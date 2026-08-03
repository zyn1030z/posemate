import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/pose/pose.dart';

/// A titled horizontal rail of pose cards.
///
/// Renders a section header followed by a 200-pixel bouncing horizontal
/// list of pose cards; tapping a card pushes that pose's detail route.
/// When the list is empty and an empty hint is provided, a slim glass
/// hint row takes the list's place instead.
class PoseRail extends StatelessWidget {
  /// Creates a pose rail with the given title and poses.
  const PoseRail({
    super.key,
    required this.title,
    required this.poses,
    this.onSeeAll,
    this.cardWidth = 150,
    this.emptyHint,
  });

  /// Section heading shown above the rail.
  final String title;

  /// Poses rendered as cards, in order.
  final List<Pose> poses;

  /// When provided, the header shows a 'See all' action invoking this.
  final VoidCallback? onSeeAll;

  /// Width of each pose card in logical pixels.
  final double cardWidth;

  /// Caption rendered in a slim glass row when the rail is empty.
  final String? emptyHint;

  /// Height of the horizontal card list.
  static const double _railHeight = 200;

  /// Height of the slim glass hint row shown when the rail is empty.
  static const double _hintHeight = 64;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: title,
            actionLabel: onSeeAll != null ? 'See all' : null,
            onAction: onSeeAll,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (poses.isEmpty && emptyHint != null)
          _buildEmptyHint(context)
        else if (poses.isNotEmpty)
          _buildList(),
      ],
    );
  }

  Widget _buildEmptyHint(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: SizedBox(
        height: _hintHeight,
        width: double.infinity,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: Text(
              emptyHint!,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return SizedBox(
      height: _railHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.screenPadding,
        itemCount: poses.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final pose = poses[index];
          return PoseCard(
            pose: pose,
            width: cardWidth,
            onTap: () => context.push(RoutePaths.poseDetailFor(pose.id)),
          );
        },
      ),
    );
  }
}
