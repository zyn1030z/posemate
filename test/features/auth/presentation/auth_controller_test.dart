import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/services/biometric/biometric_service.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Hand-rolled fake: the real service wraps a platform plugin, and tests
/// only need to script the two outcomes and count prompt attempts.
class _FakeBiometricService implements BiometricService {
  bool supported = false;
  bool authenticateResult = true;
  int authenticateCalls = 0;

  @override
  Future<bool> get isSupported async => supported;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    return authenticateResult;
  }
}

void main() {
  group('AuthController', () {
    late _MockAuthRepository repository;
    late InMemoryLocalStorage storage;
    late _FakeBiometricService biometrics;
    late ProviderContainer container;
    // A convenient concrete instance; the controller never inspects isGuest.
    late AuthUser user;

    setUp(() {
      repository = _MockAuthRepository();
      storage = InMemoryLocalStorage();
      biometrics = _FakeBiometricService();
      user = AuthUser.guest();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          localStorageProvider.overrideWithValue(storage),
          biometricServiceProvider.overrideWithValue(biometrics),
          talkerProvider.overrideWithValue(Talker()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('build restores an existing session', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => user);

      final restored = await container.read(authControllerProvider.future);

      expect(restored, user);
      expect(container.read(authControllerProvider).value, user);
      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    test('build yields signed out when no session is stored', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);

      final restored = await container.read(authControllerProvider.future);

      expect(restored, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(biometrics.authenticateCalls, 0);
    });

    test('signInWithEmail success publishes the user and returns null',
        () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);
      when(
        () => repository.signInWithEmail(
          email: 'ana@posely.app',
          password: 'secret',
        ),
      ).thenAnswer((_) async => ApiSuccess<AuthUser>(user));
      await container.read(authControllerProvider.future);

      final error = await container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'ana@posely.app', password: 'secret');

      expect(error, isNull);
      expect(container.read(authControllerProvider).value, user);
      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    test('failed sign-in returns the exception and keeps signed-out data',
        () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);
      when(
        () => repository.signInWithEmail(
          email: 'ana@posely.app',
          password: 'wrong',
        ),
      ).thenAnswer(
        (_) async => const ApiFailure<AuthUser>(UnauthorizedException()),
      );
      await container.read(authControllerProvider.future);

      final error = await container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'ana@posely.app', password: 'wrong');

      expect(error, isA<UnauthorizedException>());
      final state = container.read(authControllerProvider);
      // The attempt failed, but the session state stays plain data(null) —
      // a bad password must not put the app-wide session into error.
      expect(state.hasError, isFalse);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
    });

    test('cancelled social sign-in returns CancelledException silently',
        () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);
      when(() => repository.signInWithSocial(SocialProvider.google)).thenAnswer(
        (_) async => const ApiFailure<AuthUser>(CancelledException()),
      );
      await container.read(authControllerProvider.future);

      final error = await container
          .read(authControllerProvider.notifier)
          .signInWithSocial(SocialProvider.google);

      expect(error, isA<CancelledException>());
      expect(container.read(authControllerProvider).value, isNull);
    });

    test('continueAsGuest publishes a guest session', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);
      when(() => repository.signInAsGuest()).thenAnswer((_) async => user);
      await container.read(authControllerProvider.future);

      final notifier = container.read(authControllerProvider.notifier);
      final error = await notifier.continueAsGuest();

      expect(error, isNull);
      expect(container.read(authControllerProvider).value, user);
    });

    test('signOut clears the session back to signed-out data', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => user);
      when(() => repository.signOut()).thenAnswer((_) async {});
      await container.read(authControllerProvider.future);

      final error =
          await container.read(authControllerProvider.notifier).signOut();

      expect(error, isNull);
      verify(() => repository.signOut()).called(1);
      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
    });

    test('denied biometric gate hides the session without clearing tokens',
        () async {
      await storage.put(StorageBox.settings, StorageKeys.biometricLock, true);
      biometrics
        ..supported = true
        ..authenticateResult = false;
      when(() => repository.restoreSession()).thenAnswer((_) async => user);

      final restored = await container.read(authControllerProvider.future);

      expect(restored, isNull);
      expect(biometrics.authenticateCalls, 1);
      // Tokens survive a denied prompt: the user retries via app restart
      // or password, so sign-out must never have been triggered.
      verifyNever(() => repository.signOut());
    });

    test('passed biometric gate restores the session', () async {
      await storage.put(StorageBox.settings, StorageKeys.biometricLock, true);
      biometrics
        ..supported = true
        ..authenticateResult = true;
      when(() => repository.restoreSession()).thenAnswer((_) async => user);

      final restored = await container.read(authControllerProvider.future);

      expect(restored, user);
      expect(biometrics.authenticateCalls, 1);
    });

    test('biometric gate is skipped on unsupported hardware', () async {
      await storage.put(StorageBox.settings, StorageKeys.biometricLock, true);
      biometrics.supported = false;
      when(() => repository.restoreSession()).thenAnswer((_) async => user);

      final restored = await container.read(authControllerProvider.future);

      expect(restored, user);
      expect(biometrics.authenticateCalls, 0);
    });

    test('setBiometricLock persists the flag', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);

      await container
          .read(authControllerProvider.notifier)
          .setBiometricLock(enabled: true);

      expect(
        storage.get<bool>(StorageBox.settings, StorageKeys.biometricLock),
        isTrue,
      );
    });
  });
}
