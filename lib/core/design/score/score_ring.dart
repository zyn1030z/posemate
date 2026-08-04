import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Circular AI score dial.
///
/// Draws a glass track with a gradient progress arc sweeping from
/// twelve o'clock, a soft glow at the arc tip, and the percentage in
/// tabular display digits at the center. The ring animates from zero on
/// mount and tweens between values on updates, unless animation is
/// disabled or the platform requests reduced motion.
class ScoreRing extends StatefulWidget {
  /// Creates a score ring for a normalized score.
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 120,
    this.label,
    this.animate = true,
  }) : assert(
         score >= 0.0 && score <= 1.0,
         'score must be between 0.0 and 1.0',
       );

  /// Normalized score between 0.0 and 1.0.
  final double score;

  /// Diameter of the ring in logical pixels.
  final double size;

  /// Optional caption shown under the digits and used in semantics.
  final String? label;

  /// Whether the ring animates on mount and on score changes.
  final bool animate;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progress;
  bool _reducedMotion = false;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow);
    _progress = AlwaysStoppedAnimation<double>(widget.score);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_bootstrapped) {
      return;
    }
    _bootstrapped = true;
    if (widget.animate && !_reducedMotion) {
      _animateTo(widget.score, from: 0);
    }
  }

  @override
  void didUpdateWidget(ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score == widget.score) {
      return;
    }
    if (widget.animate && !_reducedMotion) {
      _animateTo(widget.score, from: _progress.value);
    } else {
      setState(() {
        _controller.stop();
        _progress = AlwaysStoppedAnimation<double>(widget.score);
      });
    }
  }

  void _animateTo(double target, {required double from}) {
    setState(() {
      _progress = Tween<double>(begin: from, end: target).animate(
        CurvedAnimation(parent: _controller, curve: AppDurations.easeOutExpo),
      );
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final percent = (widget.score * 100).round();
    final semanticLabel = '${widget.label ?? 'Score'} $percent percent';
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final progress = _progress.value.clamp(0.0, 1.0).toDouble();
              return CustomPaint(
                painter: _ScoreRingPainter(
                  progress: progress,
                  ringWidth: widget.size / 14,
                  trackColor: posely.glassStroke,
                  glowColor: AppColors.forScore(widget.score),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            '${(progress * 100).round()}',
                            style: AppTypography.scoreDigits.copyWith(
                              fontSize: widget.size * 0.28,
                            ),
                          ),
                          Text(
                            '%',
                            style: AppTypography.scoreDigits.copyWith(
                              fontSize: widget.size * 0.14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (widget.label != null)
                        Text(
                          widget.label!,
                          style: AppTypography.caption.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints the score ring: glass track, gradient arc, and tip glow.
class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.progress,
    required this.ringWidth,
    required this.trackColor,
    required this.glowColor,
  });

  /// Current sweep fraction of the arc, between 0.0 and 1.0.
  final double progress;

  /// Stroke width of the track and arc.
  final double ringWidth;

  /// Color of the resting circular track.
  final Color trackColor;

  /// Color of the soft glow trailing the arc tip.
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - ringWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Soft glow behind the tip of the arc, tinted by the score color.
    final tailSweep = math.min(sweepAngle, math.pi / 4);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round
      ..color = glowColor.withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, ringWidth * 0.75);
    canvas.drawArc(
      rect,
      startAngle + sweepAngle - tailSweep,
      tailSweep,
      false,
      glowPaint,
    );

    // The sweep gradient already starts at twelve o'clock, so the arc
    // reveals rose through amber to emerald as the score climbs.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round
      ..shader = AppGradients.scoreRing.createShader(rect);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringWidth != ringWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.glowColor != glowColor;
  }
}
