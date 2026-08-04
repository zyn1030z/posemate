import 'package:flutter/material.dart';

/// Brand color tokens for Posely AI.
///
/// A light-first palette built around off-white surfaces and vibrant
/// blue accents. Every token is a compile-time constant so it can be
/// used in const widget trees. Theme-dependent values are resolved
/// through PoselyColors in the theme extension layer.
abstract final class AppColors {
  // --- Blue brand scale (primary) -------------------------------------------

  /// Blue 50 — faint sky wash for tinted fills on light surfaces.
  static const Color blue50 = Color(0xFFEFF6FF);

  /// Blue 100 — soft sky for subtle highlights and badges.
  static const Color blue100 = Color(0xFFDBEAFE);

  /// Blue 200 — light tint for hover states on light surfaces.
  static const Color blue200 = Color(0xFFBFDBFE);

  /// Blue 300 — bright tint for glow edges and gradients.
  static const Color blue300 = Color(0xFF93C5FD);

  /// Blue 400 — vivid accent used in gradients and selected icons.
  static const Color blue400 = Color(0xFF60A5FA);

  /// Blue 500 — the core brand blue.
  static const Color blue500 = Color(0xFF007AFF);

  /// Blue 600 — pressed and dark-mode variant.
  static const Color blue600 = Color(0xFF0055D4);

  /// Blue 700 — deep blue for gradient ends.
  static const Color blue700 = Color(0xFF1D4ED8);

  /// Blue 800 — very deep blue for containers.
  static const Color blue800 = Color(0xFF1E40AF);

  /// Blue 900 — deepest blue, near-navy container tone.
  static const Color blue900 = Color(0xFF1E3A8A);

  /// Primary brand color, an alias of the core blue.
  static const Color primary = blue500;

  /// Secondary accent sky blue for gradients and highlights.
  static const Color accent = Color(0xFF5AC8FA);

  // --- Emerald scale (kept for score/semantic backward compat) ---------------

  /// Emerald 400 — vivid accent for score high states.
  static const Color emerald400 = Color(0xFF34D399);

  /// Emerald 500 — success green, matches legacy primary.
  static const Color emerald500 = Color(0xFF10B981);

  /// Emerald 600 — pressed green variant.
  static const Color emerald600 = Color(0xFF059669);

  // --- Light neutrals (flagship) — dim light mode ---------------------------

  /// App background — dark slate, premium dark aesthetic even in light mode.
  static const Color background = Color(0xFF1C1C1E);

  /// Base surface for cards and bars.
  static const Color surface = Color(0xFF2C2C2E);

  /// Elevated surface for dialogs, inputs, and raised cards.
  static const Color surfaceElevated = Color(0xFF3A3A3C);

  /// Highest surface tier for tracks, handles, and pressed fills.
  static const Color surfaceHighest = Color(0xFF48484A);

  /// Hairline outline color on surfaces.
  static const Color outline = Color(0xFF3A3A3C);

  // --- Dark neutrals (secondary theme) --------------------------------------

  /// App background in dark mode — OLED black.
  static const Color backgroundDark = Color(0xFF000000);

  /// Base surface for cards and bars in dark mode — deep slate.
  static const Color surfaceDark = Color(0xFF111827);

  /// Elevated surface in dark mode.
  static const Color surfaceElevatedDark = Color(0xFF1E293B);

  /// Highest surface tier in dark mode.
  static const Color surfaceHighestDark = Color(0xFF334155);

  /// Hairline outline color on dark surfaces.
  static const Color outlineDark = Color(0xFF1E293B);

  // --- Text (light mode — flagship) -----------------------------------------

  /// Primary text on light surfaces — near white to contrast with new dark bg.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Secondary, supporting text on light surfaces.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Tertiary, hint-level text on light surfaces.
  static const Color textTertiary = Color(0xFF64748B);

  /// White text and icons placed on blue fills.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Text (dark mode) -----------------------------------------------------

  /// Primary text on dark surfaces.
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  /// Secondary, supporting text on dark surfaces.
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /// Tertiary, hint-level text on dark surfaces.
  static const Color textTertiaryDark = Color(0xFF64748B);

  // --- Semantic -------------------------------------------------------------

  /// Positive state color — emerald green.
  static const Color success = emerald500;

  /// Warning state color — warm amber.
  static const Color warning = Color(0xFFF59E0B);

  /// Error and destructive state color — vivid rose.
  static const Color error = Color(0xFFF43F5E);

  /// Informational state color — sky blue.
  static const Color info = Color(0xFF38BDF8);

  // --- Glass overlays -------------------------------------------------------

  /// Frosted glass fill — white opacity for dark background.
  static const Color glassWhite = Color(0x0AFFFFFF);

  /// Glass border stroke — white opacity.
  static const Color glassStroke = Color(0x1AFFFFFF);

  /// Stronger glass fill — white opacity.
  static const Color glassStrong = Color(0x14FFFFFF);

  /// Frosted glass fill for dark mode — white at roughly 8 percent.
  static const Color glassDark = Color(0x14FFFFFF);

  /// Glass border stroke for dark mode — white at roughly 12 percent.
  static const Color glassDarkStroke = Color(0x1FFFFFFF);

  /// Modal scrim behind sheets and dialogs — black at 40 percent.
  static const Color scrim = Color(0x66000000);

  /// Lighter scrim for light mode — black at 25 percent.
  static const Color scrimLight = Color(0x40000000);

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
