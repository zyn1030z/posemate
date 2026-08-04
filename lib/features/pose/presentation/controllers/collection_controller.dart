import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/pose/data/repositories/collection_repository.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_collection.dart';

/// Controller managing the user's pose collections.
///
/// The state is a synchronous list because collections are read from the
/// local Hive box (sync reads). All mutations write-through to the repository
/// and refresh the in-memory list.
class CollectionController extends Notifier<List<PoseCollection>> {
  CollectionRepository get _repository =>
      ref.read(collectionRepositoryProvider);

  @override
  List<PoseCollection> build() => _repository.getAll();

  /// Creates a new empty collection with the given name.
  Future<PoseCollection> create(String name) async {
    final collection = await _repository.create(name);
    state = _repository.getAll();
    return collection;
  }

  /// Renames the collection.
  Future<void> rename(String id, String newName) async {
    await _repository.rename(id, newName);
    state = _repository.getAll();
  }

  /// Deletes the collection.
  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = _repository.getAll();
  }

  /// Adds a pose to a collection.
  Future<void> addPose(String collectionId, String poseId) async {
    await _repository.addPose(collectionId, poseId);
    state = _repository.getAll();
  }

  /// Removes a pose from a collection.
  Future<void> removePose(String collectionId, String poseId) async {
    await _repository.removePose(collectionId, poseId);
    state = _repository.getAll();
  }
}

/// Provides the collection controller and its state.
final collectionControllerProvider =
    NotifierProvider<CollectionController, List<PoseCollection>>(
      CollectionController.new,
    );
