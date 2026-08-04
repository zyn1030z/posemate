import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Branded placeholder for tabs and routes whose feature has not
/// shipped yet.
///
/// Renders the dark aurora backdrop with an emerald glass icon badge,
/// the screen title, an "arrives in" phase pill, and a muted teaser
/// line, all entering with a gentle staggered animation. When pushed as
/// a full-screen route a glass back button appears so the screen never
/// traps the user.
class ComingSoonScreen extends StatelessWidget {
  /// Creates a coming-soon placeholder screen.
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.phase,
    this.icon,
  });

  /// Diameter of the emerald glass icon badge.
  static const double _badgeSize = 88;

  /// Headline naming the future experience.
  final String title;

  /// Rollout phase label shown inside the pill, such as 'Phase 8'.
  final String phase;

  /// Badge icon; defaults to a sparkle when omitted.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient emerald aurora, matching the splash backdrop.
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.backgroundAurora),
          ),
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                          width: _badgeSize,
                          height: _badgeSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            border: Border.all(
                              color: AppColors.emerald400.withValues(
                                alpha: 0.35,
                              ),
                            ),
                            boxShadow: AppShadows.emeraldGlow,
                          ),
                          child: Icon(
                            icon ?? Icons.auto_awesome_rounded,
                            size: 40,
                            color: AppColors.emerald400,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: AppDurations.slow,
                          curve: AppDurations.easeOutExpo,
                        )
                        .fadeIn(duration: AppDurations.base),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                          title,
                          style: AppTypography.screenTitle,
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(
                          delay: AppDurations.fast,
                          duration: AppDurations.base,
                        )
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          delay: AppDurations.fast,
                          duration: AppDurations.slow,
                          curve: AppDurations.easeOutExpo,
                        ),
                    const SizedBox(height: AppSpacing.md),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brPill,
                        border: Border.all(
                          color: AppColors.emerald400.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + AppSpacing.xxs,
                        ),
                        child: Text(
                          'Arrives in $phase'.toUpperCase(),
                          style: AppTypography.overline.copyWith(
                            color: AppColors.emerald400,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: AppDurations.base,
                      duration: AppDurations.base,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'We are crafting this experience right now.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: posely.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      delay: AppDurations.slow,
                      duration: AppDurations.base,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back affordance only when pushed full-screen over the shell;
          // tab-hosted instances sit at the root of their branch stack.
          if (canPop)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  top: AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: PoselyIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                  ).animate().fadeIn(duration: AppDurations.base),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
