import 'dart:io';

import 'package:camera/camera.dart';
import 'package:posely_ai/features/camera/domain/entities/camera_state.dart';

/// Abstract service handling the hardware camera lifecycle and operations.
abstract class CameraService {
  /// Initializes the camera subsystem and requests permissions.
  Future<void> initialize();

  /// Disposes the camera subsystem.
  Future<void> dispose();

  /// Sets the flash mode.
  Future<void> setFlashMode(FlashMode mode);

  /// Sets the zoom level. Returns the clamped level that was actually set.
  Future<double> setZoomLevel(double zoom);

  /// Switches the camera lens direction (front/back).
  Future<void> switchLens();

  /// Captures a photo and returns the temporary file.
  Future<File?> takePicture();

  /// Sets the visual grid type.
  Future<void> setGrid(CameraGrid grid);

  /// Exposes the underlying CameraController for the UI Preview widget.
  CameraController? get controller;

  /// Stream of state changes.
  Stream<CameraState> get stateStream;

  /// The current state of the camera synchronously.
  CameraState get currentState;
}
