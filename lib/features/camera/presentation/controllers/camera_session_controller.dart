import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Notifier that manages the lifecycle of the [CameraController].
class CameraSessionController extends AsyncNotifier<CameraController> {
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isFlashOn = false;

  CameraController? _activeController;

  @override
  FutureOr<CameraController> build() async {
    // Keep screen awake while camera is active
    unawaited(WakelockPlus.enable());

    // Ensure the camera is disposed when the provider is destroyed.
    ref.onDispose(() {
      unawaited(WakelockPlus.disable());
      final controller = _activeController;
      if (controller != null) {
        unawaited(controller.dispose());
      }
    });

    return _initializeCamera();
  }

  Future<CameraController> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw const AppCameraException(message: 'No cameras available on this device.');
      }

      // Default to the first available camera (usually the back camera).
      final camera = _cameras[_currentCameraIndex];
      
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888, // Recommended for ML Kit
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      _isFlashOn = false;
      
      _startMLKitStream(controller);
      
      _activeController = controller;
      return controller;
    } on CameraException catch (e) {
      if (e.description != null && e.description!.contains('permission')) {
        throw const AppCameraException(
          message: 'Camera permission denied. Please grant access in Settings.',
        );
      }
      throw AppCameraException(
        message: 'Failed to initialize camera: ${e.description}',
      );
    } catch (e, st) {
      throw AppCameraException(
        message: 'Unexpected error initializing camera.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  bool _isProcessingImage = false;
  
  /// Switches between the available cameras (e.g. front and back).
  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final oldController = state.value;
      if (oldController != null && oldController.value.isStreamingImages) {
        await oldController.stopImageStream();
      }
      await oldController?.dispose();

      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      final newCamera = _cameras[_currentCameraIndex];

      final newController = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await newController.initialize();
      
      // Preserve flash state if possible, though front camera might not have flash.
      try {
        await newController.setFlashMode(_isFlashOn ? FlashMode.always : FlashMode.off);
      } catch (_) {
        // Ignore flash errors for cameras that don't support it
        _isFlashOn = false;
      }
      
      _startMLKitStream(newController);

      return newController;
    });
  }

  void _startMLKitStream(CameraController controller) {
    if (controller.value.isStreamingImages) return;
    controller.startImageStream((CameraImage image) async {
      // Throttle: drop frames if we are already processing one
      if (_isProcessingImage) return;
      _isProcessingImage = true;

      try {
        // PHASE 9: Here we will pass `image` to ML Kit PoseDetector.
        // For Phase 8, we just mock the throttle to ensure it doesn't melt the CPU.
        // Example: await MLKitService.detectPose(image);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } finally {
        _isProcessingImage = false;
      }
    });
  }

  /// Toggles the flash mode.
  Future<void> toggleFlash() async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      await controller.setFlashMode(_isFlashOn ? FlashMode.always : FlashMode.off);
      // We don't change state reference so UI doesn't rebuild entire preview,
      // but we update the flash state. However, to trigger a rebuild for the flash icon,
      // we need to notify listeners.
      state = AsyncValue.data(controller);
    } catch (e) {
      _isFlashOn = !_isFlashOn; // Revert on failure
    }
  }

  /// Whether the flash is currently on.
  bool get isFlashOn => _isFlashOn;

  /// Captures an image and saves it to the gallery using `gal`.
  Future<void> captureImage() async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      throw const AppCameraException(message: 'Camera is not ready.');
    }
    if (controller.value.isTakingPicture) return;

    try {
      final file = await controller.takePicture();
      // Save to gallery
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
      await Gal.putImage(file.path);
    } catch (e, st) {
      throw AppCameraException(
        message: 'Failed to capture or save image.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}

/// Provider for the camera session.
final cameraSessionProvider =
    AsyncNotifierProvider.autoDispose<CameraSessionController, CameraController>(
  CameraSessionController.new,
);
