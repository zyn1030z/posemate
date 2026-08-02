import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/design/glass/glass_panel.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// A [GlassPanel] dressed as a content card.
///
/// Applies the shared card padding, floats on a soft resting shadow,
/// and becomes tappable with radius-aware ink feedback and a light
/// haptic when an on-tap callback is provided.
class GlassCard extends StatelessWidget {
  /// Creates a glass card around the given child.
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

  /// Overrides the frosted glass fill color.
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
        borderRadius: radius,
        boxShadow: AppShadows.soft,
      ),
      child: GlassPanel(
        borderRadius: radius,
        tint: tint,
        child: content,
      ),
    );
  }
}
