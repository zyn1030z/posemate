import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/features/pose/pose.dart';

/// A horizontally scrolling row of category chips for the Home screen.
///
/// Shows up to eight categories as unselected chips — each labelled with
/// its emoji and name — plus a trailing 'All' chip. Every chip opens the
/// pose library.
class CategoryQuickRow extends StatelessWidget {
  /// Creates a quick row for the given categories.
  const CategoryQuickRow({super.key, required this.categories});

  /// Categories to render; only the first eight are shown.
  final List<PoseCategory> categories;

  /// Maximum number of category chips rendered before the 'All' chip.
  static const int _maxChips = 8;

  void _openLibrary(BuildContext context) {
    // PHASE-5: deep-link category selection via query param.
    context.push(RoutePaths.poseLibrary);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding,
      child: Row(
        children: <Widget>[
          for (final category in categories.take(_maxChips)) ...<Widget>[
            PoselyChip(
              label: '${category.emoji} ${category.name}',
              onTap: () => _openLibrary(context),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          PoselyChip(
            label: 'All →',
            onTap: () => _openLibrary(context),
          ),
        ],
      ),
    );
  }
}
