import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/inputs/posely_text_field.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:posely_ai/features/auth/presentation/widgets/social_auth_button.dart';

/// Fake controller that records calls and returns canned results
/// without touching the auth repository.
class _FakeAuthController extends AuthController {
  _FakeAuthController({this.emailResult});

  final AppException? emailResult;
  AppException? socialResult;
  AppException? guestResult;

  final List<({String email, String password})> emailCalls =
      <({String email, String password})>[];
  final List<SocialProvider> socialCalls = <SocialProvider>[];
  int guestCalls = 0;

  @override
  Future<AuthUser?> build() async => null;

  @override
  Future<AppException?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emailCalls.add((email: email, password: password));
    return emailResult;
  }

  @override
  Future<AppException?> signInWithSocial(SocialProvider provider) async {
    socialCalls.add(provider);
    return socialResult;
  }

  @override
  Future<AppException?> continueAsGuest() async {
    guestCalls++;
    return guestResult;
  }
}

void main() {
  void setPhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpLogin(
    WidgetTester tester,
    _FakeAuthController fake,
  ) async {
    setPhoneSurface(tester);
    final router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: <RouteBase>[
        GoRoute(
          path: RoutePaths.login,
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.register,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('register-stub'))),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('forgot-stub'))),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => fake),
        ],
        child: MaterialApp.router(
          theme: PoselyTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps through a full toast lifecycle so no timers stay pending.
  Future<void> drainToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  Future<void> enterCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), password);
  }

  group('LoginScreen', () {
    testWidgets('renders lockup, fields, and action buttons',
        (WidgetTester tester) async {
      final fake = _FakeAuthController();
      await pumpLogin(tester, fake);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(PoselyTextField), findsNWidgets(2));
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.byType(SocialAuthButton), findsNWidgets(3));
      expect(find.text('Continue as guest'), findsOneWidget);
    });

    testWidgets('invalid email shows validator message without calling '
        'the controller', (WidgetTester tester) async {
      final fake = _FakeAuthController();
      await pumpLogin(tester, fake);

      await enterCredentials(
        tester,
        email: 'not-an-email',
        password: 'password1',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(fake.emailCalls, isEmpty);
    });

    testWidgets('valid submit calls signInWithEmail once with the '
        'entered values', (WidgetTester tester) async {
      final fake = _FakeAuthController();
      await pumpLogin(tester, fake);

      await enterCredentials(
        tester,
        email: 'pose@posely.ai',
        password: 'password1',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(fake.emailCalls, hasLength(1));
      expect(fake.emailCalls.single.email, 'pose@posely.ai');
      expect(fake.emailCalls.single.password, 'password1');
    });

    testWidgets('sign-in failure surfaces the user message as a toast',
        (WidgetTester tester) async {
      final fake = _FakeAuthController(emailResult: const NetworkException());
      await pumpLogin(tester, fake);

      await enterCredentials(
        tester,
        email: 'pose@posely.ai',
        password: 'password1',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text(const NetworkException().userMessage), findsOneWidget);

      await drainToast(tester);
    });

    testWidgets('guest button calls continueAsGuest',
        (WidgetTester tester) async {
      final fake = _FakeAuthController();
      await pumpLogin(tester, fake);

      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();

      expect(fake.guestCalls, 1);
    });
  });
}
