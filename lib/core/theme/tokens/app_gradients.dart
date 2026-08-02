import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';

/// Gradient tokens for Posely AI.
///
/// Signature surfaces: the emerald hero fill, photographic veils, glass
/// sheens, the tricolor score ring, and the ambient aurora that gives
/// the dark background its depth.
abstract final class AppGradients {
  /// Diagonal emerald gradient for hero buttons and highlight cards.
  static const LinearGradient emeraldHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.emerald400, AppColors.emerald600],
  );

  /// Vertical veil from transparent to deep black, laid over photos so
  /// overlaid text stays legible.
  static const LinearGradient darkVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x00000000), Color(0xBF000000)],
  );

  /// Subtle white sheen that gives glass panels their catch of light.
  static const LinearGradient glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0x1AFFFFFF), Color(0x05FFFFFF)],
  );

  /// Sweep gradient for circular score dials, running from rose through
  /// amber to emerald, starting at the top of the dial.
  static const SweepGradient scoreRing = SweepGradient(
    colors: <Color>[
      AppColors.scoreLow,
      AppColors.scoreMid,
      AppColors.scoreHigh,
    ],
    stops: <double>[0.0, 0.5, 1.0],
    transform: GradientRotation(-math.pi / 2),
  );

  /// Faint radial emerald tint floated over the dark background to
  /// create an ambient aurora behind content.
  static const RadialGradient backgroundAurora = RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.2,
    colors: <Color>[Color(0x2E10B981), Color(0x0010B981)],
  );
}
