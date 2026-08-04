import 'dart:async';
import 'package:flutter/material.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/features/camera/domain/entities/camera_state.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Renders camera guides such as grids and horizon level.
class CameraGuides extends StatefulWidget {
  final CameraGrid gridType;

  const CameraGuides({super.key, required this.gridType});

  @override
  State<CameraGuides> createState() => _CameraGuidesState();
}

class _CameraGuidesState extends State<CameraGuides> {
  double _roll = 0.0; // Device roll angle
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  @override
  void initState() {
    super.initState();
    _accelSubscription = accelerometerEventStream().listen((event) {
      // Very basic roll calculation. event.x goes -9.8 to 9.8.
      if (!mounted) return;
      setState(() {
        _roll = event.x;
      });
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.gridType == CameraGrid.ruleOfThirds) ...[
            _buildGridLine(true, 1 / 3),
            _buildGridLine(true, 2 / 3),
            _buildGridLine(false, 1 / 3),
            _buildGridLine(false, 2 / 3),
          ],
          if (widget.gridType == CameraGrid.center) ...[
            _buildGridLine(true, 0.5),
            _buildGridLine(false, 0.5),
          ],
          if (widget.gridType == CameraGrid.goldenRatio) ...[
            // Approximation for Golden Ratio grid
            _buildGridLine(true, 0.382),
            _buildGridLine(true, 0.618),
            _buildGridLine(false, 0.382),
            _buildGridLine(false, 0.618),
          ],

          // Horizon level indicator
          Center(
            child: Transform.rotate(
              angle: -_roll / 9.8 * 3.14159, // Rough approximation
              child: Container(
                width: 120,
                height: 2,
                decoration: BoxDecoration(
                  color: _roll.abs() < 0.3
                      ? AppColors.success
                      : Colors.white.withValues(alpha: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLine(bool isHorizontal, double fraction) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          top: isHorizontal ? constraints.maxHeight * fraction : 0,
          left: isHorizontal ? 0 : constraints.maxWidth * fraction,
          right: isHorizontal ? 0 : null,
          bottom: isHorizontal ? null : 0,
          child: Container(
            width: isHorizontal ? constraints.maxWidth : 1,
            height: isHorizontal ? 1 : constraints.maxHeight,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }
}
