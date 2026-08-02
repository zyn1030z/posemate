import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Fullscreen branded splash shown while the app decides where to go first.
///
/// Plays the brand entrance (aperture mark scale-in with glow, wordmark
/// fade-slide, caption fade) while holding for at least the minimum splash
/// duration, then routes based on persisted first-run state and the
/// restored auth session: onboarding first, then home or login.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// Mirrors the pubspec version; replaced by package_info_plus once the
  /// about screen lands and the value is needed in more than one place.
  static const String _version = '0.1.0';

  @override
  void initState() {
    super.initState();
    unawaited(_decideNext());
  }

  Future<void> _decideNext() async {
    // Grabbed up front: the Talker instance stays usable for logging even
    // if the router unmounts this screen mid-await, unlike ref itself.
    final talker = ref.read(talkerProvider);
    // Hold the brand moment even on fast devices while session restore
    // (and its optional biometric gate) runs in parallel.
    final minHold = Future<void>.delayed(AppConstants.minSplashDuration);

    final user = await _restoreSession(talker);
    await minHold;
    if (!mounted) return;

    final onboardingComplete = ref.read(localStorageProvider).get<bool>(
          StorageBox.settings,
          StorageKeys.onboardingComplete,
          defaultValue: false,
        ) ??
        false;
    talker.debug(
      'Splash resolved (onboardingComplete=$onboardingComplete, '
      'signedIn=${user != null})',
    );

    if (!mounted) return;
    if (!onboardingComplete) {
      context.go(RoutePaths.onboarding);
    } else if (user != null) {
      context.go(RoutePaths.home);
    } else {
      context.go(RoutePaths.login);
    }
  }

  /// Resolves with the auth controller's first non-loading state: the
  /// restored session, or null when signed out, biometric-locked, or the
  /// restore failed outright.
  Future<AuthUser?> _restoreSession(Talker talker) async {
    try {
      return await ref.read(authControllerProvider.future);
    } catch (error, stackTrace) {
      // A failed restore counts as signed out; login owns recovery.
      talker.error('Splash: session restore failed', error, stackTrace);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final caption = config.flavor.isProd
        ? 'v$_version'
        : 'v$_version · ${config.flavor.label}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle emerald aurora rising behind the mark.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 1.1,
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 64,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const PoselyLogo(size: 132),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: AppDurations.slow,
                      curve: AppDurations.easeOutExpo,
                    )
                    .fadeIn(duration: AppDurations.base),
                const SizedBox(height: AppSpacing.lg),
                const PoselyWordmark(fontSize: 34)
                    .animate()
                    .fadeIn(
                      delay: AppDurations.fast,
                      duration: AppDurations.base,
                    )
                    .slideY(
                      begin: 0.35,
                      end: 0,
                      delay: AppDurations.fast,
                      duration: AppDurations.slow,
                      curve: AppDurations.easeOutExpo,
                    ),
                const Spacer(flex: 3),
                Text(
                  caption,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.posely.textMuted,
                    letterSpacing: 0.4,
                  ),
                ).animate().fadeIn(
                      delay: AppDurations.base,
                      duration: AppDurations.slow,
                    ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
