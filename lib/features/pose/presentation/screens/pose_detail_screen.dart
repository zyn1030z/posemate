import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/shared/widgets/app_loading_view.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/camera/presentation/controllers/photoshoot_queue_controller.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/presentation/controllers/favorite_pose_ids_controller.dart';
import 'package:posely_ai/features/pose/presentation/controllers/pose_detail_controller.dart';
import 'package:posely_ai/features/pose/presentation/widgets/collection_picker_sheet.dart';
import 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';

/// Fallback copy for failures that are not typed AppException values.
const String _genericErrorMessage =
    'Something unexpected went wrong. Please try again.';

/// Formats a count compactly: 950 stays '950', 12400 becomes '12.4k',
/// and 3200000 becomes '3.2M'.
String _formatCompact(int count) {
  if (count >= 1000000) {
    return '${_trimTrailingZero(count / 1000000)}M';
  }
  if (count >= 1000) {
    return '${_trimTrailingZero(count / 1000)}k';
  }
  return '$count';
}

String _trimTrailingZero(double value) {
  final text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

/// Full-screen detail for a single pose: hero preview, stats, details,
/// tags, and the camera call-to-action.
class PoseDetailScreen extends ConsumerWidget {
  /// Creates the detail screen for the given pose id.
  const PoseDetailScreen({super.key, required this.poseId});

  /// Id of the pose to load and display.
  final String poseId;

  void _useThisPose(BuildContext context, WidgetRef ref, Pose pose, Set<String> queue) {
    // PoselyButton already fires the light tap haptic on press.
    unawaited(ref.read(poseRepositoryProvider).markUsed(pose));
    
    // Final queue includes the current pose if not already there, plus the user's photoshoot queue
    final finalQueue = {pose.id, ...queue}.toList();

    unawaited(context.push<Object?>(RoutePaths.cameraFor(finalQueue)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(poseDetailProvider(poseId));
    final pose = async.value;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const AppLoadingView(),
        error: (Object error, StackTrace stackTrace) => AppErrorView(
          message:
              error is AppException ? error.userMessage : _genericErrorMessage,
          onRetry: () => ref.invalidate(poseDetailProvider(poseId)),
        ),
        data: (Pose pose) => _PoseDetailBody(pose: pose),
      ),
      bottomNavigationBar: pose == null
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final queue = ref.watch(photoshootQueueProvider);
                  final isInQueue = queue.contains(pose.id);
                  final totalCount = queue.length + (isInQueue ? 0 : 1);

                  return Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: PoselyButton(
                          label: 'Try this pose ($totalCount)',
                          icon: Icons.photo_camera_rounded,
                          expand: true,
                          onPressed: () => _useThisPose(context, ref, pose, queue),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: PoselyButton(
                          label: isInQueue ? 'Remove' : 'Add to Queue',
                          icon: isInQueue ? Icons.playlist_remove_rounded : Icons.playlist_add_rounded,
                          variant: isInQueue ? PoselyButtonVariant.glass : PoselyButtonVariant.ghost,
                          expand: true,
                          onPressed: () {
                            ref.read(photoshootQueueProvider.notifier).toggle(pose.id);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

/// Scrollable detail content below the hero image.
class _PoseDetailBody extends StatelessWidget {
  const _PoseDetailBody({required this.pose});

  final Pose pose;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _PoseHero(pose: pose)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _NameRow(pose: pose),
                const SizedBox(height: AppSpacing.lg),
                _StatRow(pose: pose),
                const SizedBox(height: AppSpacing.sectionGap),
                const SectionHeader(title: 'Details'),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    PoselyChip(label: pose.gender.label),
                    PoselyChip(label: pose.bodyDirection),
                    PoselyChip(label: pose.cameraAngle),
                  ],
                ),
                if (pose.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sectionGap),
                  const SectionHeader(title: 'Tags'),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final tag in pose.tags) PoselyChip(label: '#$tag'),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final queue = ref.watch(photoshootQueueProvider);
                      final isInQueue = queue.contains(pose.id);
                      final totalCount = queue.length + (isInQueue ? 0 : 1);
                      return ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: Text('Try this Pose ($totalCount)'),
                        onPressed: () {
                          // Manually call markUsed here since we bypass _useThisPose
                          unawaited(ref.read(poseRepositoryProvider).markUsed(pose));
                          final finalQueue = {pose.id, ...queue}.toList();
                          context.push(RoutePaths.cameraFor(finalQueue));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width 4:5 hero preview with floating back and heart discs.
class _PoseHero extends ConsumerWidget {
  const _PoseHero({required this.pose});

  final Pose pose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.paddingOf(context).top;
    final isFavorite = ref.watch(
      favoritePoseIdsProvider.select(
        (favorites) => favorites.value?.contains(pose.id) ?? false,
      ),
    );
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: PosePreviewImage(imageUrl: pose.previewUrl),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.darkVeil),
            ),
          ),
          Positioned(
            top: topInset + AppSpacing.sm,
            left: AppSpacing.lg,
            child: PoselyIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 18,
              onPressed: () => context.pop(),
              semanticLabel: 'Back',
            ),
          ),
          Positioned(
            top: topInset + AppSpacing.sm,
            right: AppSpacing.lg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PoselyIconButton(
                  icon: Icons.bookmark_add_outlined,
                  onPressed: () => unawaited(
                    showCollectionPicker(
                      context: context,
                      poseId: pose.id,
                    ),
                  ),
                  semanticLabel: 'Save to collection',
                ),
                const SizedBox(width: AppSpacing.sm),
                PoselyIconButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  active: isFavorite,
                  onPressed: () => unawaited(
                    ref
                        .read(favoritePoseIdsProvider.notifier)
                        .toggle(pose.id),
                  ),
                  semanticLabel: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pose name beside an optional premium pill.
class _NameRow extends StatelessWidget {
  const _NameRow({required this.pose});

  final Pose pose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(pose.name, style: AppTypography.screenTitle),
        ),
        if (pose.isPremium) ...<Widget>[
          const SizedBox(width: AppSpacing.md),
          const _PremiumPill(),
        ],
      ],
    );
  }
}

/// Amber glass pill marking a premium pose.
class _PremiumPill extends StatelessWidget {
  const _PremiumPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Premium',
            style: AppTypography.caption.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three glass stat cards: AI score, downloads, and difficulty.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.pose});

  final Pose pose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.warning,
            value: pose.aiScore.toStringAsFixed(1),
            label: 'AI Score',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.download_rounded,
            iconColor: AppColors.primary,
            value: _formatCompact(pose.downloads),
            label: 'Downloads',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.info,
            value: pose.difficulty.label,
            label: 'Difficulty',
          ),
        ),
      ],
    );
  }
}

/// One glass stat card: icon, value, and muted label.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.cardTitle,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
