import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// Branded fullscreen fallback for unknown locations and router errors.
///
/// Shown by the router's `errorBuilder`; keeps the user inside the app's
/// dark visual language and offers a single recovery action back home.
class RouteErrorScreen extends StatelessWidget {
  /// Creates a route error screen for the given router error.
  const RouteErrorScreen({super.key, this.error});

  /// The error reported by the router, rendered as muted supporting text.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PoselyLogo(size: 56),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Lost in the frame',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error?.toString() ??
                      'The page you were looking for does not exist.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.posely.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => context.go(RoutePaths.home),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
