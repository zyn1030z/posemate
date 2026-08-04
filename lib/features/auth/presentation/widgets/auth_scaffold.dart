import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';

/// Shared fullscreen chrome for the auth flow screens.
///
/// Renders the deep slate background with the emerald aurora glow in the
/// top-left corner (mirroring the splash treatment), an optional glass
/// back disc, and a scrollable content area that centers short content
/// and never overflows when the keyboard appears. An optional footer is
/// pinned below the scrollable area.
class AuthScaffold extends StatelessWidget {
  /// Creates the auth flow scaffold around the given content.
  const AuthScaffold({
    super.key,
    required this.child,
    this.showBack = true,
    this.footer,
  });

  /// Scrollable screen content, constrained to a tablet-friendly width.
  final Widget child;

  /// Whether the glass back disc is shown in the top-left corner.
  final bool showBack;

  /// Optional widget pinned under the scrollable area, above the
  /// bottom safe-area inset.
  final Widget? footer;

  /// Maximum content width so forms stay readable on tablets.
  static const double _maxContentWidth = 440;

  /// Vertical breathing room applied inside the scrollable area.
  static const double _verticalPadding = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Subtle emerald aurora anchored to the top-left corner.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.8),
                radius: 1.2,
                colors: <Color>[
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                if (showBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.lg,
                        top: AppSpacing.sm,
                      ),
                      child: PoselyIconButton(
                        icon: Icons.arrow_back_rounded,
                        semanticLabel: 'Back',
                        onPressed: context.pop,
                      ),
                    ),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final minHeight = math.max(
                            0.0,
                            constraints.maxHeight - _verticalPadding * 2,
                          );
                          return SingleChildScrollView(
                            padding: AppSpacing.screenPadding.add(
                              const EdgeInsets.symmetric(
                                vertical: _verticalPadding,
                              ),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: minHeight),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _maxContentWidth,
                                  ),
                                  child: child,
                                ),
                              ),
                            ),
                          );
                        },
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxContentWidth,
                        ),
                        child: footer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
