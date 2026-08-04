import 'package:flutter/material.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// Centered branded loading state: a 44-pixel emerald spinner ring over
/// a 72-pixel glass disc, with an optional muted message beneath.
///
/// The disc breathes gently between 1.0 and 1.04 scale while loading;
/// the breathing is disabled when the platform requests reduced motion.
class AppLoadingView extends StatefulWidget {
  /// Creates a loading view with an optional message.
  const AppLoadingView({super.key, this.message});

  /// Optional short status text shown below the spinner.
  final String? message;

  @override
  State<AppLoadingView> createState() => _AppLoadingViewState();
}

class _AppLoadingViewState extends State<AppLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // One half of the breathing cycle shares the shimmer cadence so all
    // loading rhythms in the app pulse together.
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    );
    _scale = Tween<double>(
      begin: 1,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (reducedMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: posely.glassSurface,
                shape: BoxShape.circle,
                border: Border.all(color: posely.glassStroke),
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: AppColors.primary,
                  semanticsLabel: 'Loading',
                ),
              ),
            ),
          ),
          if (widget.message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: posely.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
