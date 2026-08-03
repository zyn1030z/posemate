import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';

// Minimum tap target extent required for accessibility.
const double _minTapTarget = 44;

/// A circular frosted-glass icon button.
///
/// Renders the icon on a glass disc with a hairline stroke. The active
/// state tints the disc blue, colors the icon with the brand
/// primary, and adds a faint glow. The tappable area never shrinks
/// below 44 by 44 logical pixels, even for smaller disc sizes.
class PoselyIconButton extends StatelessWidget {
  /// Creates a circular glass icon button.
  const PoselyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.active = false,
    this.semanticLabel,
  });

  /// Icon rendered at the center of the disc.
  final IconData icon;

  /// Called on tap. When null the button renders disabled.
  final VoidCallback? onPressed;

  /// Diameter of the glass disc in logical pixels.
  final double size;

  /// Size of the icon in logical pixels.
  final double iconSize;

  /// Whether the button renders in its blue active state.
  final bool active;

  /// Accessibility label, also shown as a long-press tooltip.
  final String? semanticLabel;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    final enabled = onPressed != null;
    final targetSize = math.max(size, _minTapTarget);

    final disc = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.primary.withValues(alpha: 0.15)
            : colors.glassSurface,
        border: Border.all(color: colors.glassStroke),
        boxShadow: active
            ? <BoxShadow>[BoxShadow(color: colors.glow, blurRadius: 14)]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: active ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );

    Widget result = SizedBox(
      width: targetSize,
      height: targetSize,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? _handleTap : null,
          customBorder: const CircleBorder(),
          child: Center(child: disc),
        ),
      ),
    );

    if (!enabled) {
      result = Opacity(opacity: 0.4, child: result);
    }
    if (semanticLabel != null) {
      result = Tooltip(
        message: semanticLabel,
        excludeFromSemantics: true,
        child: result,
      );
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: result,
    );
  }
}
