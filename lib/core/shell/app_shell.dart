import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/services/haptics/haptic_service.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Height of the solid navigation bar.
const double _barHeight = 64;

/// Diameter of the center camera capture button.
const double _cameraButtonSize = 54;

/// Vertical lift of the camera button above the bar.
const double _cameraButtonLift = -12;

/// Persistent app scaffold hosting the tabbed navigation shell.
///
/// Renders the active branch above a solid white bottom navigation bar with
/// four tab items and a center blue camera capture button.
class AppShell extends ConsumerWidget {
  /// Creates the app shell around the given navigation shell.
  const AppShell({super.key, required this.navigationShell});

  /// Branch container provided by the stateful shell route.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _GlassNavBar(navigationShell: navigationShell),
    );
  }
}

/// The solid bottom navigation bar with tab items and the camera button.
class _GlassNavBar extends ConsumerWidget {
  const _GlassNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTap(WidgetRef ref, int index) {
    if (index != navigationShell.currentIndex) {
      unawaited(ref.read(hapticServiceProvider).selection());
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onCameraTap(BuildContext context, WidgetRef ref) {
    unawaited(ref.read(hapticServiceProvider).medium());
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Create Pose',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('AI Camera Viewfinder'),
              subtitle: const Text('Realtime coaching (Phase 8)'),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('Extract from Photo'),
              subtitle: const Text('Upload a photo to extract skeleton'),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.uploadPose);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outline,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: _barHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  _NavItem(
                    label: 'Home',
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                    selected: index == 0,
                    onTap: () => _onItemTap(ref, 0),
                  ),
                  _NavItem(
                    label: 'Poses',
                    activeIcon: Icons.grid_view_rounded,
                    inactiveIcon: Icons.grid_view_rounded,
                    selected: index == 1,
                    onTap: () => _onItemTap(ref, 1),
                  ),
                  // Reserved slot underneath the floating camera button.
                  const Spacer(),
                  _NavItem(
                    label: 'Gallery',
                    activeIcon: Icons.photo_library_rounded,
                    inactiveIcon: Icons.photo_library_outlined,
                    selected: index == 2,
                    onTap: () => _onItemTap(ref, 2),
                  ),
                  _NavItem(
                    label: 'Profile',
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outlined,
                    selected: index == 3,
                    onTap: () => _onItemTap(ref, 3),
                  ),
                ],
              ),
              _CameraButton(onTap: () => _onCameraTap(context, ref)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single tab item: icon, active dot, and active label.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : inactiveIcon,
                size: 24,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xxs),
              AnimatedContainer(
                duration: AppDurations.fast,
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              AnimatedOpacity(
                duration: AppDurations.fast,
                opacity: selected ? 1 : 0,
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The center blue capture button that opens the full-screen camera.
class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open camera',
      child: GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: const Offset(0, _cameraButtonLift),
          child: Container(
            width: _cameraButtonSize,
            height: _cameraButtonSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.blueHero,
              boxShadow: AppShadows.blueGlow,
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
