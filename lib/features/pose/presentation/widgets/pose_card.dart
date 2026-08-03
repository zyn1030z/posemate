import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/services/haptics/haptic_service.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/presentation/controllers/favorite_pose_ids_controller.dart';

/// The canonical pose tile shared by the library grid and home rails.
///
/// A portrait 3:4 photo card: cached preview image under a dark veil
/// carrying the pose name, a difficulty micro-chip, and the AI score.
/// A crown badge marks premium poses and an optional heart toggles the
/// pose in the shared favorites set.
class PoseCard extends ConsumerWidget {
  /// Creates a pose card for the given pose.
  const PoseCard({
    super.key,
    required this.pose,
    this.onTap,
    this.width,
    this.showFavorite = true,
  });

  /// When true, network images are skipped entirely and the branded
  /// fallback renders in their place. Tests set this so widget pumps
  /// never touch the network or leave shimmer placeholders animating.
  static bool debugForcePlaceholder = false;

  /// The pose rendered on this card.
  final Pose pose;

  /// Called when the card body is tapped. The heart never triggers it.
  final VoidCallback? onTap;

  /// Optional fixed width, for horizontal rails; null fills the parent.
  final double? width;

  /// Whether the favorite heart is shown in the top-right corner.
  final bool showFavorite;

  void _handleCardTap(WidgetRef ref) {
    unawaited(ref.read(hapticServiceProvider).light());
    onTap?.call();
  }

  void _handleHeartTap(WidgetRef ref) {
    unawaited(ref.read(hapticServiceProvider).light());
    unawaited(ref.read(favoritePoseIdsProvider.notifier).toggle(pose.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritePoseIdsProvider.select(
        (favorites) => favorites.value?.contains(pose.id) ?? false,
      ),
    );

    Widget card = AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: AppRadius.brXl,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            RepaintBoundary(
              child: PosePreviewImage(imageUrl: pose.previewUrl),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _CardVeil(pose: pose),
            ),
            if (pose.isPremium)
              const Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _PremiumBadge(),
              ),
            if (showFavorite)
              Positioned(
                top: AppSpacing.xxs,
                right: AppSpacing.xxs,
                child: _FavoriteHeartButton(
                  isFavorite: isFavorite,
                  onPressed: () => _handleHeartTap(ref),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleCardTap(ref),
        child: card,
      );
    }
    if (width != null) {
      card = SizedBox(width: width, child: card);
    }
    return card;
  }
}

/// The pose preview photo with the shared branded fallback.
///
/// Wraps CachedNetworkImage with a shimmer placeholder and an
/// emerald-tinted fallback for load errors. Honors the
/// PoseCard.debugForcePlaceholder test switch by skipping the network
/// image entirely. Reused by the pose detail hero so every pose photo
/// fails identically.
class PosePreviewImage extends StatelessWidget {
  /// Creates a pose preview image for the given URL.
  const PosePreviewImage({super.key, required this.imageUrl});

  /// The preview image URL, rendered with cover fit.
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (PoseCard.debugForcePlaceholder) {
      return const _PoseImageFallback();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          const ShimmerBox(borderRadius: BorderRadius.zero),
      errorWidget: (context, url, error) => const _PoseImageFallback(),
    );
  }
}

/// Branded stand-in when a pose photo cannot render: an emerald-tinted
/// dark gradient with a faint pose-figure watermark.
class _PoseImageFallback extends StatelessWidget {
  const _PoseImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.blue900, AppColors.background],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.accessibility_new_rounded,
          size: 48,
          color: AppColors.emerald400.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Bottom veil with the pose name, difficulty chip, and AI score.
class _CardVeil extends StatelessWidget {
  const _CardVeil({required this.pose});

  final Pose pose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.darkVeil),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxl,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              pose.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 15,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                _DifficultyMicroChip(difficulty: pose.difficulty),
                const Spacer(),
                const Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  pose.aiScore.toStringAsFixed(1),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny glass pill carrying the difficulty label.
class _DifficultyMicroChip extends StatelessWidget {
  const _DifficultyMicroChip({required this.difficulty});

  final PoseDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.glassStrong,
        borderRadius: AppRadius.brPill,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.glassStroke),
        ),
      ),
      child: Text(
        difficulty.label,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

/// Amber-tinted 24-pixel glass disc marking a premium pose.
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Premium pose',
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.5),
          ),
        ),
        child: const Icon(
          Icons.workspace_premium_rounded,
          size: 14,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

/// 32-pixel scrim disc heart inside a 44-pixel tap target.
///
/// Pops with a brief scale-up whenever the favorite state flips, then
/// settles back to rest.
class _FavoriteHeartButton extends StatefulWidget {
  const _FavoriteHeartButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  State<_FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<_FavoriteHeartButton> {
  double _scale = 1;

  @override
  void didUpdateWidget(covariant _FavoriteHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() => _scale = 1.25);
    }
  }

  void _handleAnimationEnd() {
    if (_scale != 1) {
      setState(() => _scale = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: widget.isFavorite,
      label: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.scrim,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.glassStroke),
                ),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: _scale,
                  duration: AppDurations.fast,
                  curve: AppDurations.spring,
                  onEnd: _handleAnimationEnd,
                  child: Icon(
                    widget.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: widget.isFavorite
                        ? AppColors.primary
                        : Colors.white,
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
