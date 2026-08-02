import 'package:flutter/painting.dart';

/// Shadow tokens for Posely AI.
///
/// Tuned for the dark flagship theme: low alpha and large blur so
/// elevation reads as soft ambient depth rather than harsh drop
/// shadows. The emerald glow is reserved for hero moments.
abstract final class AppShadows {
  /// Soft ambient shadow for resting cards and tiles.
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
  ];

  /// Medium shadow for raised surfaces such as popovers and menus.
  static const List<BoxShadow> medium = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 28,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
  ];

  /// High shadow for floating elements such as dialogs and sheets.
  static const List<BoxShadow> high = <BoxShadow>[
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 48,
      offset: Offset(0, 20),
      spreadRadius: -8,
    ),
  ];

  /// Emerald-tinted glow for hero buttons and score highlights.
  static const List<BoxShadow> emeraldGlow = <BoxShadow>[
    BoxShadow(
      color: Color(0x5210B981),
      blurRadius: 28,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x2410B981),
      blurRadius: 48,
      offset: Offset(0, 12),
    ),
  ];
}
