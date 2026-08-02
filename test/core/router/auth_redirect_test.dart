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
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/splash/presentation/screens/splash_screen.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Pumps the real app router inside a themed MaterialApp, with onboarding
/// already completed so splash branches purely on the session state.
Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required AuthRepository repository,
}) async {
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
/// Intentionally NOT pumpAndSettle: screens may run entrance animations.
Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pump(AppConstants.minSplashDuration);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  group('auth redirect', () {
    testWidgets('signed-out sessions land on login after splash',
        (tester) async {
      final repository = _MockAuthRepository();
      when(repository.restoreSession).thenAnswer((_) async => null);

      final container = await _pumpApp(tester, repository: repository);
      final router = container.read(appRouterProvider);

      // Splash owns the boot frame while the session restores.
      expect(find.byType(SplashScreen), findsOneWidget);

      await _pumpPastSplash(tester);

      expect(router.state.matchedLocation, RoutePaths.login);
    });

    testWidgets('restored sessions land on home', (tester) async {
      final repository = _MockAuthRepository();
      when(repository.restoreSession)
          .thenAnswer((_) async => AuthUser.guest());

      final container = await _pumpApp(tester, repository: repository);
      final router = container.read(appRouterProvider);

      await _pumpPastSplash(tester);

      expect(router.state.matchedLocation, RoutePaths.home);
    });

    testWidgets('signOut pushes the app back to login', (tester) async {
      final repository = _MockAuthRepository();
      when(repository.restoreSession)
          .thenAnswer((_) async => AuthUser.guest());
      when(repository.signOut).thenAnswer((_) async {});

      final container = await _pumpApp(tester, repository: repository);
      final router = container.read(appRouterProvider);

      await _pumpPastSplash(tester);
      expect(router.state.matchedLocation, RoutePaths.home);

      await container.read(authControllerProvider.notifier).signOut();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(router.state.matchedLocation, RoutePaths.login);
    });
  });
}
