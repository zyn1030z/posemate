import 'package:flutter/widgets.dart';

/// Spacing tokens for Posely AI, built on a 4-point grid.
///
/// Use these constants for paddings, gaps, and margins so the whole app
/// shares one consistent rhythm.
abstract final class AppSpacing {
  /// Hairline spacing — 2 logical pixels.
  static const double xxs = 2;

  /// Extra-small spacing — 4 logical pixels.
  static const double xs = 4;

  /// Small spacing — 8 logical pixels.
  static const double sm = 8;

  /// Medium spacing — 12 logical pixels.
  static const double md = 12;

  /// Large spacing — 16 logical pixels.
  static const double lg = 16;

  /// Extra-large spacing — 20 logical pixels.
  static const double xl = 20;

  /// Double-extra-large spacing — 24 logical pixels.
  static const double xxl = 24;

  /// Triple-extra-large spacing — 32 logical pixels.
  static const double xxxl = 32;

  /// Huge spacing — 40 logical pixels.
  static const double huge = 40;

  /// Massive spacing — 56 logical pixels.
  static const double massive = 56;

  /// Vertical rhythm between major screen sections — 28 logical pixels.
  static const double sectionGap = 28;

  /// Default horizontal padding applied to screen content.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xl);

  /// Default inner padding for cards and glass panels.
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}
