import 'package:flutter/painting.dart';

/// Corner radius tokens for Posely AI.
///
/// Standardized to 16-20px for cards per the clean modern spec.
/// Exposes raw radii, prebuilt border-radius constants, and shared
/// shapes for cards and sheets so rounding stays consistent everywhere.
abstract final class AppRadius {
  /// Small radius — 10 logical pixels, for chips and small controls.
  static const double sm = 10;

  /// Medium radius — 16 logical pixels, for inputs and tiles.
  static const double md = 16;

  /// Large radius — 20 logical pixels, for buttons and cards.
  static const double lg = 20;

  /// Extra-large radius — 20 logical pixels, for cards and dialogs.
  static const double xl = 20;

  /// Double-extra-large radius — 28 logical pixels, for sheets.
  static const double xxl = 28;

  /// Effectively-circular radius for pill shapes.
  static const double pill = 999;

  /// Border radius using the small token.
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));

  /// Border radius using the medium token.
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));

  /// Border radius using the large token.
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));

  /// Border radius using the extra-large token.
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));

  /// Border radius using the double-extra-large token.
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));

  /// Border radius producing a full pill shape.
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));

  /// Shared shape for cards and glass panels.
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: brXl,
  );

  /// Shared shape for bottom sheets — rounded on the top edge only.
  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(xxl)),
  );
}
