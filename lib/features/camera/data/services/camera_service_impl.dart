import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/camera/domain/entities/camera_state.dart';
import 'package:posely_ai/features/camera/domain/services/camera_service.dart';

class CameraServiceImpl implements CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  final _stateController = StreamController<CameraState>.broadcast();
  CameraState _currentState = const CameraState();

  @override
  CameraController? get controller => _controller;

  @override
  Stream<CameraState> get stateStream => _stateController.stream;

  @override
  CameraState get currentState => _currentState;

  void _emit(CameraState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Future<void> initialize() async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _emit(_currentState.copyWith(error: 'Camera permission denied.'));
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _emit(_currentState.copyWith(error: 'No cameras found.'));
        return;
      }

      await _initCamera(_cameras.first);
    } catch (e) {
      _emit(_currentState.copyWith(error: 'Failed to initialize camera: $e'));
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    unawaited(_controller?.dispose());

    // Use medium/high resolution for preview and capture
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();

      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();

      final direction = description.lensDirection;

      _emit(
        _currentState.copyWith(
          isInitialized: true,
          lensDirection: direction,
          minZoomLevel: minZoom,
          maxZoomLevel: maxZoom,
          zoomLevel: 1.0,
          error: null,
        ),
      );
    } catch (e) {
      _emit(_currentState.copyWith(error: 'Camera error: $e'));
    }
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    await _stateController.close();
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFlashMode(mode);
      _emit(_currentState.copyWith(flashMode: mode));
    } catch (e) {
      _emit(_currentState.copyWith(error: 'Failed to set flash: $e'));
    }
  }

  @override
  Future<void> setGrid(CameraGrid grid) async {
    _emit(_currentState.copyWith(grid: grid));
  }

  @override
  Future<double> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return zoom;

    final clamped = zoom.clamp(
      _currentState.minZoomLevel,
      _currentState.maxZoomLevel,
    );
    try {
      await _controller!.setZoomLevel(clamped);
      _emit(_currentState.copyWith(zoomLevel: clamped));
      return clamped;
    } catch (e) {
      _emit(_currentState.copyWith(error: 'Failed to set zoom: $e'));
      return _currentState.zoomLevel;
    }
  }

  @override
  Future<void> switchLens() async {
    if (_cameras.length < 2) return;

    final currentDirection = _currentState.lensDirection;
    final targetDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final targetCamera = _cameras.firstWhere(
      (c) => c.lensDirection == targetDirection,
      orElse: () => _cameras.first,
    );

    await _initCamera(targetCamera);
  }

  @override
  Future<File?> takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture) {
      return null;
    }

    try {
      _emit(_currentState.copyWith(isCapturing: true));

      if (Platform.isIOS) {
        unawaited(_controller!.lockCaptureOrientation());
      }
      final file = await _controller!.takePicture();

      _emit(_currentState.copyWith(isCapturing: false));
      return File(file.path);
    } catch (e) {
      _emit(
        _currentState.copyWith(
          isCapturing: false,
          error: 'Failed to take picture: $e',
        ),
      );
      throw const UnknownException(message: 'Camera capture failed');
    }
  }
}

/// Provides the CameraService interface.
final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraServiceImpl();
  ref.onDispose(service.dispose);
  return service;
});
