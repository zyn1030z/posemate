import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/screens/forgot_password_screen.dart';

typedef _RegisterCall = ({String displayName, String email, String password});

/// Test double recording calls and returning canned results.
class _FakeAuthController extends AuthController {
  _FakeAuthController({this.resetResult});

  AppException? registerResult;
  final AppException? resetResult;
  final List<_RegisterCall> registerCalls = <_RegisterCall>[];
  final List<String> resetCalls = <String>[];

  // `Never?` keeps the initial-state override compatible with `AuthUser?`
  // without coupling the test to the entity import.
  @override
  Future<Never?> build() async => null;

  @override
  Future<AppException?> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    registerCalls.add(
      (displayName: displayName, email: email, password: password),
    );
    return registerResult;
  }

  @override
  Future<AppException?> requestPasswordReset({required String email}) async {
    resetCalls.add(email);
    return resetResult;
  }
}

Widget _harness(_FakeAuthController fake) {
  final router = GoRouter(
    initialLocation: RoutePaths.forgotPassword,
    routes: <RouteBase>[
      GoRoute(path: RoutePaths.login, builder: (_, _) => const Placeholder()),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [authControllerProvider.overrideWith(() => fake)],
    child: MaterialApp.router(theme: PoselyTheme.dark(), routerConfig: router),
  );
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(720, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _submitEmail(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextField), email);
  await tester.tap(find.text('Send reset link'));
  await tester.pumpAndSettle();
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('valid email calls the controller and shows the sent phase',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController();
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await _submitEmail(tester, 'mia@posely.ai');

      expect(fake.resetCalls, <String>['mia@posely.ai']);
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(find.textContaining('mia@posely.ai'), findsOneWidget);
      expect(find.textContaining('Resend in'), findsOneWidget);
      expect(find.text('Send reset link'), findsNothing);

      // Unmount the screen so the resend countdown timer is disposed.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('countdown unlocks a resend that re-fires the request',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController();
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await _submitEmail(tester, 'mia@posely.ai');

      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('Resend email'), findsOneWidget);

      await tester.tap(find.text('Resend email'));
      await tester.pump();
      await tester.pump();

      expect(fake.resetCalls, <String>['mia@posely.ai', 'mia@posely.ai']);
      expect(find.textContaining('Resend in'), findsOneWidget);

      // Unmount the screen so the restarted countdown timer is disposed.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('server failure stays on the form and shows an error toast',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController(resetResult: const ServerException());
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'mia@posely.ai');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      await tester.pump();

      expect(fake.resetCalls, <String>['mia@posely.ai']);
      expect(find.text('Check your inbox'), findsNothing);
      expect(find.text('Send reset link'), findsOneWidget);
      expect(
        find.text(
          'Something went wrong on our side. Please try again shortly.',
        ),
        findsOneWidget,
      );

      // Let the toast hold, dismiss, and remove itself.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
