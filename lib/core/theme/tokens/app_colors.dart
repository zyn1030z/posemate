import 'package:flutter/material.dart';

/// Brand color tokens for Posely AI.
///
/// A dark-first palette built around deep slate surfaces and emerald
/// accents. Every token is a compile-time constant so it can be used in
/// const widget trees. Theme-dependent values are resolved through
/// PoselyColors in the theme extension layer.
abstract final class AppColors {
  // --- Emerald brand scale --------------------------------------------------

  /// Emerald 50 — faint mint wash for tinted fills on light surfaces.
  static const Color emerald50 = Color(0xFFECFDF5);

  /// Emerald 100 — soft mint for subtle highlights and badges.
  static const Color emerald100 = Color(0xFFD1FAE5);

  /// Emerald 200 — light tint for hover states on light surfaces.
  static const Color emerald200 = Color(0xFFA7F3D0);

  /// Emerald 300 — bright tint for glow edges and gradients.
  static const Color emerald300 = Color(0xFF6EE7B7);

  /// Emerald 400 — vivid accent used in gradients and selected icons.
  static const Color emerald400 = Color(0xFF34D399);

  /// Emerald 500 — the core brand emerald.
  static const Color emerald500 = Color(0xFF10B981);

  /// Emerald 600 — pressed and light-mode-contrast variant.
  static const Color emerald600 = Color(0xFF059669);

  /// Emerald 700 — deep emerald for gradient ends.
  static const Color emerald700 = Color(0xFF047857);

  /// Emerald 800 — very deep emerald for containers.
  static const Color emerald800 = Color(0xFF065F46);

  /// Emerald 900 — deepest emerald, near-forest container tone.
  static const Color emerald900 = Color(0xFF064E3B);

  /// Primary brand color, an alias of the core emerald.
  static const Color primary = emerald500;

  /// Secondary accent green for gradients and highlights.
  static const Color accent = Color(0xFF22C55E);

  // --- Dark neutrals (flagship) ---------------------------------------------

  /// App background in dark mode — deepest slate.
  static const Color background = Color(0xFF0F172A);

  /// Base surface for cards and bars in dark mode.
  static const Color surface = Color(0xFF111827);

  /// Elevated surface for dialogs, inputs, and raised cards.
  static const Color surfaceElevated = Color(0xFF1E293B);

  /// Highest surface tier for tracks, handles, and pressed fills.
  static const Color surfaceHighest = Color(0xFF334155);

  /// Hairline outline color on dark surfaces.
  static const Color outline = Color(0xFF33415F);

  // --- Light neutrals -------------------------------------------------------

  /// App background in light mode — near-white slate.
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Base surface for cards and bars in light mode.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Elevated surface for inputs and grouped content in light mode.
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);

  /// Highest surface tier for tracks and handles in light mode.
  static const Color surfaceHighestLight = Color(0xFFE2E8F0);

  /// Hairline outline color on light surfaces.
  static const Color outlineLight = Color(0xFFCBD5E1);

  // --- Text (dark mode) -----------------------------------------------------

  /// Primary text on dark surfaces.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Secondary, supporting text on dark surfaces.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Tertiary, hint-level text on dark surfaces.
  static const Color textTertiary = Color(0xFF64748B);

  /// Deep forest text and icons placed on emerald fills.
  static const Color textOnPrimary = Color(0xFF052E1F);

  // --- Text (light mode) ----------------------------------------------------

  /// Primary text on light surfaces.
  static const Color textPrimaryLight = Color(0xFF0F172A);

  /// Secondary, supporting text on light surfaces.
  static const Color textSecondaryLight = Color(0xFF475569);

  /// Tertiary, hint-level text on light surfaces.
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // --- Semantic -------------------------------------------------------------

  /// Positive state color, aligned with the brand emerald.
  static const Color success = emerald500;

  /// Warning state color — warm amber.
  static const Color warning = Color(0xFFF59E0B);

  /// Error and destructive state color — vivid rose.
  static const Color error = Color(0xFFF43F5E);

  /// Informational state color — sky blue.
  static const Color info = Color(0xFF38BDF8);

  // --- Glass overlays -------------------------------------------------------

  /// Frosted glass fill — white at roughly 8 percent opacity.
  static const Color glassWhite = Color(0x14FFFFFF);

  /// Glass border stroke — white at roughly 12 percent opacity.
  static const Color glassStroke = Color(0x1FFFFFFF);

  /// Stronger glass fill — white at roughly 14 percent opacity.
  static const Color glassStrong = Color(0x24FFFFFF);

  /// Frosted glass fill for light mode — slate at roughly 5 percent.
  static const Color glassDark = Color(0x0D0F172A);

  /// Glass border stroke for light mode — slate at roughly 10 percent.
  static const Color glassDarkStroke = Color(0x1A0F172A);

  /// Modal scrim behind sheets and dialogs — black at 60 percent.
  static const Color scrim = Color(0x99000000);

  /// Lighter scrim for light mode — black at 40 percent.
  static const Color scrimLight = Color(0x66000000);

  // --- AI score feedback ----------------------------------------------------

  /// Score color for weak results, below 0.5.
  static const Color scoreLow = Color(0xFFF43F5E);

  /// Score color for average results, from 0.5 up to 0.8.
  static const Color scoreMid = Color(0xFFF59E0B);

  /// Score color for strong results, 0.8 and above.
  static const Color scoreHigh = Color(0xFF10B981);

  /// Resolves the feedback color for a normalized score.
  ///
  /// The score is expected to be between 0.0 and 1.0. Values below 0.5
  /// resolve to the low color, values below 0.8 resolve to the mid
  /// color, and everything else resolves to the high color.
  static Color forScore(double score) {
    if (score >= 0.8) {
      return scoreHigh;
    }
    if (score >= 0.5) {
      return scoreMid;
    }
    return scoreLow;
  }
}
