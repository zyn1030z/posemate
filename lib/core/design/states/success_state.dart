import 'package:flutter/material.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Centered success state: an emerald glass circle with a check mark
/// drawn progressively, a title, optional message, and optional action.
///
/// The check strokes itself in once on mount; under reduced motion it
/// renders fully drawn. The whole state shares the same gentle
/// fade-and-rise entrance used by the empty state.
class SuccessState extends StatelessWidget {
  /// Creates a success state with the given title.
  const SuccessState({
    super.key,
    required this.title,
    this.message,
    this.action,
  });

  /// Short celebratory headline.
  final String title;

  /// Optional supporting copy shown in muted text below the title.
  final String? message;

  /// Optional follow-up action widget rendered below the copy.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: reducedMotion ? Duration.zero : AppDurations.slow,
          curve: AppDurations.easeOutExpo,
          builder: (context, t, child) {
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - t)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: posely.glassStroke),
                  boxShadow: AppShadows.emeraldGlow,
                ),
                child: const _AnimatedCheck(size: 34),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.cardTitle,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: AppTypography.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Check mark that strokes itself in with a one-shot animation.
class _AnimatedCheck extends StatefulWidget {
  const _AnimatedCheck({required this.size});

  /// Square edge length of the check canvas in logical pixels.
  final double size;

  @override
  State<_AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<_AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: AppDurations.easeOutExpo,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _CheckPainter(progress: _progress.value),
        );
      },
    );
  }
}

/// Draws a check path progressively with a soft emerald glow behind it.
class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress});

  /// Draw progress from 0 (nothing) to 1 (complete check).
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.54)
      ..lineTo(size.width * 0.42, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.26);

    var visible = path;
    if (progress < 1) {
      visible = Path();
      for (final metric in path.computeMetrics()) {
        visible.addPath(
          metric.extractPath(0, metric.length * progress),
          Offset.zero,
        );
      }
    }

    final strokeWidth = size.width * 0.12;
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.8);
    canvas.drawPath(visible, glowPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.blue300;
    canvas.drawPath(visible, strokePaint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
