import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/presentation/screens/onboarding_screen.dart';

void main() {
  void setPhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<InMemoryLocalStorage> pumpOnboarding(WidgetTester tester) async {
    setPhoneSurface(tester);
    final storage = InMemoryLocalStorage();
    final router = GoRouter(
      initialLocation: RoutePaths.onboarding,
      routes: <RouteBase>[
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (BuildContext context, GoRouterState state) =>
              const OnboardingScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('login-stub'))),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(storage),
        ],
        child: MaterialApp.router(
          theme: PoselyTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return storage;
  }

  Future<void> swipeToNextPage(WidgetTester tester) async {
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
  }

  bool? onboardingFlag(InMemoryLocalStorage storage) {
    return storage.get<bool>(
      StorageBox.settings,
      StorageKeys.onboardingComplete,
    );
  }

  group('OnboardingScreen', () {
    testWidgets('swipes through all three pages',
        (WidgetTester tester) async {
      await pumpOnboarding(tester);

      expect(find.text('Find your pose'), findsOneWidget);

      await swipeToNextPage(tester);
      expect(find.text('Shoot with a ghost guide'), findsOneWidget);

      await swipeToNextPage(tester);
      expect(find.text('Let AI coach you'), findsOneWidget);
    });

    testWidgets('skip persists the onboarding flag and routes to login',
        (WidgetTester tester) async {
      final storage = await pumpOnboarding(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(onboardingFlag(storage), isTrue);
      expect(find.text('login-stub'), findsOneWidget);
    });

    testWidgets('Next advances pages and Get started completes the flow',
        (WidgetTester tester) async {
      final storage = await pumpOnboarding(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Shoot with a ghost guide'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Let AI coach you'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(onboardingFlag(storage), isTrue);
      expect(find.text('login-stub'), findsOneWidget);
    });

    testWidgets('dots indicator reflects the current page',
        (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      await pumpOnboarding(tester);

      expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);

      await swipeToNextPage(tester);
      expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);

      await swipeToNextPage(tester);
      expect(find.bySemanticsLabel('Page 3 of 3'), findsOneWidget);

      handle.dispose();
    });
  });
}
