import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/services/haptics/haptic_service.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/features/camera/presentation/controllers/camera_session_controller.dart';
import 'package:posely_ai/features/camera/presentation/widgets/camera_guides.dart';
import 'package:posely_ai/features/camera/presentation/widgets/interactive_silhouette_overlay.dart';
import 'package:posely_ai/features/pose/presentation/controllers/pose_detail_controller.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, this.poseId});

  final String? poseId;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  double _overlayOpacity = 0.5;
  bool _isCapturing = false;
  bool _showGuides = true;
  bool _isLocked = false;
  bool _isFlipped = false;

  Future<void> _handleCapture() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);
    await ref.read(hapticServiceProvider).heavy();

    try {
      await ref.read(cameraSessionProvider.notifier).captureImage();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Gallery! 📸')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraSessionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraState.when(
        data: (controller) => _buildCamera(context, controller),
        error: (err, _) => _buildError(context, err),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildCamera(BuildContext context, CameraController controller) {
    // Look up the target pose if we have an ID
    final targetPose = widget.poseId != null
        ? ref.watch(poseDetailProvider(widget.poseId!)).value
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        CameraPreview(controller),

        // Guides & Horizon
        CameraGuides(
          showGrid: _showGuides,
          showHorizon: _showGuides,
        ),

        // Interactive Ghost Silhouette Overlay
        if (targetPose != null)
          InteractiveSilhouetteOverlay(
            imageUrl: targetPose.overlayUrl,
            opacity: _overlayOpacity,
            isLocked: _isLocked,
            isFlipped: _isFlipped,
          ),

        // Top Controls (Back, Flash, Guides)
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PoselyIconButton(
                icon: Icons.close_rounded,
                onPressed: () => context.pop(),
              ),
              Row(
                children: [
                  PoselyIconButton(
                    icon: _showGuides ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                    onPressed: () => setState(() => _showGuides = !_showGuides),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PoselyIconButton(
                    icon: ref.read(cameraSessionProvider.notifier).isFlashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onPressed: () {
                      ref.read(cameraSessionProvider.notifier).toggleFlash();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Side Controls (Lock, Flip, Opacity Slider)
        if (targetPose != null)
          Positioned(
            right: AppSpacing.md,
            top: 150,
            bottom: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PoselyIconButton(
                  icon: _isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                  onPressed: () => setState(() => _isLocked = !_isLocked),
                ),
                const SizedBox(height: AppSpacing.md),
                PoselyIconButton(
                  icon: Icons.flip_rounded,
                  onPressed: () => setState(() => _isFlipped = !_isFlipped),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3, // Make it vertical
                    child: Slider(
                      value: _overlayOpacity,
                      onChanged: (val) => setState(() => _overlayOpacity = val),
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white30,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Bottom Controls (Capture, Flip Camera)
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Empty space to balance the flip button
              const SizedBox(width: 64),

              // Capture Button
              GestureDetector(
                onTap: _handleCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isCapturing ? AppColors.primary : Colors.transparent,
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

              // Flip Camera Button
              PoselyIconButton(
                icon: Icons.flip_camera_ios_rounded,
                onPressed: () {
                  ref.read(cameraSessionProvider.notifier).switchCamera();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
