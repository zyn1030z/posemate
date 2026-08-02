import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';

/// The Posely AI brand mark: a six-blade camera aperture stroked with the
/// emerald hero gradient over a soft glow, with an emerald center dot.
///
/// Painted at runtime with a custom painter so it stays crisp at any size
/// and needs no bundled assets. Optionally renders the wordmark beneath
/// the mark.
class PoselyLogo extends StatelessWidget {
  /// Creates a Posely logo of the given size, optionally with the wordmark.
  const PoselyLogo({super.key, this.size = 96, this.showWordmark = false});

  /// Width and height of the aperture mark in logical pixels.
  final double size;

  /// Whether the wordmark is rendered beneath the mark.
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AperturePainter(
          gradient: AppGradients.emeraldHero,
          glowColor: AppColors.primary.withValues(alpha: 0.38),
          dotColor: AppColors.emerald400,
        ),
      ),
    );
    if (!showWordmark) return mark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.2),
        PoselyWordmark(fontSize: size * 0.27),
      ],
    );
  }
}

/// The Posely AI wordmark: 'Posely' in the primary text color followed by
/// 'AI' in emerald, set bold with tight letter-spacing.
///
/// Exposed separately so screens (e.g. the splash) can animate the mark
/// and the wordmark independently.
class PoselyWordmark extends StatelessWidget {
  /// Creates the wordmark at the given font size.
  const PoselyWordmark({super.key, this.fontSize = 26});

  /// Font size of the wordmark text in logical pixels.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: fontSize * -0.03,
          height: 1,
        ),
        children: const [
          TextSpan(
            text: 'Posely',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: 'AI',
            style: TextStyle(color: AppColors.emerald400),
          ),
        ],
      ),
    );
  }
}

/// Paints six swirling aperture blades: each blade follows the outer ring
/// for a short arc, then sweeps inward toward the iris, giving the classic
/// shutter-blade curl. A blurred pass behind the blades provides the glow.
class _AperturePainter extends CustomPainter {
  const _AperturePainter({
    required this.gradient,
    required this.glowColor,
    required this.dotColor,
  });

  final Gradient gradient;
  final Color glowColor;
  final Color dotColor;

  static const int _bladeCount = 6;
  static const double _degToRad = math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final side = size.shortestSide;
    final outerRadius = side * 0.44;
    final innerRadius = side * 0.19;
    final strokeWidth = side * 0.06;
    final blades = _bladesPath(center, outerRadius, innerRadius);

    // Glow pass: same geometry, wider blurred stroke behind the blades.
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.2
      ..strokeCap = StrokeCap.round
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.05);
    canvas.drawPath(blades, glowPaint);

    // Blade pass: crisp stroke shaded with the emerald hero gradient.
    final bladePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Offset.zero & size);
    canvas.drawPath(blades, bladePaint);

    // Center dot accent with its own soft halo.
    final dotGlowPaint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.03);
    canvas.drawCircle(center, side * 0.07, dotGlowPaint);
    canvas.drawCircle(center, side * 0.05, Paint()..color = dotColor);
  }

  Path _bladesPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    for (var i = 0; i < _bladeCount; i++) {
      final startAngle = i * 360 / _bladeCount * _degToRad - math.pi / 2;
      path.addPath(
        _blade(center, outerRadius, innerRadius, startAngle),
        Offset.zero,
      );
    }
    return path;
  }

  Path _blade(
    Offset center,
    double outerRadius,
    double innerRadius,
    double startAngle,
  ) {
    const arcSweep = 38 * _degToRad;
    final controlAngle = startAngle + 72 * _degToRad;
    final tipAngle = startAngle + 100 * _degToRad;
    final control = center +
        Offset(math.cos(controlAngle), math.sin(controlAngle)) *
            (outerRadius * 0.84);
    final tip = center +
        Offset(math.cos(tipAngle), math.sin(tipAngle)) * innerRadius;
    return Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        arcSweep,
      )
      ..quadraticBezierTo(control.dx, control.dy, tip.dx, tip.dy);
  }

  @override
  bool shouldRepaint(_AperturePainter oldDelegate) =>
      gradient != oldDelegate.gradient ||
      glowColor != oldDelegate.glowColor ||
      dotColor != oldDelegate.dotColor;
}
