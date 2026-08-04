import 'package:flutter/material.dart';

import 'package:posely_ai/core/design/skeleton/shimmer_box.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// Loading placeholder shaped like a pose card.
///
/// A tall shimmering panel with a darkened bottom veil carrying two
/// short shimmer lines where the pose title and meta text will appear.
class PoseCardSkeleton extends StatelessWidget {
  /// Creates a pose card skeleton with the given aspect ratio.
  const PoseCardSkeleton({super.key, this.aspectRatio = 3 / 4});

  /// Width-to-height ratio of the card; portrait 3:4 by default.
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: const Stack(
        children: <Widget>[
          Positioned.fill(child: ShimmerBox(borderRadius: AppRadius.brXl)),
          // Darkened veil so the text-line shimmer reads against the
          // base panel, mirroring the real card's photo overlay.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 96,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.darkVeil,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xl),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.6,
                  child: ShimmerBox(height: 12, borderRadius: AppRadius.brSm),
                ),
                SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.35,
                  child: ShimmerBox(height: 10, borderRadius: AppRadius.brSm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
