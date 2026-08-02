import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/router/route_error_screen.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/shared/widgets/coming_soon_screen.dart';
import 'package:posely_ai/core/shell/app_shell.dart';
import 'package:posely_ai/features/ai/presentation/screens/pose_generator_screen.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:posely_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:posely_ai/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:posely_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:posely_ai/features/camera/presentation/screens/camera_screen.dart';
import 'package:posely_ai/features/extraction/presentation/screens/upload_pose_screen.dart';
import 'package:posely_ai/features/home/presentation/screens/home_screen.dart';
import 'package:posely_ai/features/pose/presentation/screens/pose_detail_screen.dart';
import 'package:posely_ai/features/pose/presentation/screens/pose_library_screen.dart';
import 'package:posely_ai/features/pose/presentation/screens/pose_search_screen.dart';
import 'package:posely_ai/features/settings/presentation/screens/design_gallery_screen.dart';
import 'package:posely_ai/features/splash/presentation/screens/splash_screen.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Routes a signed-out user may visit besides splash; everything else
/// redirects to login until a session exists.
const Set<String> _authFlowPaths = {
  RoutePaths.onboarding,
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
};

/// Ticks whenever the auth session changes so GoRouter re-runs its redirect.
///
/// The router takes this as its `refreshListenable`; appRouterProvider bumps
/// the value from a `ref.listen` on the auth controller. Kept as a separate
/// provider so the notifier's lifetime is managed by Riverpod (disposed with
/// the container) rather than by the router.
final routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Provides the app-wide `GoRouter` instance.
///
/// Route diagnostics are logged in the dev flavor and every navigation is
/// mirrored into Talker via a route observer, so the in-app log console
/// shows the full navigation history.
///
/// ── Route rollout map ──────────────────────────────────────────────────
/// Paths for all of these are already reserved in RoutePaths; routes are
/// registered here as the owning feature lands.
///
/// PHASE-5: search ✅, collections ✅.
/// PHASE-6: generate, upload — AI pose generator and custom uploads.
/// PHASE-8: camera — realtime AI coaching viewfinder.
/// PHASE-9: gallery, gallery/:photoId.
/// PHASE-10: profile, settings, notifications, about, feedback, privacy,
///           terms.
/// PHASE-11: community feed.
/// PHASE-12: premium paywall (redirect gate on premium-only routes).
final appRouterProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(appConfigProvider);
  final talker = ref.watch(talkerProvider);

  // Bump the refresh notifier on every session change; subscribing here
  // also kicks off the auth controller, so session restore begins the
  // moment the router exists.
  final refresh = ref.watch(routerRefreshProvider);
  ref.listen(authControllerProvider, (previous, next) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: config.flavor.isDev,
    observers: [TalkerRouteObserver(talker)],
    refreshListenable: refresh,
    // Auth guard. Decision table (row: session state, column: target):
    //
    //                | splash | auth flow*  | anything else |
    //  loading       | stay   | -> splash   | -> splash     |
    //  signed out    | stay   | stay        | -> login      |
    //  signed in     | -> home| -> home     | stay          |
    //
    //  *auth flow: onboarding, login, register, forgot-password.
    //  While restoring, splash owns the waiting UX. designGallery falls
    //  under "anything else", so it stays reachable only when signed in.
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final onAuthFlow = _authFlowPaths.contains(location);
      final onSplash = location == RoutePaths.splash;

      if (auth.isLoading) {
        return onSplash ? null : RoutePaths.splash;
      }
      final signedIn = auth.value != null;
      if (!signedIn) {
        return onSplash || onAuthFlow ? null : RoutePaths.login;
      }
      return onSplash || onAuthFlow ? RoutePaths.home : null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Tabbed shell: each branch keeps its own navigation stack while
      // the floating glass bar persists across them. Branch order maps
      // to the bar: 0 home, 1 poses, 2 gallery, 3 profile.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.poseLibrary,
                name: RouteNames.poseLibrary,
                builder: (context, state) => const PoseLibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              // PHASE-10: replaced by the real captured-photos gallery.
              GoRoute(
                path: RoutePaths.gallery,
                name: RouteNames.gallery,
                builder: (context, state) => const ComingSoonScreen(
                  title: 'Your Gallery',
                  phase: 'Phase 10',
                  icon: Icons.photo_library_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              // PHASE-12: replaced by the real profile screen.
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ComingSoonScreen(
                  title: 'Your Profile',
                  phase: 'Phase 12',
                  icon: Icons.person_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
      // Top-level so the detail view pushes full-screen over the glass
      // bar instead of rendering inside the poses branch.
      GoRoute(
        path: RoutePaths.poseDetail,
        name: RouteNames.poseDetail,
        builder: (context, state) => PoseDetailScreen(
          poseId: state.pathParameters['poseId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => PoseSearchScreen(
          initialQuery: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(
        path: RoutePaths.poseGenerator,
        name: RouteNames.poseGenerator,
        builder: (context, state) => const PoseGeneratorScreen(),
      ),
      GoRoute(
        path: RoutePaths.uploadPose,
        name: RouteNames.uploadPose,
        builder: (context, state) => const UploadPoseScreen(),
      ),
      // PHASE-8: Real camera experience.
      GoRoute(
        path: RoutePaths.camera,
        name: RouteNames.camera,
        builder: (context, state) => CameraScreen(
          poseId: state.uri.queryParameters['poseId'],
        ),
      ),
      // Dev-only design-system showcase; reached via
      // context.go(RoutePaths.designGallery) — never linked in production UI.
      GoRoute(
        path: RoutePaths.designGallery,
        name: RouteNames.designGallery,
        builder: (context, state) => const DesignGalleryScreen(),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(error: state.error),
  );
  ref.onDispose(router.dispose);
  return router;
});
