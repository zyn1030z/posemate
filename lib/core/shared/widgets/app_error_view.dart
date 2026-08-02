import 'package:flutter/material.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Centered branded error state: a danger-tinted glass circle with an
/// error icon, a title, a message, and an optional retry action.
///
/// Shares the empty-state geometry and its gentle one-shot
/// fade-and-rise entrance, skipped under reduced motion.
class AppErrorView extends StatelessWidget {
  /// Creates an error view with the given message and optional retry.
  const AppErrorView({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
  });

  /// Short headline for the error state.
  final String title;

  /// Human-readable explanation shown in muted text.
  final String message;

  /// When provided, renders a 'Try again' button invoking this callback.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
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
                    color: posely.danger.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: posely.glassStroke),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 32,
                    color: posely.danger,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  style: AppTypography.cardTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: AppTypography.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
