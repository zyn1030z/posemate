import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_state.freezed.dart';

/// Defines the visual grid overlaid on the camera preview.
enum CameraGrid {
  /// No grid is shown.
  none,

  /// Rule of thirds grid (3x3).
  ruleOfThirds,

  /// Golden ratio spiral or grid.
  goldenRatio,

  /// Crosshairs indicating the center.
  center,
}

/// Represents the current configuration and operational status of the camera.
@freezed
abstract class CameraState with _$CameraState {
  /// Creates a [CameraState].
  const factory CameraState({
    /// Whether the camera is initialized and ready to stream.
    @Default(false) bool isInitialized,

    /// The current flash mode.
    @Default(FlashMode.off) FlashMode flashMode,

    /// The active lens direction (front/back).
    @Default(CameraLensDirection.back) CameraLensDirection lensDirection,

    /// The current zoom level.
    @Default(1.0) double zoomLevel,

    /// The minimum allowed zoom level for the current lens.
    @Default(1.0) double minZoomLevel,

    /// The maximum allowed zoom level for the current lens.
    @Default(1.0) double maxZoomLevel,

    /// The active visual grid overlaid on the preview.
    @Default(CameraGrid.none) CameraGrid grid,

    /// True while a photo is being captured.
    @Default(false) bool isCapturing,

    /// If an error occurred (e.g., permissions denied).
    String? error,
  }) = _CameraState;
}
