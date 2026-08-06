import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/shared/widgets/app_loading_view.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/features/camera/data/services/camera_service_impl.dart';
import 'package:posely_ai/features/camera/domain/entities/camera_state.dart';
import 'package:posely_ai/features/camera/presentation/controllers/camera_session_controller.dart';
import 'package:posely_ai/features/camera/presentation/controllers/overlay_transform_controller.dart';
import 'package:posely_ai/features/camera/presentation/widgets/ai_coach_hud.dart';
import 'package:posely_ai/features/camera/presentation/widgets/camera_guides.dart';

/// The main camera screen with AI guides and ghost silhouette overlays.
class CameraScreen extends ConsumerStatefulWidget {
  /// The optional list of pose IDs to load for the session.
  final List<String>? poseIds;

  /// The optional AI Coach ID to use for this session.
  final String? coachId;

  const CameraScreen({super.key, this.poseIds, this.coachId});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // In a real app we'd fetch the pose details if needed.
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraStateAsync = ref.watch(cameraSessionControllerProvider);
    final transformState = ref.watch(overlayTransformControllerProvider);
    final cameraControllerNotifier = ref.watch(
      cameraSessionControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraStateAsync.when(
        data: (cameraState) {
          if (cameraState.error != null) {
            return AppErrorView(
              message: cameraState.error!,
              onRetry: () {
                ref.invalidate(cameraSessionControllerProvider);
              },
            );
          }

          if (!cameraState.isInitialized) {
            return const AppLoadingView(message: 'Initializing camera...');
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Preview
              _CameraPreviewWidget(),

              // 2. Guides
              if (cameraState.grid != CameraGrid.none)
                CameraGuides(gridType: cameraState.grid),

              // 3. Ghost Silhouette Overlay
              if (!transformState.isHidden)
                const _GhostSilhouetteInteractiveLayer(
                  imagePath: 'assets/mock/lineart_mock.png',
                ),

              // 3.5. AI Coach HUD
              if (widget.coachId != null)
                AiCoachHud(coachId: widget.coachId!),

              // 4. Top Controls (Glass)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 16,
                left: 16,
                right: 16,
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PoselyIconButton(
                        icon: Icons.close,
                        onPressed: () => context.pop(),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              cameraState.flashMode == FlashMode.off
                                  ? Icons.flash_off
                                  : cameraState.flashMode == FlashMode.always
                                  ? Icons.flash_on
                                  : Icons.flash_auto,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              final nextMode =
                                  cameraState.flashMode == FlashMode.off
                                  ? FlashMode.auto
                                  : cameraState.flashMode == FlashMode.auto
                                  ? FlashMode.always
                                  : FlashMode.off;
                              cameraControllerNotifier.setFlashMode(nextMode);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              cameraState.grid == CameraGrid.none
                                  ? Icons.grid_off
                                  : Icons.grid_3x3,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              final nextGrid =
                                  cameraState.grid == CameraGrid.none
                                  ? CameraGrid.ruleOfThirds
                                  : CameraGrid.none;
                              cameraControllerNotifier.setGrid(nextGrid);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Bottom Controls (Capture & Lens)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: Row(
                        children: [
                          const Text(
                            '1x',
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(
                            child: Slider(
                              value: cameraState.zoomLevel,
                              min: cameraState.minZoomLevel,
                              max: cameraState.maxZoomLevel,
                              activeColor: AppColors.primary,
                              inactiveColor: Colors.white30,
                              onChanged: cameraControllerNotifier.setZoomLevel,
                            ),
                          ),
                          Text(
                            '${cameraState.maxZoomLevel.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left: Gallery Thumbnail (Mocked)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        // Center: Capture Button
                        GestureDetector(
                          onTap: cameraState.isCapturing
                              ? null
                              : () async {
                                  final (file, saved) =
                                      await cameraControllerNotifier
                                          .takePicture();
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (file == null) {
                                    PoselyToast.show(
                                      context,
                                      message: 'Capture failed. Try again.',
                                      kind: PoselyToastKind.error,
                                    );
                                  } else if (saved) {
                                    PoselyToast.show(
                                      context,
                                      message: 'Photo saved to gallery',
                                      kind: PoselyToastKind.success,
                                    );
                                  } else {
                                    PoselyToast.show(
                                      context,
                                      message:
                                          'Captured, but not saved to gallery',
                                      kind: PoselyToastKind.error,
                                    );
                                  }
                                },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: cameraState.isCapturing
                                  ? Colors.white54
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Right: Switch Lens
                        PoselyIconButton(
                          icon: Icons.flip_camera_ios,
                          onPressed: cameraControllerNotifier.switchLens,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoadingView(message: 'Starting camera...'),
        error: (err, stack) => AppErrorView(
          message: 'Camera failed: $err',
          onRetry: () {
            ref.invalidate(cameraSessionControllerProvider);
          },
        ),
      ),
    );
  }
}

class _CameraPreviewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(cameraServiceProvider);
    if (service.controller == null ||
        !service.controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(service.controller!);
  }
}

class _GhostSilhouetteInteractiveLayer extends ConsumerWidget {
  final String imagePath;

  const _GhostSilhouetteInteractiveLayer({required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transform = ref.watch(overlayTransformControllerProvider);
    final transformNotifier = ref.read(
      overlayTransformControllerProvider.notifier,
    );

    return GestureDetector(
      onPanUpdate: (details) {
        transformNotifier.updateOffset(details.delta);
      },
      child: Transform.translate(
        offset: transform.offset,
        child: Transform.scale(
          scale: transform.scale,
          child: Transform.rotate(
            angle: transform.rotation,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(transform.isFlipped ? 3.14159 : 0),
              child: Opacity(
                opacity: transform.opacity,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
