import 'package:flutter/material.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Compact glass pill showing a labeled AI sub-score.
///
/// A small score-colored dot, a muted label, and the percentage in
/// tabular figures tinted by the score color. Used in the camera AI
/// panel rows.
class ScorePill extends StatelessWidget {
  /// Creates a score pill for a normalized score.
  const ScorePill({
    super.key,
    required this.label,
    required this.score,
  }) : assert(
          score >= 0.0 && score <= 1.0,
          'score must be between 0.0 and 1.0',
        );

  /// Short name of the scored aspect, such as 'Framing'.
  final String label;

  /// Normalized score between 0.0 and 1.0.
  final double score;

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final color = AppColors.forScore(score);
    final percent = (score * 100).round();
    return Semantics(
      container: true,
      label: '$label $percent percent',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: posely.glassSurface,
            borderRadius: AppRadius.brPill,
            border: Border.all(color: posely.glassStroke),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 8, height: 8),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$percent%',
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
