import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

// Minimum tap target extent required for accessibility.
const double _minTapTarget = 44;

/// Visual style of a [PoselyButton].
enum PoselyButtonVariant {
  /// Blue hero gradient fill with a soft glow shadow.
  primary,

  /// Frosted glass fill with a hairline glass stroke.
  glass,

  /// Transparent fill with secondary text, turning blue on press.
  ghost,

  /// Destructive style with a translucent rose fill and rose stroke.
  danger,
}

/// Size preset of a [PoselyButton].
enum PoselyButtonSize {
  /// 52 logical pixels tall — hero and screen-level actions.
  large,

  /// 44 logical pixels tall — standard inline actions.
  medium,

  /// 36 logical pixels tall — compact and secondary actions.
  small,
}

/// The Posely pill button.
///
/// Renders one of four variants at one of three sizes, scales down
/// slightly while pressed, fires a light haptic on tap, and swaps its
/// label for a spinner while loading. A null on-pressed callback shows
/// the dimmed disabled state and blocks interaction.
class PoselyButton extends StatefulWidget {
  /// Creates a Posely pill button.
  const PoselyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PoselyButtonVariant.primary,
    this.size = PoselyButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  /// Text shown inside the button, also used as the semantic label.
  final String label;

  /// Called on tap. When null the button renders disabled.
  final VoidCallback? onPressed;

  /// Visual style of the button.
  final PoselyButtonVariant variant;

  /// Size preset of the button.
  final PoselyButtonSize size;

  /// Optional 18 pixel icon rendered before the label.
  final IconData? icon;

  /// Whether to show a spinner instead of the label and block taps.
  final bool loading;

  /// Whether the button stretches to the full available width.
  final bool expand;

  @override
  State<PoselyButton> createState() => _PoselyButtonState();
}

class _PoselyButtonState extends State<PoselyButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  double get _height => switch (widget.size) {
        PoselyButtonSize.large => 52,
        PoselyButtonSize.medium => 44,
        PoselyButtonSize.small => 36,
      };

  double get _horizontalPadding => switch (widget.size) {
        PoselyButtonSize.large => AppSpacing.xl,
        PoselyButtonSize.medium => AppSpacing.lg,
        PoselyButtonSize.small => AppSpacing.md,
      };

  double get _fontSize => switch (widget.size) {
        PoselyButtonSize.large => 16,
        PoselyButtonSize.medium => 15,
        PoselyButtonSize.small => 14,
      };

  Color _foreground(PoselyColors colors) {
    return switch (widget.variant) {
      PoselyButtonVariant.primary => AppColors.textOnPrimary,
      PoselyButtonVariant.glass => AppColors.textPrimary,
      PoselyButtonVariant.ghost =>
        _pressed ? AppColors.primary : AppColors.textSecondary,
      PoselyButtonVariant.danger => colors.danger,
    };
  }

  BoxDecoration _decoration(PoselyColors colors) {
    return switch (widget.variant) {
      PoselyButtonVariant.primary => BoxDecoration(
          gradient: AppGradients.blueHero,
          borderRadius: AppRadius.brPill,
          boxShadow: widget.onPressed != null ? AppShadows.blueGlow : null,
        ),
      PoselyButtonVariant.glass => BoxDecoration(
          color: colors.glassSurface,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: colors.glassStroke),
        ),
      PoselyButtonVariant.ghost => const BoxDecoration(
          borderRadius: AppRadius.brPill,
        ),
      PoselyButtonVariant.danger => BoxDecoration(
          color: colors.danger.withValues(alpha: 0.12),
          borderRadius: AppRadius.brPill,
          border: Border.all(color: colors.danger),
        ),
    };
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_enabled) {
      return;
    }
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_pressed) {
      return;
    }
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    if (!_pressed) {
      return;
    }
    setState(() => _pressed = false);
  }

  void _handleTap() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    final foreground = _foreground(colors);

    final Widget inner;
    if (widget.loading) {
      inner = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    } else {
      inner = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.icon != null) ...<Widget>[
            Icon(widget.icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: AppTypography.button.copyWith(
                fontSize: _fontSize,
                color: foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    Widget pill = Container(
      height: _height,
      width: widget.expand ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      decoration: _decoration(colors),
      child: Center(
        widthFactor: 1,
        child: AnimatedSize(
          duration: AppDurations.base,
          curve: AppDurations.easeOutExpo,
          child: inner,
        ),
      ),
    );

    pill = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: AppDurations.fast,
      curve: AppDurations.easeOutExpo,
      child: pill,
    );

    if (widget.onPressed == null) {
      pill = Opacity(opacity: 0.4, child: pill);
    }

    final verticalHitPadding =
        _height >= _minTapTarget ? 0.0 : (_minTapTarget - _height) / 2;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      onTap: _enabled ? _handleTap : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalHitPadding),
          child: pill,
        ),
      ),
    );
  }
}
