import 'package:flutter/material.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:shimmer/shimmer.dart';

/// A rounded shimmering placeholder block.
///
/// The building brick for all skeleton layouts: an elevated-surface box
/// swept by a soft white highlight on the shared shimmer cadence.
class ShimmerBox extends StatelessWidget {
  /// Creates a shimmer placeholder, optionally sized and rounded.
  const ShimmerBox({super.key, this.width, this.height, this.borderRadius});

  /// Fixed width; when null the box sizes to its parent constraints.
  final double? width;

  /// Fixed height; when null the box sizes to its parent constraints.
  final double? height;

  /// Corner rounding; defaults to the medium radius token.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    // The highlight is white at ten percent composited over the base so
    // the sweep stays a subtle glass sheen instead of a hard flash.
    final highlight = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.10),
      AppColors.surfaceElevated,
    );
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: highlight,
      period: AppDurations.shimmer,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: borderRadius ?? AppRadius.brMd,
        ),
      ),
    );
  }
}
