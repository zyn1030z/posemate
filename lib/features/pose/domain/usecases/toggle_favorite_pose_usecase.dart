import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Flips the favorite state of a pose on this device.
class ToggleFavoritePoseUseCase {
  /// Creates the use case over the repository.
  const ToggleFavoritePoseUseCase(this._repository);

  final PoseRepository _repository;

  /// Executes the toggle and returns the new state: true when the pose is
  /// now a favorite, false when it no longer is.
  Future<bool> call(String poseId) => _repository.toggleFavorite(poseId);
}

/// Provides the favorite-toggle use case.
final toggleFavoritePoseUseCaseProvider = Provider<ToggleFavoritePoseUseCase>(
  (ref) => ToggleFavoritePoseUseCase(ref.watch(poseRepositoryProvider)),
);
