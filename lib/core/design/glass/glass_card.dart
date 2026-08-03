import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// A card surface with soft elevation and subtle border.
///
/// Applies the shared card padding, floats on a soft resting shadow,
/// and becomes tappable with radius-aware ink feedback and a light
/// haptic when an on-tap callback is provided.
class GlassCard extends StatelessWidget {
  /// Creates a card surface around the given child.
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.tint,
  });

  /// Content rendered inside the card.
  final Widget child;

  /// Inner padding around the child. Defaults to
  /// [AppSpacing.cardPadding].
  final EdgeInsetsGeometry? padding;

  /// Corner rounding of the card. Defaults to [AppRadius.brXl].
  final BorderRadius? borderRadius;

  /// Called when the card is tapped. When null the card is static.
  final VoidCallback? onTap;

  /// Overrides the default surface fill color.
  final Color? tint;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.brXl;

    Widget content = Padding(
      padding: padding ?? AppSpacing.cardPadding,
      child: child,
    );
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        boxShadow: AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
