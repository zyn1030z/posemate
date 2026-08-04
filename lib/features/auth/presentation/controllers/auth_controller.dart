import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/services/biometric/biometric_service.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Owns the app-wide session: the signed-in user, or null when signed out.
///
/// The async state describes the session only — loading while the stored
/// session is being restored, then data forever after. Individual sign-in
/// attempts are a separate concern: their outcome is returned to the caller
/// as an `AppException?` (null on success) and a failed attempt never moves
/// the session into an error state, so one bad password does not tear down
/// the rest of the app watching this provider.
class AuthController extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final user = await repository.restoreSession();
    if (user == null) {
      return null;
    }
    final lockEnabled =
        ref
            .read(localStorageProvider)
            .get<bool>(
              StorageBox.settings,
              StorageKeys.biometricLock,
              defaultValue: false,
            ) ??
        false;
    if (!lockEnabled) {
      return user;
    }
    final biometrics = ref.read(biometricServiceProvider);
    if (!await biometrics.isSupported) {
      // The lock was enabled on hardware that can no longer verify (sensor
      // removed, permissions revoked); never brick the account behind it.
      return user;
    }
    final unlocked = await biometrics.authenticate(reason: 'Unlock Posely AI');
    if (!unlocked) {
      // Present as signed out WITHOUT clearing tokens: the session survives
      // so the user can retry via an app restart or their password.
      return null;
    }
    return user;
  }

  /// Signs in with email and password.
  ///
  /// Publishes the user and returns null on success; otherwise returns the
  /// failure for the screen to render, leaving the session state untouched.
  Future<AppException?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    return _apply(result);
  }

  /// Creates a new account and signs the user in.
  ///
  /// Publishes the user and returns null on success; otherwise returns the
  /// failure for the screen to render, leaving the session state untouched.
  Future<AppException?> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final result = await _repository.register(
      displayName: displayName,
      email: email,
      password: password,
    );
    return _apply(result);
  }

  /// Signs in through the given social identity provider.
  ///
  /// A user-aborted flow surfaces as a returned `CancelledException`;
  /// screens check the type and stay silent for it. All other failures are
  /// returned for rendering. The session state only changes on success.
  Future<AppException?> signInWithSocial(SocialProvider provider) async {
    final result = await _repository.signInWithSocial(provider);
    return _apply(result);
  }

  /// Starts a local guest session; never fails.
  Future<AppException?> continueAsGuest() async {
    final user = await _repository.signInAsGuest();
    state = AsyncData(user);
    return null;
  }

  /// Requests a password-reset email for the given address.
  ///
  /// Returns null on success or the failure to render; the session state is
  /// never touched.
  Future<AppException?> requestPasswordReset({required String email}) async {
    final result = await _repository.requestPasswordReset(email: email);
    return result.exceptionOrNull;
  }

  /// Ends the current session and publishes the signed-out state.
  Future<AppException?> signOut() async {
    await _repository.signOut();
    state = const AsyncData(null);
    return null;
  }

  /// Enables or disables the biometric gate applied on the next session
  /// restore.
  Future<void> setBiometricLock({required bool enabled}) => ref
      .read(localStorageProvider)
      .put(StorageBox.settings, StorageKeys.biometricLock, enabled);

  /// Publishes a successful sign-in, or hands the failure back to the
  /// caller without disturbing the current session state.
  AppException? _apply(ApiResult<AuthUser> result) {
    switch (result) {
      case ApiSuccess<AuthUser>(:final data):
        state = AsyncData(data);
        return null;
      case ApiFailure<AuthUser>(:final exception):
        return exception;
    }
  }
}

/// The app-wide session: loading while restoring, then the signed-in user
/// as data, with null data meaning signed out.
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

/// Whether a user — including guests — is currently signed in.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider).value != null,
);
