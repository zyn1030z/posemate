import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
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

    return _cameraService.currentState;
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

  /// Captures a photo and saves it to the device gallery.
  ///
  /// Returns a record of the captured file (null if the capture itself
  /// failed) and whether the file was successfully saved to the gallery.
  Future<(File?, bool)> takePicture() async {
    final file = await _cameraService.takePicture();
    if (file == null) {
      return (null, false);
    }

    final talker = ref.read(talkerProvider);
    try {
      var hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }
      if (!hasAccess) {
        talker.warning('Gallery access denied — capture not saved');
        return (file, false);
      }
      await Gal.putImage(file.path);
      return (file, true);
    } on GalException catch (e) {
      talker.error('Failed to save capture to gallery', e);
      return (file, false);
    }
  }
}

/// Provides the CameraSessionController.
final cameraSessionControllerProvider =
    AsyncNotifierProvider<CameraSessionController, CameraState>(
      CameraSessionController.new,
    );
