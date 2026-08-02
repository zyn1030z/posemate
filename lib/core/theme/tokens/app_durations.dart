import 'package:flutter/animation.dart';

/// Motion tokens for Posely AI — durations and curves.
///
/// Keep motion short and decisive for micro-interactions, and reserve
/// the slower timings for large surfaces and branded moments.
abstract final class AppDurations {
  /// Quick micro-interactions such as taps, toggles, and icon swaps.
  static const Duration fast = Duration(milliseconds: 150);

  /// Default duration for most transitions.
  static const Duration base = Duration(milliseconds: 250);

  /// Slower, emphasized transitions for sheets and hero moves.
  static const Duration slow = Duration(milliseconds: 400);

  /// Splash-screen reveal duration.
  static const Duration splash = Duration(milliseconds: 1600);

  /// One full sweep of a shimmer loading placeholder.
  static const Duration shimmer = Duration(milliseconds: 1200);

  /// Fast-out curve with a long, luxurious deceleration tail.
  static const Curve easeOutExpo = Curves.easeOutExpo;

  /// Playful overshoot curve for pop-in elements and badges.
  static const Curve spring = Curves.easeOutBack;

  /// Emphasized Material 3 curve for large surface transitions.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}
