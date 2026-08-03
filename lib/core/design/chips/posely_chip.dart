import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// A selectable pill chip for filters and pose categories.
///
/// Animates between a frosted glass resting state and a blue-tinted
/// selected state. The visible pill is 36 logical pixels tall, and
/// built-in vertical padding extends the tappable area to 44 logical
/// pixels. Fires a selection-click haptic on tap.
class PoselyChip extends StatelessWidget {
  /// Creates a Posely filter chip.
  const PoselyChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  /// Text shown inside the chip.
  final String label;

  /// Whether the chip renders in its blue selected state.
  final bool selected;

  /// Called on tap. When null the chip is static.
  final VoidCallback? onTap;

  /// Optional 16 pixel icon rendered before the label.
  final IconData? icon;

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    final foreground = selected ? AppColors.primary : AppColors.textPrimary;

    final chip = AnimatedContainer(
      duration: AppDurations.base,
      curve: AppDurations.easeOutExpo,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.18)
            : colors.glassSurface,
        borderRadius: AppRadius.brPill,
        border: Border.all(
          color: selected ? AppColors.primary : colors.glassStroke,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.sm),
          ],
          AnimatedDefaultTextStyle(
            duration: AppDurations.base,
            curve: AppDurations.easeOutExpo,
            style: AppTypography.caption.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ],
      ),
    );

    Widget result = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: chip,
    );
    if (onTap != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: result,
      );
    }

    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        selected: selected,
        child: result,
      ),
    );
  }
}
