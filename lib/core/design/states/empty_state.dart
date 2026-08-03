import 'package:flutter/material.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Centered empty state: an emerald-tinted glass circle with an icon,
/// a title, an optional supporting message, and an optional action.
///
/// Enters with a gentle one-shot fade-and-rise which is skipped when
/// the platform requests reduced motion.
class EmptyState extends StatelessWidget {
  /// Creates an empty state with the given title.
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  /// Short headline describing the empty situation.
  final String title;

  /// Optional supporting copy shown in muted text below the title.
  final String? message;

  /// Icon shown inside the glass circle. Defaults to a sparkle.
  final IconData? icon;

  /// Optional call-to-action widget rendered below the copy.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: reducedMotion ? Duration.zero : AppDurations.slow,
          curve: AppDurations.easeOutExpo,
          builder: (context, t, child) {
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - t)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: posely.glassStroke),
                ),
                child: Icon(
                  icon ?? Icons.auto_awesome_outlined,
                  size: 32,
                  color: AppColors.emerald400,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.cardTitle,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: AppTypography.bodyMuted.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
