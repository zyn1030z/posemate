import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraGuides extends StatefulWidget {
  final bool showGrid;
  final bool showHorizon;

  const CameraGuides({
    super.key,
    this.showGrid = true,
    this.showHorizon = true,
  });

  @override
  State<CameraGuides> createState() => _CameraGuidesState();
}

class _CameraGuidesState extends State<CameraGuides> {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _rollAngle = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.showHorizon) {
      _initSensors();
    }
  }

  @override
  void didUpdateWidget(covariant CameraGuides oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showHorizon != oldWidget.showHorizon) {
      if (widget.showHorizon) {
        _initSensors();
      } else {
        _accelSub?.cancel();
        _accelSub = null;
      }
    }
  }

  void _initSensors() {
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      // Calculate roll angle (tilt left/right).
      // Assuming phone is held in portrait mode:
      // x is lateral (left/right)
      // y is vertical (up/down)
      // z is depth
      final angle = math.atan2(event.x, event.y);
      setState(() {
        _rollAngle = angle;
      });
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GuidesPainter(
          showGrid: widget.showGrid,
          showHorizon: widget.showHorizon,
          rollAngle: _rollAngle,
        ),
      ),
    );
  }
}

class _GuidesPainter extends CustomPainter {
  final bool showGrid;
  final bool showHorizon;
  final double rollAngle;

  _GuidesPainter({
    required this.showGrid,
    required this.showHorizon,
    required this.rollAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    if (showGrid) {
      // Rule of thirds lines
      final thirdWidth = width / 3;
      final thirdHeight = height / 3;

      for (var i = 1; i <= 2; i++) {
        // Vertical lines
        canvas.drawLine(
          Offset(thirdWidth * i, 0),
          Offset(thirdWidth * i, height),
          gridPaint,
        );
        // Horizontal lines
        canvas.drawLine(
          Offset(0, thirdHeight * i),
          Offset(width, thirdHeight * i),
          gridPaint,
        );
      }

      // Center crosshair
      final centerX = width / 2;
      final centerY = height / 2;
      const crossSize = 10.0;
      canvas.drawLine(
        Offset(centerX - crossSize, centerY),
        Offset(centerX + crossSize, centerY),
        centerPaint,
      );
      canvas.drawLine(
        Offset(centerX, centerY - crossSize),
        Offset(centerX, centerY + crossSize),
        centerPaint,
      );
    }

    if (showHorizon) {
      // Draw horizon level
      canvas.save();
      
      final centerX = width / 2;
      final centerY = height / 2;
      
      canvas.translate(centerX, centerY);
      
      // We rotate by the calculated roll angle to keep the line horizontal
      canvas.rotate(-rollAngle);

      // If angle is very close to 0, show green (AppColors.primary)
      final isLevel = rollAngle.abs() < 0.05; // ~3 degrees tolerance
      final horizonColor = isLevel ? AppColors.primary : Colors.white;

      final horizonPaint = Paint()
        ..color = horizonColor.withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Draw a line across the center
      final lineLength = width * 0.6;
      canvas.drawLine(
        Offset(-lineLength / 2, 0),
        Offset(lineLength / 2, 0),
        horizonPaint,
      );
      
      // Draw end tick marks
      canvas.drawLine(
        Offset(-lineLength / 2, -10),
        Offset(-lineLength / 2, 10),
        horizonPaint,
      );
      canvas.drawLine(
        Offset(lineLength / 2, -10),
        Offset(lineLength / 2, 10),
        horizonPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GuidesPainter oldDelegate) {
    return oldDelegate.showGrid != showGrid ||
        oldDelegate.showHorizon != showHorizon ||
        oldDelegate.rollAngle != rollAngle;
  }
}
