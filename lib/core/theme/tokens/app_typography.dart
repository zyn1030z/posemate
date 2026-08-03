import 'package:flutter/material.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';

/// Typography tokens for Posely AI.
///
/// Clean geometric type: tight negative tracking on large sizes,
/// confident w600 to w800 headings, and relaxed line heights for body
/// copy. Includes an airportCode style for extra-large bold identifiers.
/// The Material text theme is built per brightness, while the semantic
/// aliases carry light-first colors for direct use across the app.
abstract final class AppTypography {
  /// Text font family bundled with the app (weights 400–700).
  static const String fontFamily = 'Inter';

  /// Display-optical-size family for large headings and hero numerals
  /// (weights 600–800). Same metrics as Inter, tighter spacing at size.
  static const String displayFamily = 'InterDisplay';

  /// Builds the Material text theme with brand tracking and weights.
  ///
  /// The primary color is applied to prominent styles and the secondary
  /// color to supporting styles such as small body and label text.
  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: _style(
        size: 56,
        weight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -1.5,
        color: primary,
        family: displayFamily,
      ),
      displayMedium: _style(
        size: 44,
        weight: FontWeight.w700,
        height: 1.14,
        letterSpacing: -1.1,
        color: primary,
        family: displayFamily,
      ),
      displaySmall: _style(
        size: 36,
        weight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.8,
        color: primary,
        family: displayFamily,
      ),
      headlineLarge: _style(
        size: 32,
        weight: FontWeight.w700,
        height: 1.22,
        letterSpacing: -0.6,
        color: primary,
        family: displayFamily,
      ),
      headlineMedium: _style(
        size: 28,
        weight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: primary,
        family: displayFamily,
      ),
      headlineSmall: _style(
        size: 24,
        weight: FontWeight.w600,
        height: 1.28,
        letterSpacing: -0.4,
        color: primary,
        family: displayFamily,
      ),
      titleLarge: _style(
        size: 22,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: primary,
      ),
      titleMedium: _style(
        size: 17,
        weight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.2,
        color: primary,
      ),
      titleSmall: _style(
        size: 15,
        weight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.1,
        color: primary,
      ),
      bodyLarge: _style(
        size: 17,
        weight: FontWeight.w400,
        height: 1.45,
        letterSpacing: -0.2,
        color: primary,
      ),
      bodyMedium: _style(
        size: 15,
        weight: FontWeight.w400,
        height: 1.45,
        letterSpacing: -0.1,
        color: primary,
      ),
      bodySmall: _style(
        size: 13,
        weight: FontWeight.w400,
        height: 1.4,
        color: secondary,
      ),
      labelLarge: _style(
        size: 15,
        weight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: _style(
        size: 12,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.4,
        color: secondary,
      ),
      labelSmall: _style(
        size: 11,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.6,
        color: secondary,
      ),
    );
  }

  /// Hero display style for splash, onboarding, and result reveals.
  static TextStyle get displayHero => _style(
        size: 44,
        weight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.2,
        color: AppColors.textPrimary,
        family: displayFamily,
      );

  /// Large title at the top of a screen.
  static TextStyle get screenTitle => _style(
        size: 28,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
        family: displayFamily,
      );

  /// Heading for a content section within a screen.
  static TextStyle get sectionTitle => _style(
        size: 20,
        weight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  /// Title inside a card or list tile.
  static TextStyle get cardTitle => _style(
        size: 17,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  /// Default body copy.
  static TextStyle get body => _style(
        size: 15,
        weight: FontWeight.w400,
        height: 1.5,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  /// Muted body copy for supporting paragraphs.
  static TextStyle get bodyMuted => _style(
        size: 15,
        weight: FontWeight.w400,
        height: 1.5,
        letterSpacing: -0.1,
        color: AppColors.textSecondary,
      );

  /// Small caption text under images and controls.
  static TextStyle get caption => _style(
        size: 13,
        weight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textTertiary,
      );

  /// Tiny uppercase-style eyebrow label with wide tracking.
  static TextStyle get overline => _style(
        size: 11,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
      );

  /// Button label style.
  static TextStyle get button => _style(
        size: 16,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  /// Extra-large bold style for category codes and pose identifiers,
  /// inspired by airport code typography (JFK, LAX style).
  static TextStyle get airportCode => _style(
        size: 32,
        weight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
        family: displayFamily,
      );

  /// Large numeric style for AI scores, using tabular figures so
  /// animated digits do not shift horizontally.
  static TextStyle get scoreDigits => _style(
        size: 56,
        weight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
        family: displayFamily,
        features: const <FontFeature>[FontFeature.tabularFigures()],
      );

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color? color,
    String family = fontFamily,
    List<FontFeature>? features,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: features,
    );
  }
}
