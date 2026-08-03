import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';

/// A 52-pixel frosted glass disc that starts a social sign-in.
///
/// Renders a clean monochrome glyph for the provider — letterforms for
/// Google and Facebook, the platform icon for Apple — on a glass disc
/// with a hairline stroke and ink feedback. While loading, an 18-pixel
/// spinner replaces the glyph and taps are blocked.
class SocialAuthButton extends StatelessWidget {
  /// Creates a social sign-in disc for the given provider.
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.loading = false,
  });

  /// The social provider this button signs in with.
  final SocialProvider provider;

  /// Called on tap; blocked while loading.
  final VoidCallback onPressed;

  /// Whether a spinner replaces the glyph and taps are blocked.
  final bool loading;

  /// Diameter of the glass disc in logical pixels.
  static const double _size = 52;

  /// Monochrome letterform style for the Google and Facebook glyphs.
  static TextStyle _glyphStyle(BuildContext context) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1,
    color: Theme.of(context).colorScheme.onSurface,
  );

  void _handleTap() {
    HapticFeedback.lightImpact();
    onPressed();
  }

  Widget _buildGlyph(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (loading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(onSurface),
        ),
      );
    }
    return switch (provider) {
      SocialProvider.google => Text('g', style: _glyphStyle(context)),
      SocialProvider.apple =>
        Icon(Icons.apple, size: 26, color: onSurface),
      SocialProvider.facebook => Text('f', style: _glyphStyle(context)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    return Semantics(
      button: true,
      enabled: !loading,
      label: 'Continue with ${provider.label}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.glassSurface,
          border: Border.all(color: colors.glassStroke),
        ),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: loading ? null : _handleTap,
              customBorder: const CircleBorder(),
              child: Center(child: _buildGlyph(context)),
            ),
          ),
        ),
      ),
    );
  }
}
