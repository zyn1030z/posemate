import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_blur.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Maximum width of the dialog card on wide screens.
const double _dialogMaxWidth = 400;

/// Diameter of the optional leading icon circle.
const double _iconCircleSize = 56;

/// One action button rendered at the bottom of a Posely dialog.
///
/// When [onDialogTap] is null the action simply pops the dialog route.
/// Otherwise the callback receives the dialog's own context so it can
/// pop with a result, for example
/// `Navigator.of(dialogContext).pop(true)`.
class PoselyDialogAction {
  /// Creates a dialog action.
  const PoselyDialogAction({
    required this.label,
    this.onDialogTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  /// Text shown on the action button.
  final String label;

  /// Tap handler receiving the dialog context; null means just pop.
  final void Function(BuildContext dialogContext)? onDialogTap;

  /// Whether this action renders as the filled emerald pill.
  final bool isPrimary;

  /// Whether this action renders in the danger tint.
  final bool isDestructive;
}

/// Shows the Posely dialog and returns the value the route pops with.
///
/// Built on [showGeneralDialog] with a blurred barrier: the scrim color
/// plus a backdrop blur that eases up to [AppBlur.soft]. The card
/// scales from 0.94 to 1 while fading in over [AppDurations.base] with
/// an ease-out-expo curve.
///
/// The card sits on the elevated surface with [AppRadius.brXl] corners
/// and a high shadow. An optional [icon] renders inside an
/// emerald-tinted circle above the centered [title] and [message], and
/// [actions] stack full-width below — primary as a filled emerald pill,
/// destructive in the danger tint, and the rest as ghost buttons. Every
/// action fires a light haptic before running its handler or popping.
Future<T?> showPoselyDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  IconData? icon,
  List<PoselyDialogAction> actions = const <PoselyDialogAction>[],
  bool barrierDismissible = true,
}) {
  final colors = Theme.of(context).extension<PoselyColors>()!;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: colors.scrim,
    transitionDuration: AppDurations.base,
    pageBuilder: (
      BuildContext dialogContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return _PoselyDialogCard(
        title: title,
        message: message,
        icon: icon,
        actions: actions,
      );
    },
    transitionBuilder: (
      BuildContext dialogContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppDurations.easeOutExpo,
      );
      return BackdropFilter(
        filter: AppBlur.glassFilter(AppBlur.soft * curved.value),
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Shows a two-action confirmation dialog and resolves to a decision.
///
/// Returns true when the confirm action is tapped and false when the
/// cancel action is tapped or the dialog is dismissed any other way,
/// such as a barrier tap — it never resolves to null. Set [destructive]
/// to render the confirm action in the danger tint.
Future<bool> showPoselyConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showPoselyDialog<bool>(
    context: context,
    title: title,
    message: message,
    actions: <PoselyDialogAction>[
      PoselyDialogAction(
        label: confirmLabel,
        isPrimary: true,
        isDestructive: destructive,
        onDialogTap: (BuildContext dialogContext) =>
            Navigator.of(dialogContext).pop(true),
      ),
      PoselyDialogAction(
        label: cancelLabel,
        onDialogTap: (BuildContext dialogContext) =>
            Navigator.of(dialogContext).pop(false),
      ),
    ],
  );
  return result ?? false;
}

/// Elevated glass card hosting the dialog content and actions.
class _PoselyDialogCard extends StatelessWidget {
  const _PoselyDialogCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.actions,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final List<PoselyDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PoselyColors>()!;
    final scheme = theme.colorScheme;
    final message = this.message;
    final icon = this.icon;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
            child: Semantics(
              container: true,
              namesRoute: true,
              label: title,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: AppRadius.brXl,
                  boxShadow: AppShadows.high,
                ),
                child: Material(
                  color: scheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.brXl,
                    side: BorderSide(color: colors.glassStroke),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (icon != null) ...<Widget>[
                          Center(
                            child: Container(
                              width: _iconCircleSize,
                              height: _iconCircleSize,
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                size: 28,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.cardTitle.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        if (message != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMuted.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (actions.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.xxl),
                          for (var i = 0; i < actions.length; i++) ...<Widget>[
                            if (i > 0) const SizedBox(height: AppSpacing.sm),
                            _PoselyDialogActionButton(action: actions[i]),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders one dialog action in its primary, destructive, or ghost
/// styling and wires up haptics plus the default pop behavior.
class _PoselyDialogActionButton extends StatelessWidget {
  const _PoselyDialogActionButton({required this.action});

  final PoselyDialogAction action;

  void _handleTap(BuildContext context) {
    unawaited(HapticFeedback.lightImpact());
    final onDialogTap = action.onDialogTap;
    if (onDialogTap != null) {
      onDialogTap(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PoselyColors>()!;
    final scheme = theme.colorScheme;

    if (action.isPrimary && action.isDestructive) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colors.danger,
          foregroundColor: scheme.onError,
        ),
        onPressed: () => _handleTap(context),
        child: Text(action.label),
      );
    }
    if (action.isPrimary) {
      return FilledButton(
        onPressed: () => _handleTap(context),
        child: Text(action.label),
      );
    }
    if (action.isDestructive) {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: colors.danger,
          backgroundColor: colors.danger.withValues(alpha: 0.12),
        ),
        onPressed: () => _handleTap(context),
        child: Text(action.label),
      );
    }
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
      onPressed: () => _handleTap(context),
      child: Text(action.label),
    );
  }
}
