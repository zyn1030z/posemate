import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Owns the set of pose ids the user has marked as favorite.
///
/// Toggles are optimistic: the id flips in state immediately so hearts
/// respond instantly, and the repository write happens afterwards. When
/// the write fails the previous set is restored, which flips the heart
/// back — that revert is the whole user-facing error handling, so the
/// failure itself is only logged, never rethrown.
class FavoritePoseIdsController extends AsyncNotifier<Set<String>> {
  PoseRepository get _repository => ref.read(poseRepositoryProvider);

  @override
  Future<Set<String>> build() {
    return ref.watch(poseRepositoryProvider).getFavoriteIds();
  }

  /// Flips the favorite membership of the given pose id.
  ///
  /// State updates before the repository call so the UI reacts
  /// immediately; a failed persist reverts to the previous set. The
  /// repository's returned bool is intentionally ignored — the
  /// optimistic set is already the source of truth for this session.
  Future<void> toggle(String poseId) async {
    final previous = state.value ?? const <String>{};
    final updated = previous.contains(poseId)
        ? previous.where((id) => id != poseId).toSet()
        : <String>{...previous, poseId};
    state = AsyncData<Set<String>>(updated);
    try {
      await _repository.toggleFavorite(poseId);
    } catch (error, stackTrace) {
      state = AsyncData<Set<String>>(previous);
      _logToggleFailure(poseId, error, stackTrace);
    }
  }

  void _logToggleFailure(String poseId, Object error, StackTrace stackTrace) {
    try {
      ref.read(talkerProvider).warning(
            'Failed to toggle favorite for pose $poseId',
            error,
            stackTrace,
          );
    } catch (_) {
      // Logger not bootstrapped (bare unit-test containers); the revert
      // above already handled the failure for the user.
    }
  }
}

/// The user's favorite pose ids, shared by every heart in the app.
final favoritePoseIdsProvider =
    AsyncNotifierProvider<FavoritePoseIdsController, Set<String>>(
  FavoritePoseIdsController.new,
);
