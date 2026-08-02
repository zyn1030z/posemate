import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/pose/data/datasources/pose_remote_datasource.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

class _MockPoseRemoteDatasource extends Mock implements PoseRemoteDatasource {}

Pose _pose(String id) => Pose(
  id: id,
  name: 'Pose $id',
  previewUrl: 'https://example.com/$id.jpg',
  overlayUrl: 'https://example.com/$id-ov.png',
  categoryId: 'beach',
);

void main() {
  const favoritesKey = StorageKeys.favoritePoseIds;
  const recentKey = StorageKeys.lastUsedPoseIds;

  late _MockPoseRemoteDatasource remote;
  late InMemoryLocalStorage localStorage;
  late PoseRepositoryImpl repository;

  setUp(() {
    remote = _MockPoseRemoteDatasource();
    localStorage = InMemoryLocalStorage();
    repository = PoseRepositoryImpl(
      remoteDatasource: remote,
      localStorage: localStorage,
    );
  });

  group('toggleFavorite', () {
    test('turns a pose into a favorite and persists the id', () async {
      final isFavorite = await repository.toggleFavorite('p1');

      expect(isFavorite, isTrue);
      expect(await repository.getFavoriteIds(), {'p1'});
      expect(
        localStorage.get<List<dynamic>>(StorageBox.poses, favoritesKey),
        ['p1'],
      );
    });

    test('round-trips back off and clears the persisted id', () async {
      await repository.toggleFavorite('p1');
      final isFavorite = await repository.toggleFavorite('p1');

      expect(isFavorite, isFalse);
      expect(await repository.getFavoriteIds(), isEmpty);
      expect(
        localStorage.get<List<dynamic>>(StorageBox.poses, favoritesKey),
        isEmpty,
      );
    });

    test('keeps other favorites untouched when toggling one off', () async {
      await repository.toggleFavorite('p1');
      await repository.toggleFavorite('p2');
      await repository.toggleFavorite('p1');

      expect(await repository.getFavoriteIds(), {'p2'});
    });
  });

  group('markUsed', () {
    test('keeps the most recent pose first', () async {
      await repository.markUsed(_pose('p1'));
      await repository.markUsed(_pose('p2'));

      final recent = await repository.getRecentlyUsed();
      expect(recent.map((pose) => pose.id), ['p2', 'p1']);
    });

    test('dedupes by id, moving a reused pose to the front', () async {
      await repository.markUsed(_pose('p1'));
      await repository.markUsed(_pose('p2'));
      await repository.markUsed(_pose('p1'));

      final recent = await repository.getRecentlyUsed();
      expect(recent.map((pose) => pose.id), ['p1', 'p2']);
    });

    test('caps the list at 12, dropping the oldest', () async {
      for (var i = 1; i <= 13; i++) {
        await repository.markUsed(_pose('p$i'));
      }

      final recent = await repository.getRecentlyUsed();
      expect(recent, hasLength(12));
      expect(recent.first.id, 'p13');
      expect(recent.map((pose) => pose.id), isNot(contains('p1')));
    });

    test('stores wire-shaped maps that survive an entity round trip', () async {
      const original = Pose(
        id: 'p1',
        name: 'Latte Art Lean',
        previewUrl: 'https://example.com/p1.jpg',
        overlayUrl: 'https://example.com/p1-ov.png',
        tags: ['coffee', 'cozy'],
        difficulty: PoseDifficulty.medium,
        gender: PoseGender.couple,
        bodyDirection: 'side',
        cameraAngle: 'low',
        aiScore: 4.6,
        downloads: 27390,
        isPremium: true,
        categoryId: 'cafe',
      );

      await repository.markUsed(original);

      final recent = await repository.getRecentlyUsed();
      expect(recent.single, original);
    });
  });

  group('getRecentlyUsed', () {
    test('skips corrupt entries and keeps the valid ones', () async {
      const validMap = <String, Object?>{
        'id': 'kept',
        'name': 'Kept Pose',
        'preview_url': 'https://example.com/kept.jpg',
        'overlay_url': 'https://example.com/kept-ov.png',
        'tags': <String>['candid'],
        'difficulty': 'medium',
        'gender': 'female',
        'body_direction': 'side',
        'camera_angle': 'low',
        'ai_score': 4.4,
        'downloads': 1200,
        'is_premium': true,
        'category_id': 'beach',
      };
      await localStorage.put(StorageBox.poses, recentKey, <Object?>[
        'garbage',
        <String, Object?>{'id': 'broken'},
        validMap,
      ]);

      final recent = await repository.getRecentlyUsed();

      expect(recent, hasLength(1));
      expect(recent.single.id, 'kept');
      expect(recent.single.difficulty, PoseDifficulty.medium);
      expect(recent.single.isPremium, isTrue);
    });

    test('returns an empty list when nothing is stored', () async {
      expect(await repository.getRecentlyUsed(), isEmpty);
    });
  });

  group('getPoses', () {
    test('converts enum filters to wire strings and maps items', () async {
      const model = PoseModel(
        id: 'p1',
        name: 'Crosswalk Stride',
        previewUrl: 'https://example.com/p1.jpg',
        overlayUrl: 'https://example.com/p1-ov.png',
        difficulty: 'medium',
        gender: 'female',
        categoryId: 'street',
      );
      when(
        () => remote.getPoses(
          page: 2,
          pageSize: 10,
          categoryId: 'street',
          difficulty: 'medium',
          gender: 'female',
        ),
      ).thenAnswer(
        (_) async => const Paginated<PoseModel>(
          items: [model],
          page: 2,
          pageSize: 10,
          totalItems: 11,
          hasMore: false,
        ),
      );

      final result = await repository.getPoses(
        page: 2,
        pageSize: 10,
        categoryId: 'street',
        difficulty: PoseDifficulty.medium,
        gender: PoseGender.female,
      );

      final page = result.dataOrNull;
      expect(page, isNotNull);
      expect(page?.items.single.difficulty, PoseDifficulty.medium);
      expect(page?.items.single.gender, PoseGender.female);
      expect(page?.totalItems, 11);
      expect(page?.hasMore, isFalse);
    });
  });

  group('guardApi mapping', () {
    test('maps a DioException from the datasource to ApiFailure', () async {
      when(() => remote.getCategories()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/poses/categories'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getCategories();

      expect(result.isSuccess, isFalse);
      expect(result.exceptionOrNull, isA<NetworkException>());
    });

    test('maps a thrown AppException to ApiFailure unchanged', () async {
      when(
        () => remote.getPoseById('missing'),
      ).thenThrow(const NotFoundException());

      final result = await repository.getPoseById('missing');

      expect(result.exceptionOrNull, isA<NotFoundException>());
    });
  });
}
