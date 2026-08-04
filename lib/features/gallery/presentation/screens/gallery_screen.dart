import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/features/gallery/domain/entities/capture_record.dart';
import 'package:posely_ai/features/gallery/presentation/controllers/gallery_controller.dart';

/// The main gallery tab displaying local captures in a grid.
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppColors.background.withOpacity(0.5),
              elevation: 0,
              title: const Text(
                'Gallery',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: state.when(
        data: (captures) {
          if (captures.isEmpty) {
            return const Center(
              child: Text(
                'No captures yet.\nStart posing to fill your gallery!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(galleryControllerProvider.notifier).refresh(),
            child: GridView.builder(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
                bottom: MediaQuery.paddingOf(context).bottom + 80, // Space for bottom nav
                left: 16,
                right: 16,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: captures.length,
              itemBuilder: (context, index) {
                final capture = captures[index];
                return _GalleryItem(capture: capture);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Failed to load gallery:\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  const _GalleryItem({required this.capture});

  final CaptureRecord capture;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteNames.captureDetail,
          pathParameters: {'id': capture.id},
          extra: capture,
        );
      },
      child: Hero(
        tag: 'capture_${capture.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
            image: DecorationImage(
              image: FileImage(File(capture.localPath)),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              if (!capture.isSynced)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.white70),
                ),
              if (capture.score != null)
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(capture.score! * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
