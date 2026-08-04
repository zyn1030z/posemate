import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/features/gallery/presentation/controllers/gallery_controller.dart';

/// Screen for viewing a captured photo and performing actions (compare, share, delete).
class CaptureDetailScreen extends ConsumerStatefulWidget {
  const CaptureDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<CaptureDetailScreen> createState() => _CaptureDetailScreenState();
}

class _CaptureDetailScreenState extends ConsumerState<CaptureDetailScreen> {
  bool _isComparing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // True OLED black for full screen viewing
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PoselyIconButton(
          icon: Icons.close,
          onPressed: () => context.pop(),
        ),
        actions: [
          PoselyIconButton(
            icon: Icons.share_rounded,
            onPressed: () async {
              final capture = state.value?.firstWhere((c) => c.id == widget.id);
              if (capture != null) {
                await Share.shareXFiles([XFile(capture.localPath)]); // Let's use Share.shareXFiles since SharePlus.instance.share might need different args, wait actually I'll change it to Share.shareXFiles, wait no, let's fix it properly.
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        data: (captures) {
          final capture = captures.firstWhere(
            (c) => c.id == widget.id,
            // If deleted, pop
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // Main Image with Hero
              Hero(
                tag: 'capture_${capture.id}',
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.file(
                    File(capture.localPath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Compare Overlay
              if (_isComparing && capture.poseId != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.network(
                        'https://storage.googleapis.com/posely-assets/mock/generated_${capture.poseId}_overlay.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

              // Bottom Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 16,
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Score display
                      if (capture.score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Match: ${(capture.score! * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (capture.score == null) const SizedBox(), // spacing

                      // Action Buttons
                      Row(
                        children: [
                          if (capture.poseId != null)
                            PoselyIconButton(
                              icon: _isComparing ? Icons.visibility_off : Icons.compare,
                              onPressed: () {
                                setState(() {
                                  _isComparing = !_isComparing;
                                });
                              },
                            ),
                          const SizedBox(width: 12),
                          PoselyIconButton(
                            icon: Icons.delete_outline,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: const Text('Delete Photo?', style: TextStyle(color: Colors.white)),
                                  content: const Text('This action cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                unawaited(ref.read(galleryControllerProvider.notifier).deleteCapture(widget.id));
                                if (context.mounted) context.pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
