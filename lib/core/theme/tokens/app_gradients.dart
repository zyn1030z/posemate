import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'package:posely_ai/core/theme/tokens/app_colors.dart';

/// Gradient tokens for Posely AI.
///
/// Clean, modern gradients: the blue hero fill for primary actions,
/// soft veils for photo overlays, subtle sheens for elevated cards,
/// the tricolor score ring, and a faint blue aurora for depth.
abstract final class AppGradients {
  /// Diagonal blue gradient for hero buttons and highlight cards.
  static const LinearGradient blueHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.blue400, AppColors.blue600],
  );

  /// Legacy alias — maps to blueHero for backward compatibility.
  static const LinearGradient emeraldHero = blueHero;

  /// Vertical veil from transparent to soft black, laid over photos so
  /// overlaid text stays legible.
  static const LinearGradient darkVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x00000000), Color(0x99000000)],
  );

  /// Subtle gray sheen that gives elevated cards their catch of light.
  static const LinearGradient glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0x0D000000), Color(0x03000000)],
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

  /// Faint radial blue tint floated over the light background to
  /// create a visible ambient glow behind hero content.
  static const RadialGradient backgroundAurora = RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.2,
    colors: <Color>[Color(0x24007AFF), Color(0x00007AFF)],
  );
}
