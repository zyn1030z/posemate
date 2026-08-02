import 'package:flutter/material.dart';

import 'package:posely_ai/core/design/skeleton/pose_card_skeleton.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// A non-scrollable grid of pose card skeletons.
///
/// Designed to sit inside an existing scroll view while a gallery or
/// feed loads: it shrink-wraps and never scrolls on its own.
class SkeletonGrid extends StatelessWidget {
  /// Creates a skeleton grid.
  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.aspectRatio = 3 / 4,
  });

  /// Number of skeleton cards to render.
  final int itemCount;

  /// Number of columns in the grid.
  final int crossAxisCount;

  /// Width-to-height ratio of each card; portrait 3:4 by default.
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return PoseCardSkeleton(aspectRatio: aspectRatio);
      },
    );
  }
}
