import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';
import 'package:posely_ai/features/pose/presentation/controllers/favorite_pose_ids_controller.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockPoseRepository extends Mock implements PoseRepository {}

void main() {
  group('FavoritePoseIdsController', () {
    late _MockPoseRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _MockPoseRepository();
      container = ProviderContainer(
        overrides: [
          poseRepositoryProvider.overrideWithValue(repository),
          talkerProvider.overrideWithValue(Talker()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('build exposes the stored favorite ids', () async {
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{'a'});

      final ids = await container.read(favoritePoseIdsProvider.future);

      expect(ids, <String>{'a'});
    });

    test('toggle adds optimistically before the repository completes',
        () async {
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{'a'});
      final write = Completer<bool>();
      when(() => repository.toggleFavorite('b'))
          .thenAnswer((_) => write.future);
      await container.read(favoritePoseIdsProvider.future);

      final toggleCall =
          container.read(favoritePoseIdsProvider.notifier).toggle('b');

      // The id is in state before the repository write resolves.
      expect(
        container.read(favoritePoseIdsProvider).value,
        <String>{'a', 'b'},
      );

      write.complete(true);
      await toggleCall;
      expect(
        container.read(favoritePoseIdsProvider).value,
        <String>{'a', 'b'},
      );
      verify(() => repository.toggleFavorite('b')).called(1);
    });

    test('toggle removes an existing favorite', () async {
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{'a', 'b'});
      when(() => repository.toggleFavorite('a'))
          .thenAnswer((_) async => false);
      await container.read(favoritePoseIdsProvider.future);

      await container.read(favoritePoseIdsProvider.notifier).toggle('a');

      expect(container.read(favoritePoseIdsProvider).value, <String>{'b'});
    });

    test('a failed write reverts the optimistic flip and swallows the error',
        () async {
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{'a'});
      when(() => repository.toggleFavorite('b'))
          .thenThrow(const NetworkException());
      await container.read(favoritePoseIdsProvider.future);

      // Completes normally: the failure is logged, not rethrown.
      await container.read(favoritePoseIdsProvider.notifier).toggle('b');

      expect(container.read(favoritePoseIdsProvider).value, <String>{'a'});
    });

    test('a failed removal restores the id', () async {
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{'a'});
      when(() => repository.toggleFavorite('a'))
          .thenThrow(const NetworkException());
      await container.read(favoritePoseIdsProvider.future);

      await container.read(favoritePoseIdsProvider.notifier).toggle('a');

      expect(container.read(favoritePoseIdsProvider).value, <String>{'a'});
    });
  });
}
