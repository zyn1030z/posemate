import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Header row for a content section within a screen.
///
/// A section title on the left and an optional trailing action in the
/// 'See all' pattern: an emerald label with a small chevron, a 44-pixel
/// minimum tap target, and a selection haptic on tap.
class SectionHeader extends StatelessWidget {
  /// Creates a section header with the given title.
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  /// Section heading text.
  final String title;

  /// Optional trailing action label, such as 'See all'.
  final String? actionLabel;

  /// Invoked when the trailing action is tapped.
  final VoidCallback? onAction;

  void _handleAction() {
    unawaited(HapticFeedback.selectionClick());
    onAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: AppTypography.sectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null)
          MergeSemantics(
            child: Semantics(
              button: true,
              child: GestureDetector(
                onTap: _handleAction,
                behavior: HitTestBehavior.opaque,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        actionLabel!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      const Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
