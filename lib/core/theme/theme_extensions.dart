import 'package:flutter/material.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';

/// Theme-dependent Posely color tokens, resolved per brightness.
///
/// Attach an instance to ThemeData through its extensions list and read
/// it back with Theme.of, so glass surfaces, glows, and semantic colors
/// adapt automatically when the brightness changes.
class PoselyColors extends ThemeExtension<PoselyColors> {
  /// Creates a fully specified Posely color set.
  const PoselyColors({
    required this.glassSurface,
    required this.glassStroke,
    required this.glow,
    required this.scrim,
    required this.textMuted,
    required this.cardSurface,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  /// Flagship dark values — white glass over deep slate.
  const PoselyColors.dark()
      : glassSurface = AppColors.glassWhite,
        glassStroke = AppColors.glassStroke,
        glow = const Color(0x5910B981),
        scrim = AppColors.scrim,
        textMuted = AppColors.textTertiary,
        cardSurface = AppColors.surface,
        success = AppColors.success,
        warning = AppColors.warning,
        danger = AppColors.error,
        info = AppColors.info;

  /// Light values — slate glass over near-white surfaces, with
  /// semantic colors darkened for contrast.
  const PoselyColors.light()
      : glassSurface = AppColors.glassDark,
        glassStroke = AppColors.glassDarkStroke,
        glow = const Color(0x3310B981),
        scrim = AppColors.scrimLight,
        textMuted = AppColors.textTertiaryLight,
        cardSurface = AppColors.surfaceLight,
        success = AppColors.emerald600,
        warning = const Color(0xFFD97706),
        danger = const Color(0xFFE11D48),
        info = const Color(0xFF0284C7);

  /// Frosted glass fill behind blurred panels.
  final Color glassSurface;

  /// Hairline stroke drawn on glass panel edges.
  final Color glassStroke;

  /// Emerald glow tint for hero elements and score highlights.
  final Color glow;

  /// Scrim behind modal sheets and dialogs.
  final Color scrim;

  /// Muted text color for hints and tertiary content.
  final Color textMuted;

  /// Resting card surface color.
  final Color cardSurface;

  /// Positive state color.
  final Color success;

  /// Warning state color.
  final Color warning;

  /// Destructive and error state color.
  final Color danger;

  /// Informational state color.
  final Color info;

  @override
  PoselyColors copyWith({
    Color? glassSurface,
    Color? glassStroke,
    Color? glow,
    Color? scrim,
    Color? textMuted,
    Color? cardSurface,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return PoselyColors(
      glassSurface: glassSurface ?? this.glassSurface,
      glassStroke: glassStroke ?? this.glassStroke,
      glow: glow ?? this.glow,
      scrim: scrim ?? this.scrim,
      textMuted: textMuted ?? this.textMuted,
      cardSurface: cardSurface ?? this.cardSurface,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  PoselyColors lerp(ThemeExtension<PoselyColors>? other, double t) {
    if (other is! PoselyColors) {
      return this;
    }
    return PoselyColors(
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
