import 'package:flutter/painting.dart';

/// Shadow tokens for Posely AI.
///
/// Tuned for the light flagship theme: very low alpha and large blur
/// so elevation reads as soft, natural depth on off-white backgrounds.
/// The blue glow is reserved for hero moments.
abstract final class AppShadows {
  /// Soft ambient shadow for resting cards and tiles.
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x4D000000), // 30% black
      blurRadius: 16,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  /// Medium shadow for raised surfaces such as popovers and menus.
  static const List<BoxShadow> medium = <BoxShadow>[
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x66000000), // 40% black
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  /// High shadow for floating elements such as dialogs and sheets.
  static const List<BoxShadow> high = <BoxShadow>[
    BoxShadow(
      color: Color(0x4D000000), // 30% black
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x80000000), // 50% black
      blurRadius: 40,
      offset: Offset(0, 16),
      spreadRadius: -8,
    ),
  ];

  /// Blue-tinted glow for hero buttons and score highlights.
  static const List<BoxShadow> blueGlow = <BoxShadow>[
    BoxShadow(
      color: Color(0x33007AFF),
      blurRadius: 24,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
    BoxShadow(color: Color(0x1A007AFF), blurRadius: 40, offset: Offset(0, 12)),
  ];

  /// Legacy alias — maps to blueGlow for backward compatibility.
  static const List<BoxShadow> emeraldGlow = blueGlow;
}
