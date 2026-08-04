import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/camera/domain/entities/overlay_transform.dart';

/// Manages the ghost silhouette overlay's transformation state.
class OverlayTransformController extends Notifier<OverlayTransform> {
  @override
  OverlayTransform build() {
    return const OverlayTransform();
  }

  /// Updates the translation offset.
  void updateOffset(Offset delta) {
    if (state.isLocked) return;
    state = state.copyWith(offset: state.offset + delta);
  }

  /// Updates the scale multiplier.
  void updateScale(double scaleDelta) {
    if (state.isLocked) return;
    final newScale = (state.scale * scaleDelta).clamp(0.5, 3.0);
    state = state.copyWith(scale: newScale);
  }

  /// Updates the rotation.
  void updateRotation(double rotationDelta) {
    if (state.isLocked) return;
    state = state.copyWith(rotation: state.rotation + rotationDelta);
  }

  /// Updates the opacity of the ghost silhouette.
  void setOpacity(double opacity) {
    state = state.copyWith(opacity: opacity.clamp(0.0, 1.0));
  }

  /// Toggles horizontal flip.
  void toggleFlip() {
    if (state.isLocked) return;
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  /// Toggles the transform lock, preventing accidental gestures.
  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
  }

  /// Toggles the visibility of the overlay entirely.
  void toggleVisibility() {
    state = state.copyWith(isHidden: !state.isHidden);
  }

  /// Resets the transform to default values.
  void reset() {
    if (state.isLocked) return;
    state = const OverlayTransform();
  }
}

/// Provides the OverlayTransformController.
final overlayTransformControllerProvider =
    NotifierProvider<OverlayTransformController, OverlayTransform>(
      OverlayTransformController.new,
    );
