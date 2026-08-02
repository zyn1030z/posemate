import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages a global queue of pose IDs for the next photoshoot session.
class PhotoshootQueueNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return <String>{};
  }

  /// Adds a pose to the queue.
  void add(String poseId) {
    state = {...state, poseId};
  }

  /// Removes a pose from the queue.
  void remove(String poseId) {
    final next = Set<String>.from(state);
    next.remove(poseId);
    state = next;
  }

  /// Toggles a pose's presence in the queue.
  void toggle(String poseId) {
    if (state.contains(poseId)) {
      remove(poseId);
    } else {
      add(poseId);
    }
  }

  /// Clears the entire queue.
  void clear() {
    state = const <String>{};
  }
}

/// Provider for the global photoshoot queue.
final photoshootQueueProvider =
    NotifierProvider<PhotoshootQueueNotifier, Set<String>>(
  PhotoshootQueueNotifier.new,
);
