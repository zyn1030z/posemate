import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/storage/secure_storage.dart';
import 'package:posely_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:posely_ai/features/auth/data/models/auth_response_model.dart';
import 'package:posely_ai/features/auth/data/models/auth_user_model.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/data/services/social_auth_service.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class _MockSocialAuthService extends Mock implements SocialAuthService {}

class _MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

class _MockTalker extends Mock implements Talker {}

void main() {
  const userModel = AuthUserModel(
    id: 'u_1',
    email: 'user@example.com',
    displayName: 'Minh',
  );
  const response = AuthResponseModel(
    user: userModel,
    accessToken: 'access_1',
    refreshToken: 'refresh_1',
  );

  late _MockRemoteDatasource remote;
  late _MockSocialAuthService social;
  late _MockSecureTokenStorage tokenStorage;
  late InMemoryLocalStorage localStorage;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(SocialProvider.google);
  });

  setUp(() {
    remote = _MockRemoteDatasource();
    social = _MockSocialAuthService();
    tokenStorage = _MockSecureTokenStorage();
    localStorage = InMemoryLocalStorage();
    repository = AuthRepositoryImpl(
      remoteDatasource: remote,
      socialAuthService: social,
      tokenStorage: tokenStorage,
      localStorage: localStorage,
      talker: _MockTalker(),
    );

    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
  });

  group('signInWithEmail', () {
    test('persists tokens, profile, and ends any guest session', () async {
      await localStorage.put(
        StorageBox.settings,
        StorageKeys.authIsGuest,
        true,
      );
      when(
        () => remote.signInWithEmail(
          email: 'user@example.com',
          password: 'hunter22!',
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.signInWithEmail(
        email: 'user@example.com',
        password: 'hunter22!',
      );

      expect(result, isA<ApiSuccess<AuthUser>>());
      final user = result.dataOrNull;
      expect(user?.id, 'u_1');
      expect(user?.displayName, 'Minh');
      expect(user?.isGuest, isFalse);

      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access_1',
          refreshToken: 'refresh_1',
        ),
      ).called(1);
      final profile = localStorage.get<Map<dynamic, dynamic>>(
        StorageBox.settings,
        StorageKeys.authUserProfile,
      );
      expect(profile, isNotNull);
      expect(profile?['email'], 'user@example.com');
      expect(profile?['display_name'], 'Minh');
      expect(
        localStorage.contains(StorageBox.settings, StorageKeys.authIsGuest),
        isFalse,
      );
    });

    test('maps a datasource failure to ApiFailure', () async {
      when(
        () => remote.signInWithEmail(
          email: 'user@example.com',
          password: 'wrong',
        ),
      ).thenThrow(const UnauthorizedException());

      final result = await repository.signInWithEmail(
        email: 'user@example.com',
        password: 'wrong',
      );

      expect(result.exceptionOrNull, isA<UnauthorizedException>());
      verifyNever(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
      expect(
        localStorage.contains(
          StorageBox.settings,
          StorageKeys.authUserProfile,
        ),
        isFalse,
      );
    });
  });

  group('register', () {
    test('persists the new session on success', () async {
      when(
        () => remote.register(
          displayName: 'Minh',
          email: 'user@example.com',
          password: 'hunter22!',
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.register(
        displayName: 'Minh',
        email: 'user@example.com',
        password: 'hunter22!',
      );

      expect(result.dataOrNull?.email, 'user@example.com');
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access_1',
          refreshToken: 'refresh_1',
        ),
      ).called(1);
    });
  });

  group('requestPasswordReset', () {
    test('returns success when the datasource completes', () async {
      when(
        () => remote.requestPasswordReset(email: 'user@example.com'),
      ).thenAnswer((_) async {});

      final result = await repository.requestPasswordReset(
        email: 'user@example.com',
      );

      expect(result.isSuccess, isTrue);
    });
  });

  group('guest flow', () {
    test('sets the guest flag and returns the guest identity', () async {
      final user = await repository.signInAsGuest();

      expect(user, AuthUser.guest());
      expect(
        localStorage.get<bool>(StorageBox.settings, StorageKeys.authIsGuest),
        isTrue,
      );
    });
  });

  group('signOut', () {
    test('clears tokens, profile, and guest flag', () async {
      await localStorage.put(
        StorageBox.settings,
        StorageKeys.authUserProfile,
        <String, Object?>{'id': 'u_1'},
      );
      await localStorage.put(
        StorageBox.settings,
        StorageKeys.authIsGuest,
        true,
      );

      await repository.signOut();

      verify(() => tokenStorage.clearTokens()).called(1);
      expect(
        localStorage.contains(
          StorageBox.settings,
          StorageKeys.authUserProfile,
        ),
        isFalse,
      );
      expect(
        localStorage.contains(StorageBox.settings, StorageKeys.authIsGuest),
        isFalse,
      );
    });

    test('never throws even when token clearing fails', () async {
      when(() => tokenStorage.clearTokens()).thenThrow(Exception('keychain'));

      await expectLater(repository.signOut(), completes);
    });
  });

  group('restoreSession', () {
    test('returns the guest identity when the guest flag is set', () async {
      await localStorage.put(
        StorageBox.settings,
        StorageKeys.authIsGuest,
        true,
      );

      final user = await repository.restoreSession();

      expect(user, AuthUser.guest());
    });

    test('returns null when no access token is stored', () async {
      when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);

      expect(await repository.restoreSession(), isNull);
    });

    test('restores the user from the stored profile', () async {
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => 'access_1');
      await localStorage.put(
        StorageBox.settings,
        StorageKeys.authUserProfile,
        <String, Object?>{
          'id': 'u_1',
          'email': 'user@example.com',
          'display_name': 'Minh',
          'is_premium': true,
        },
      );

      final user = await repository.restoreSession();

      expect(user?.id, 'u_1');
      expect(user?.displayName, 'Minh');
      expect(user?.isPremium, isTrue);
      expect(user?.isGuest, isFalse);
    });

    test(
      'clears tokens and returns null when the profile is missing',
      () async {
        when(
          () => tokenStorage.readAccessToken(),
        ).thenAnswer((_) async => 'access_1');

        final user = await repository.restoreSession();

        expect(user, isNull);
        verify(() => tokenStorage.clearTokens()).called(1);
      },
    );
  });

  group('signInWithSocial', () {
    test('exchanges the provider token and persists the session', () async {
      when(
        () => social.fetchIdToken(SocialProvider.google),
      ).thenAnswer((_) async => 'provider-token');
      when(
        () => remote.socialLogin(
          provider: SocialProvider.google,
          idToken: 'provider-token',
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.signInWithSocial(SocialProvider.google);

      expect(result.dataOrNull?.id, 'u_1');
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access_1',
          refreshToken: 'refresh_1',
        ),
      ).called(1);
    });

    test('surfaces a user cancel as ApiFailure(CancelledException)', () async {
      when(
        () => social.fetchIdToken(SocialProvider.apple),
      ).thenThrow(const CancelledException());

      final result = await repository.signInWithSocial(SocialProvider.apple);

      expect(result.exceptionOrNull, isA<CancelledException>());
      verifyNever(
        () => remote.socialLogin(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
        ),
      );
    });
  });
}
