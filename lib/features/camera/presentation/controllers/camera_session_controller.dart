import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/camera/data/services/camera_service_impl.dart';
import 'package:posely_ai/features/camera/domain/entities/camera_state.dart';
import 'package:posely_ai/features/camera/domain/services/camera_service.dart';

/// Manages the camera session and UI state.
class CameraSessionController extends AsyncNotifier<CameraState> {
  CameraService get _cameraService => ref.read(cameraServiceProvider);
  StreamSubscription<CameraState>? _subscription;

  @override
  FutureOr<CameraState> build() async {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    _subscription = _cameraService.stateStream.listen((state) {
      this.state = AsyncValue.data(state);
    });

    await _cameraService.initialize();

    // Fallback if the stream hasn't fired yet
    return const CameraState();
  }

  /// Sets the flash mode.
  Future<void> setFlashMode(FlashMode mode) async {
    await _cameraService.setFlashMode(mode);
  }

  /// Sets the zoom level.
  Future<void> setZoomLevel(double zoom) async {
    await _cameraService.setZoomLevel(zoom);
  }

  /// Switches between front and back lens.
  Future<void> switchLens() async {
    await _cameraService.switchLens();
  }

  /// Sets the grid type.
  Future<void> setGrid(CameraGrid grid) async {
    await _cameraService.setGrid(grid);
  }

  /// Captures a photo.
  Future<File?> takePicture() async {
    return _cameraService.takePicture();
  }
}

/// Provides the CameraSessionController.
final cameraSessionControllerProvider =
    AsyncNotifierProvider<CameraSessionController, CameraState>(
      CameraSessionController.new,
    );
