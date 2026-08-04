import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_collection.dart';

/// Storage key for user collections, stored as a list of JSON maps.
const String _collectionsKey = 'pose.collections';

/// Device-local repository for managing user-created pose collections.
///
/// Collections live entirely on device (Hive `poses` box) and never hit the
/// network. All mutations persist atomically — the full list is written after
/// each change — and reads tolerate corrupt entries (skipped silently).
class CollectionRepository {
  /// Creates the repository with the given local storage.
  CollectionRepository(this._localStorage);

  final LocalStorage _localStorage;

  static final Random _random = Random();

  /// Returns all collections, ordered by most recently updated first.
  List<PoseCollection> getAll() {
    final raw = _localStorage.get<List<dynamic>>(
      StorageBox.poses,
      _collectionsKey,
    );
    if (raw == null) {
      return const <PoseCollection>[];
    }
    final collections = <PoseCollection>[];
    for (final entry in raw) {
      if (entry is! Map<dynamic, dynamic>) {
        continue;
      }
      final collection = PoseCollection.tryFromJson(
        Map<String, dynamic>.from(entry),
      );
      if (collection != null) {
        collections.add(collection);
      }
    }
    // Most recently updated first.
    collections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return collections;
  }

  /// Creates a new empty collection with the given name.
  ///
  /// Returns the created collection.
  Future<PoseCollection> create(String name) async {
    final now = DateTime.now();
    final collection = PoseCollection(
      id: _generateId(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    final current = getAll();
    await _persist([...current, collection]);
    return collection;
  }

  /// Renames the collection with the given id.
  ///
  /// Returns the updated collection, or null if not found.
  Future<PoseCollection?> rename(String id, String newName) async {
    final current = getAll();
    final index = current.indexWhere((c) => c.id == id);
    if (index == -1) {
      return null;
    }
    final updated = current[index].copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    current[index] = updated;
    await _persist(current);
    return updated;
  }

  /// Deletes the collection with the given id.
  Future<void> delete(String id) async {
    final current = getAll();
    current.removeWhere((c) => c.id == id);
    await _persist(current);
  }

  /// Adds a pose id to the collection. No-op if already present.
  ///
  /// Returns the updated collection, or null if the collection was not found.
  Future<PoseCollection?> addPose(String collectionId, String poseId) async {
    final current = getAll();
    final index = current.indexWhere((c) => c.id == collectionId);
    if (index == -1) {
      return null;
    }
    final collection = current[index];
    if (collection.poseIds.contains(poseId)) {
      return collection;
    }
    final updated = collection.copyWith(
      poseIds: [...collection.poseIds, poseId],
      updatedAt: DateTime.now(),
    );
    current[index] = updated;
    await _persist(current);
    return updated;
  }

  /// Removes a pose id from the collection. No-op if not present.
  ///
  /// Returns the updated collection, or null if the collection was not found.
  Future<PoseCollection?> removePose(String collectionId, String poseId) async {
    final current = getAll();
    final index = current.indexWhere((c) => c.id == collectionId);
    if (index == -1) {
      return null;
    }
    final collection = current[index];
    if (!collection.poseIds.contains(poseId)) {
      return collection;
    }
    final updated = collection.copyWith(
      poseIds: collection.poseIds.where((id) => id != poseId).toList(),
      updatedAt: DateTime.now(),
    );
    current[index] = updated;
    await _persist(current);
    return updated;
  }

  Future<void> _persist(List<PoseCollection> collections) {
    return _localStorage.put(
      StorageBox.poses,
      _collectionsKey,
      collections.map((c) => c.toJson()).toList(),
    );
  }

  /// Generates a short random hex id.
  static String _generateId() {
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }
    return buffer.toString();
  }
}

/// Provides the app-wide collection repository.
final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(ref.watch(localStorageProvider)),
);
