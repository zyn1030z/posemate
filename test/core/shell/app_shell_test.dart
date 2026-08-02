import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/config/flavor.dart';
import 'package:posely_ai/core/router/app_router.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/shell/app_shell.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Pumps the real app router with a restored guest session and
/// onboarding complete, so boot lands on the shell's home branch.
Future<ProviderContainer> _pumpSignedInApp(WidgetTester tester) async {
  final repository = _MockAuthRepository();
  when(repository.restoreSession).thenAnswer((_) async => AuthUser.guest());

  final storage = InMemoryLocalStorage();
  await storage.put(StorageBox.settings, StorageKeys.onboardingComplete, true);

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.forFlavor(Flavor.dev)),
      localStorageProvider.overrideWithValue(storage),
      talkerProvider.overrideWithValue(TalkerFlutter.init()),
      authRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: PoselyTheme.dark(),
        routerConfig: container.read(appRouterProvider),
      ),
    ),
  );
  return container;
}

/// Flushes the splash minimum hold plus the resulting navigation frames.
/// Intentionally NOT pumpAndSettle: branch screens may run entrance
/// animations or surface async error states of their own.
Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pump(AppConstants.minSplashDuration);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Flushes a navigation triggered mid-test plus its transition frames.
Future<void> _pumpNavigation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  // These tests assert router locations and shell chrome only; branch
  // screen internals belong to their owning features' tests.
  group('app shell', () {
    testWidgets('signed-in boot shows the glass bar on the home branch',
        (tester) async {
      final container = await _pumpSignedInApp(tester);
      final router = container.read(appRouterProvider);

      await _pumpPastSplash(tester);

      expect(router.state.matchedLocation, RoutePaths.home);
      expect(find.byType(AppShell), findsOneWidget);

      // Home is the active tab, so its rounded variant renders; the
      // other tabs sit in their inactive variants around the camera.
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
    });

    testWidgets('tapping the Poses item switches to the library branch',
        (tester) async {
      final container = await _pumpSignedInApp(tester);
      final router = container.read(appRouterProvider);

      await _pumpPastSplash(tester);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await _pumpNavigation(tester);

      expect(router.state.matchedLocation, RoutePaths.poseLibrary);
      // The bar persists across branch switches.
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('camera button pushes the full-screen route and pops back',
        (tester) async {
      final container = await _pumpSignedInApp(tester);
      final router = container.read(appRouterProvider);

      await _pumpPastSplash(tester);
      expect(router.state.matchedLocation, RoutePaths.home);

      await tester.tap(find.byIcon(Icons.photo_camera_rounded));
      await _pumpNavigation(tester); // Bottom sheet animation

      // Tap 'AI Camera Viewfinder' in the bottom sheet
      await tester.tap(find.text('AI Camera Viewfinder'));
      await _pumpNavigation(tester); // Push to camera

      expect(router.state.matchedLocation, RoutePaths.camera);

      router.pop();
      await _pumpNavigation(tester);

      expect(router.state.matchedLocation, RoutePaths.home);
    });
  });
}
