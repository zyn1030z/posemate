import 'dart:ui';

/// Backdrop blur tokens for the glassmorphism language of Posely AI.
abstract final class AppBlur {
  /// Soft sigma for subtle frosted layers behind small controls.
  static const double soft = 12;

  /// Standard glass sigma for cards, bars, and sheets.
  static const double glass = 20;

  /// Heavy sigma for full-screen veils and modal backgrounds.
  static const double heavy = 36;

  /// Builds a symmetric gaussian blur filter for a backdrop filter
  /// widget, defaulting to the standard glass sigma.
  static ImageFilter glassFilter([double sigma = glass]) {
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }
}
