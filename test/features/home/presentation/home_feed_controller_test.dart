import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/home/presentation/controllers/home_feed_controller.dart';
import 'package:posely_ai/features/pose/pose.dart';

class _MockPoseRepository extends Mock implements PoseRepository {}

Pose _pose(String id, String name) => Pose(
      id: id,
      name: name,
      previewUrl: 'https://img.posely.test/.jpg',
      overlayUrl: 'https://img.posely.test/-overlay.png',
      tags: const <String>['studio'],
      difficulty: PoseDifficulty.values.first,
      gender: PoseGender.values.first,
      aiScore: 0.86,
      downloads: 1240,
      isPremium: true,
      categoryId: 'cat-1',
    );

PoseCategory _category(int index) => PoseCategory(
      id: 'cat-$index',
      name: 'Category $index',
      emoji: '📸',
    );

void main() {
  group('HomeFeedController', () {
    late _MockPoseRepository repository;
    late ProviderContainer container;
    late List<Pose> trending;
    late List<Pose> recommended;
    late List<Pose> recent;
    late List<PoseCategory> categories;

    setUp(() {
      repository = _MockPoseRepository();
      trending = <Pose>[_pose('t1', 'Golden Hour Lean')];
      recommended = <Pose>[_pose('r1', 'Rooftop Stride')];
      recent = <Pose>[_pose('u1', 'Mirror Check')];
      categories = <PoseCategory>[_category(1), _category(2)];
      container = ProviderContainer(
        overrides: [
          poseRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
    });

    /// Stubs every repository call with a successful canned response.
    void stubSuccess() {
      when(repository.getTrending)
          .thenAnswer((_) async => ApiSuccess<List<Pose>>(trending));
      when(repository.getRecommended)
          .thenAnswer((_) async => ApiSuccess<List<Pose>>(recommended));
      when(repository.getCategories)
          .thenAnswer((_) async => ApiSuccess<List<PoseCategory>>(categories));
      when(repository.getRecentlyUsed).thenAnswer((_) async => recent);
    }

    test('build loads all four sections into one feed', () async {
      stubSuccess();

      final feed = await container.read(homeFeedControllerProvider.future);

      expect(feed.trending, trending);
      expect(feed.recommended, recommended);
      expect(feed.recentlyUsed, recent);
      expect(feed.categories, categories);
      verify(repository.getTrending).called(1);
      verify(repository.getRecommended).called(1);
      verify(repository.getCategories).called(1);
      verify(repository.getRecentlyUsed).called(1);
    });

    test('a lone trending failure folds to empty and keeps the feed as data',
        () async {
      stubSuccess();
      when(repository.getTrending).thenAnswer(
        (_) async => const ApiFailure<List<Pose>>(NetworkException()),
      );

      final feed = await container.read(homeFeedControllerProvider.future);

      expect(feed.trending, isEmpty);
      expect(feed.recommended, recommended);
      expect(feed.recentlyUsed, recent);
      expect(feed.categories, categories);
      expect(container.read(homeFeedControllerProvider).hasError, isFalse);
    });

    test('trending and recommended both failing errors the feed with the '
        'first exception', () async {
      stubSuccess();
      when(repository.getTrending).thenAnswer(
        (_) async => const ApiFailure<List<Pose>>(NetworkException()),
      );
      when(repository.getRecommended).thenAnswer(
        (_) async => const ApiFailure<List<Pose>>(ApiTimeoutException()),
      );

      await expectLater(
        container.read(homeFeedControllerProvider.future),
        throwsA(isA<NetworkException>()),
      );
      expect(container.read(homeFeedControllerProvider).hasError, isTrue);
    });

    test('a recently-used failure folds to an empty list', () async {
      stubSuccess();
      when(repository.getRecentlyUsed)
          .thenThrow(const CacheException());

      final feed = await container.read(homeFeedControllerProvider.future);

      expect(feed.recentlyUsed, isEmpty);
      expect(feed.trending, trending);
    });

    test('a categories failure folds to an empty list', () async {
      stubSuccess();
      when(repository.getCategories).thenAnswer(
        (_) async => const ApiFailure<List<PoseCategory>>(ServerException()),
      );

      final feed = await container.read(homeFeedControllerProvider.future);

      expect(feed.categories, isEmpty);
      expect(feed.trending, trending);
    });

    test('refresh refetches every source and republishes data', () async {
      stubSuccess();
      await container.read(homeFeedControllerProvider.future);

      await container.read(homeFeedControllerProvider.notifier).refresh();

      verify(repository.getTrending).called(2);
      verify(repository.getRecommended).called(2);
      verify(repository.getCategories).called(2);
      verify(repository.getRecentlyUsed).called(2);
      final state = container.read(homeFeedControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.trending, trending);
    });
  });
}
