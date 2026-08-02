import 'package:flutter/material.dart';
import 'package:posely_ai/core/theme/theme_extensions.dart';

/// Convenience accessors on `BuildContext` for theme and media query data.
extension BuildContextX on BuildContext {
  /// The nearest ambient `ThemeData`.
  ThemeData get theme => Theme.of(this);

  /// The text theme of the nearest ambient theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The color scheme of the nearest ambient theme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The Posely brand colors theme extension.
  ///
  /// The app theme always registers PoselyColors, so the lookup is
  /// non-nullable by design; failing loudly beats silently wrong colors.
  PoselyColors get posely => Theme.of(this).extension<PoselyColors>()!;

  /// The logical screen size from the nearest media query.
  Size get size => MediaQuery.sizeOf(this);

  /// The safe-area padding from the nearest media query.
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// Whether the ambient theme is in dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Dismisses the on-screen keyboard by unfocusing the primary focus.
  void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
}
