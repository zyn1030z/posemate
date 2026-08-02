import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/pose/data/repositories/collection_repository.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_collection.dart';

void main() {
  late InMemoryLocalStorage localStorage;
  late CollectionRepository repository;

  setUp(() {
    localStorage = InMemoryLocalStorage();
    repository = CollectionRepository(localStorage);
  });

  group('create', () {
    test('creates an empty collection with the given name', () async {
      final collection = await repository.create('Beach Vibes');

      expect(collection.name, 'Beach Vibes');
      expect(collection.poseIds, isEmpty);
      expect(collection.id, isNotEmpty);
    });

    test('persists across reads', () async {
      await repository.create('First');
      await repository.create('Second');

      final all = repository.getAll();
      expect(all, hasLength(2));
      // Most recently updated first.
      expect(all.first.name, 'Second');
    });
  });

  group('rename', () {
    test('updates the name and updatedAt', () async {
      final original = await repository.create('Old Name');
      // Tiny delay so updatedAt differs.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final updated = await repository.rename(original.id, 'New Name');

      expect(updated?.name, 'New Name');
      expect(updated!.updatedAt.isAfter(original.updatedAt), isTrue);
    });

    test('returns null for unknown id', () async {
      final result = await repository.rename('nope', 'Name');
      expect(result, isNull);
    });
  });

  group('delete', () {
    test('removes the collection', () async {
      final c = await repository.create('Temporary');
      await repository.delete(c.id);

      expect(repository.getAll(), isEmpty);
    });

    test('does nothing for unknown id', () async {
      await repository.create('Keep');
      await repository.delete('nope');

      expect(repository.getAll(), hasLength(1));
    });
  });

  group('addPose / removePose', () {
    test('adds a pose id to the collection', () async {
      final c = await repository.create('Favorites');
      final updated = await repository.addPose(c.id, 'p1');

      expect(updated?.poseIds, ['p1']);
    });

    test('dedupes: adding the same pose twice is a no-op', () async {
      final c = await repository.create('Favorites');
      await repository.addPose(c.id, 'p1');
      final updated = await repository.addPose(c.id, 'p1');

      expect(updated?.poseIds, ['p1']);
    });

    test('removes a pose id from the collection', () async {
      final c = await repository.create('Favorites');
      await repository.addPose(c.id, 'p1');
      await repository.addPose(c.id, 'p2');
      final updated = await repository.removePose(c.id, 'p1');

      expect(updated?.poseIds, ['p2']);
    });

    test('removing a non-existent pose is a no-op', () async {
      final c = await repository.create('Favorites');
      await repository.addPose(c.id, 'p1');
      final updated = await repository.removePose(c.id, 'p99');

      expect(updated?.poseIds, ['p1']);
    });
  });

  group('PoseCollection serialization', () {
    test('round-trips through toJson and tryFromJson', () {
      final original = PoseCollection(
        id: 'abc',
        name: 'Test',
        poseIds: const ['p1', 'p2'],
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025, 6, 15),
      );

      final json = original.toJson();
      final restored = PoseCollection.tryFromJson(json);

      expect(restored, isNotNull);
      expect(restored!.id, 'abc');
      expect(restored.name, 'Test');
      expect(restored.poseIds, ['p1', 'p2']);
    });

    test('tryFromJson returns null for corrupt data', () {
      expect(
        PoseCollection.tryFromJson(<String, dynamic>{'broken': true}),
        isNull,
      );
    });
  });
}
