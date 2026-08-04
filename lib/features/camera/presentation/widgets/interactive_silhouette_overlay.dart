import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';

class InteractiveSilhouetteOverlay extends StatefulWidget {
  final String imageUrl;
  final double opacity;
  final bool isLocked;
  final bool isFlipped;

  const InteractiveSilhouetteOverlay({
    super.key,
    required this.imageUrl,
    required this.opacity,
    this.isLocked = false,
    this.isFlipped = false,
  });

  @override
  State<InteractiveSilhouetteOverlay> createState() =>
      _InteractiveSilhouetteOverlayState();
}

class _InteractiveSilhouetteOverlayState
    extends State<InteractiveSilhouetteOverlay> {
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  // Variables to hold the starting values during a gesture
  Offset _startingOffset = Offset.zero;
  double _startingScale = 1.0;
  double _startingRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.opacity <= 0.0) return const SizedBox.shrink();

    // Determine image source based on URL prefix
    Widget silhouette;
    if (widget.imageUrl.startsWith('asset://')) {
      silhouette = Image.asset(
        widget.imageUrl.replaceFirst('asset://', ''),
        fit: BoxFit.contain,
      );
    } else if (widget.imageUrl.startsWith('file://')) {
      silhouette = Image.file(
        File(widget.imageUrl.replaceFirst('file://', '')),
        fit: BoxFit.contain,
      );
    } else {
      silhouette = CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }

    // Apply flip (mirror)
    if (widget.isFlipped) {
      silhouette = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(
          math.pi,
        ), // Needs import 'dart:math' as math;
        child: silhouette,
      );
    }

    // Apply Glow and Opacity
    silhouette = Opacity(
      opacity: widget.opacity,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Glow layer
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: silhouette,
            ),
          ),
          // Main image (White line-art contour)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: silhouette,
          ),
        ],
      ),
    );

    // Apply Transformation (Pan, Scale, Rotate)
    silhouette = Transform.translate(
      offset: _offset,
      child: Transform.scale(
        scale: _scale,
        child: Transform.rotate(angle: _rotation, child: silhouette),
      ),
    );

    if (widget.isLocked) {
      return IgnorePointer(child: silhouette);
    }

    return GestureDetector(
      onScaleStart: (details) {
        _startingOffset = _offset;
        _startingScale = _scale;
        _startingRotation = _rotation;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Adjust translation by scale so it pans naturally at different zoom levels
          _offset = _startingOffset + details.focalPointDelta;
          // Scale
          _scale = (_startingScale * details.scale).clamp(0.1, 5.0);
          // Rotation
          _rotation = _startingRotation + details.rotation;
        });
        // Update starting offset for continuous pan calculation
        _startingOffset = _offset;
      },
      child: ColoredBox(
        color: Colors.transparent, // Capture gestures
        child: silhouette,
      ),
    );
  }
}
