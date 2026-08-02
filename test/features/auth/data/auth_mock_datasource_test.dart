import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';

void main() {
  late AuthMockDatasource datasource;

  setUp(() {
    datasource = AuthMockDatasource(latency: () => Duration.zero);
  });

  group('signInWithEmail', () {
    test('signs in the seeded demo account', () async {
      final response = await datasource.signInWithEmail(
        email: AuthMockDatasource.demoEmail,
        password: AuthMockDatasource.demoPassword,
      );

      expect(response.user.email, AuthMockDatasource.demoEmail);
      expect(response.user.displayName, 'Demo Creator');
      expect(response.user.avatarUrl, isNull);
      expect(response.user.isPremium, isTrue);
      expect(response.accessToken, startsWith('mock_access_'));
      expect(response.refreshToken, startsWith('mock_refresh_'));
    });

    test('throws UnauthorizedException for a wrong password', () {
      expect(
        () => datasource.signInWithEmail(
          email: AuthMockDatasource.demoEmail,
          password: 'wrong-password',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('throws UnauthorizedException for an unknown email', () {
      expect(
        () => datasource.signInWithEmail(
          email: 'nobody@posely.app',
          password: 'whatever1',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('issues a fresh token pair per sign-in', () async {
      final first = await datasource.signInWithEmail(
        email: AuthMockDatasource.demoEmail,
        password: AuthMockDatasource.demoPassword,
      );
      final second = await datasource.signInWithEmail(
        email: AuthMockDatasource.demoEmail,
        password: AuthMockDatasource.demoPassword,
      );

      expect(first.accessToken, isNot(second.accessToken));
    });
  });

  group('register', () {
    test('throws ConflictException for an already-registered email', () {
      expect(
        () => datasource.register(
          displayName: 'Impostor',
          email: AuthMockDatasource.demoEmail,
          password: 'hunter22!',
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('creates an account that can subsequently sign in', () async {
      final registered = await datasource.register(
        displayName: 'New Creator',
        email: 'new@posely.app',
        password: 'hunter22!',
      );

      expect(registered.user.displayName, 'New Creator');
      expect(registered.user.email, 'new@posely.app');
      expect(registered.user.isPremium, isFalse);

      final signedIn = await datasource.signInWithEmail(
        email: 'new@posely.app',
        password: 'hunter22!',
      );
      expect(signedIn.user.id, registered.user.id);
    });
  });

  group('requestPasswordReset', () {
    test('always completes, even for unknown emails', () async {
      await expectLater(
        datasource.requestPasswordReset(email: 'nobody@posely.app'),
        completes,
      );
    });
  });

  group('socialLogin', () {
    test('returns a provider-branded user', () async {
      final response = await datasource.socialLogin(
        provider: SocialProvider.google,
        idToken: 'fake-id-token',
      );

      expect(response.user.email, 'google.user@posely.app');
      expect(response.user.displayName, 'Google Creator');
      expect(response.accessToken, startsWith('mock_access_'));
    });

    test('reuses the same identity across repeat sign-ins', () async {
      final first = await datasource.socialLogin(
        provider: SocialProvider.apple,
        idToken: 'token-a',
      );
      final second = await datasource.socialLogin(
        provider: SocialProvider.apple,
        idToken: 'token-b',
      );

      expect(first.user.id, second.user.id);
    });
  });

  group('latency injection', () {
    test('zero-latency calls resolve well under the default floor', () async {
      final stopwatch = Stopwatch()..start();
      await datasource.signInWithEmail(
        email: AuthMockDatasource.demoEmail,
        password: AuthMockDatasource.demoPassword,
      );
      stopwatch.stop();

      // The default latency floor is 350 ms; zero-latency injection must
      // come in far below it.
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });
  });
}
