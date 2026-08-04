import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'overlay_transform.freezed.dart';

/// Represents the pan, scale, rotation, and display properties for the ghost silhouette.
@freezed
abstract class OverlayTransform with _$OverlayTransform {
  /// Creates an [OverlayTransform].
  const factory OverlayTransform({
    /// The translation offset relative to the center of the gesture area.
    @Default(Offset.zero) Offset offset,

    /// The zoom scale of the overlay.
    @Default(1.0) double scale,

    /// The rotation in radians.
    @Default(0.0) double rotation,

    /// The opacity of the ghost silhouette (0.0 to 1.0).
    @Default(0.3) double opacity,

    /// Whether the overlay is flipped horizontally (mirror effect).
    @Default(false) bool isFlipped,

    /// Whether gestures are locked to prevent accidental movement.
    @Default(false) bool isLocked,

    /// Whether the overlay is temporarily hidden.
    @Default(false) bool isHidden,
  }) = _OverlayTransform;
}
