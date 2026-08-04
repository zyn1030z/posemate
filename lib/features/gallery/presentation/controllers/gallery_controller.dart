import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/gallery/data/repositories/gallery_repository.dart';
import 'package:posely_ai/features/gallery/domain/entities/capture_record.dart';

final galleryControllerProvider =
    AsyncNotifierProvider<GalleryController, List<CaptureRecord>>(
  GalleryController.new,
);

class GalleryController extends AsyncNotifier<List<CaptureRecord>> {
  @override
  FutureOr<List<CaptureRecord>> build() async {
    final repo = ref.watch(galleryRepositoryProvider);
    
    // Attempt background sync when first loading
    _syncInBackground(repo);

    return repo.getLocalCaptures();
  }

  void _syncInBackground(GalleryRepository repo) async {
    try {
      await repo.syncPendingCaptures();
      // Reload the captures after a background sync completes
      state = AsyncValue.data(repo.getLocalCaptures());
    } catch (_) {
      // Ignore background sync errors
    }
  }

  /// Refreshes the local gallery and triggers a background sync.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repo = ref.read(galleryRepositoryProvider);
    try {
      await repo.syncPendingCaptures();
    } finally {
      state = AsyncValue.data(repo.getLocalCaptures());
    }
  }

  /// Deletes a capture from the gallery.
  Future<void> deleteCapture(String id) async {
    final previousState = state;
    
    // Optimistic UI update
    if (state.value != null) {
      final updated = state.value!.where((c) => c.id != id).toList();
      state = AsyncValue.data(updated);
    }
    
    try {
      final repo = ref.read(galleryRepositoryProvider);
      await repo.deleteCapture(id);
    } catch (e, stack) {
      state = previousState;
      state = AsyncValue.error(e, stack);
    }
  }
}
