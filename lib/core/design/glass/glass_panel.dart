import 'package:flutter/material.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_blur.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';

/// A frosted glass surface that blurs whatever renders behind it.
///
/// The panel clips to its border radius, applies a backdrop blur, and
/// paints a translucent tint with a hairline stroke on top. An optional
/// sheen gradient catches light across the top edge, selling the glass
/// effect on dark backgrounds.
class GlassPanel extends StatelessWidget {
  /// Creates a frosted glass panel around the given child.
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = AppBlur.glass,
    this.tint,
    this.showSheen = true,
  });

  /// Content rendered inside the panel.
  final Widget child;

  /// Inner padding around the child. Defaults to none.
  final EdgeInsetsGeometry? padding;

  /// Corner rounding of the panel. Defaults to [AppRadius.brXl].
  final BorderRadius? borderRadius;

  /// Gaussian blur sigma applied to the backdrop.
  final double blurSigma;

  /// Fill color painted over the blurred backdrop. Defaults to the
  /// glass surface color from [PoselyColors].
  final Color? tint;

  /// Whether to paint the light-catching sheen gradient overlay.
  final bool showSheen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    final radius = borderRadius ?? AppRadius.brXl;

    var content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (showSheen) {
      content = Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.glassSheen,
                  borderRadius: radius,
                ),
              ),
            ),
          ),
          content,
        ],
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: AppBlur.glassFilter(blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint ?? colors.glassSurface,
            borderRadius: radius,
            border: Border.all(color: colors.glassStroke),
          ),
          child: content,
        ),
      ),
    );
  }
}
