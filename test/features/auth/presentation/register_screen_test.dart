import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/screens/register_screen.dart';

typedef _RegisterCall = ({String displayName, String email, String password});

/// Test double recording calls and returning canned results.
class _FakeAuthController extends AuthController {
  _FakeAuthController({this.registerResult});

  final AppException? registerResult;
  AppException? resetResult;
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
    initialLocation: RoutePaths.register,
    routes: <RouteBase>[
      GoRoute(path: RoutePaths.login, builder: (_, _) => const Placeholder()),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(path: RoutePaths.terms, builder: (_, _) => const Placeholder()),
      GoRoute(path: RoutePaths.privacy, builder: (_, _) => const Placeholder()),
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

Finder _field(int index) => find.byType(TextField).at(index);

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(_field(0), 'Ava Chen');
  await tester.enterText(_field(1), 'ava@posely.ai');
  await tester.enterText(_field(2), 'P0sely!pro');
  await tester.enterText(_field(3), 'P0sely!pro');
}

void main() {
  group('RegisterScreen', () {
    testWidgets('invalid form blocks the controller call with inline errors',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController();
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await tester.enterText(_field(2), 'Passw0rd!');
      await tester.enterText(_field(3), 'Different1!');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(fake.registerCalls, isEmpty);
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('valid form calls register with the exact values',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController();
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(
        fake.registerCalls.single,
        (
          displayName: 'Ava Chen',
          email: 'ava@posely.ai',
          password: 'P0sely!pro',
        ),
      );
    });

    testWidgets('ValidationException field errors land on the email field',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController(
        registerResult: const ValidationException(
          fieldErrors: <String, List<String>>{
            'email': <String>['Email already in use.'],
          },
        ),
      );
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(fake.registerCalls, hasLength(1));
      expect(find.text('Email already in use.'), findsOneWidget);
    });

    testWidgets('strength meter label reacts from weak to strong as typed',
        (tester) async {
      _useTallViewport(tester);
      final fake = _FakeAuthController();
      await tester.pumpWidget(_harness(fake));
      await tester.pumpAndSettle();

      await tester.enterText(_field(2), 'abc');
      await tester.pumpAndSettle();
      expect(find.text('Weak'), findsOneWidget);

      await tester.enterText(_field(2), 'P0sely');
      await tester.pumpAndSettle();
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Weak'), findsNothing);

      await tester.enterText(_field(2), 'P0sely!pro');
      await tester.pumpAndSettle();
      expect(find.text('Strong'), findsOneWidget);
      expect(find.text('Good'), findsNothing);
    });
  });
}
