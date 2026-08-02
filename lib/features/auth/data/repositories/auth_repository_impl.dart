import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/dio_client.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/storage/secure_storage.dart';
import 'package:posely_ai/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:posely_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:posely_ai/features/auth/data/models/auth_response_model.dart';
import 'package:posely_ai/features/auth/data/models/auth_user_model.dart';
import 'package:posely_ai/features/auth/data/services/social_auth_service.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Concrete auth repository wiring the remote datasource, social SDK seam,
/// and both storage layers together.
///
/// Session persistence model: tokens live in secure storage, the profile
/// snapshot lives as a JSON map in the settings box, and guest mode is a
/// plain boolean flag with no tokens at all.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository with its collaborators.
  AuthRepositoryImpl({
    required this._remoteDatasource,
    required this._socialAuthService,
    required this._tokenStorage,
    required this._localStorage,
    required this._talker,
  });

  final AuthRemoteDatasource _remoteDatasource;
  final SocialAuthService _socialAuthService;
  final SecureTokenStorage _tokenStorage;
  final LocalStorage _localStorage;
  final Talker _talker;

  @override
  Future<ApiResult<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) => guardApi(() async {
    final response = await _remoteDatasource.signInWithEmail(
      email: email,
      password: password,
    );
    return _persistSession(response);
  });

  @override
  Future<ApiResult<AuthUser>> register({
    required String displayName,
    required String email,
    required String password,
  }) => guardApi(() async {
    final response = await _remoteDatasource.register(
      displayName: displayName,
      email: email,
      password: password,
    );
    return _persistSession(response);
  });

  @override
  Future<ApiResult<void>> requestPasswordReset({required String email}) =>
      guardApi(() => _remoteDatasource.requestPasswordReset(email: email));

  @override
  Future<ApiResult<AuthUser>> signInWithSocial(SocialProvider provider) =>
      guardApi(() async {
        // A cancelled SDK flow throws CancelledException here, which guardApi
        // surfaces as ApiFailure(CancelledException) for screens to ignore.
        final idToken = await _socialAuthService.fetchIdToken(provider);
        final response = await _remoteDatasource.socialLogin(
          provider: provider,
          idToken: idToken,
        );
        return _persistSession(response);
      });

  @override
  Future<AuthUser> signInAsGuest() async {
    await _localStorage.put(
      StorageBox.settings,
      StorageKeys.authIsGuest,
      true,
    );
    return AuthUser.guest();
  }

  @override
  Future<void> signOut() async {
    try {
      await _tokenStorage.clearTokens();
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthRepository: failed to clear tokens on sign-out',
        error,
        stackTrace,
      );
    }
    try {
      await _localStorage.delete(
        StorageBox.settings,
        StorageKeys.authUserProfile,
      );
      await _localStorage.delete(
        StorageBox.settings,
        StorageKeys.authIsGuest,
      );
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthRepository: failed to clear local session on sign-out',
        error,
        stackTrace,
      );
    }
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final isGuest = _localStorage.get<bool>(
      StorageBox.settings,
      StorageKeys.authIsGuest,
      defaultValue: false,
    );
    if (isGuest ?? false) {
      return AuthUser.guest();
    }

    final String? accessToken;
    try {
      accessToken = await _tokenStorage.readAccessToken();
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthRepository: failed to read access token during restore',
        error,
        stackTrace,
      );
      return null;
    }
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final raw = _localStorage.get<Map<dynamic, dynamic>>(
      StorageBox.settings,
      StorageKeys.authUserProfile,
    );
    if (raw == null) {
      // A token without a profile is an inconsistent half-session; drop the
      // token so the app starts cleanly signed out.
      await _clearTokensQuietly('missing profile for stored token');
      return null;
    }
    try {
      final model = AuthUserModel.fromJson(Map<String, dynamic>.from(raw));
      return model.toEntity();
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthRepository: stored profile is unreadable — clearing session',
        error,
        stackTrace,
      );
      await _clearTokensQuietly('unreadable stored profile');
      return null;
    }
  }

  /// Persists a fresh session and returns the domain user.
  ///
  /// Saves the token pair, snapshots the profile for offline restore, and
  /// ends any guest session the user was in.
  Future<AuthUser> _persistSession(AuthResponseModel response) async {
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localStorage.put(
      StorageBox.settings,
      StorageKeys.authUserProfile,
      response.user.toJson(),
    );
    await _localStorage.delete(
      StorageBox.settings,
      StorageKeys.authIsGuest,
    );
    return response.user.toEntity();
  }

  Future<void> _clearTokensQuietly(String reason) async {
    try {
      await _tokenStorage.clearTokens();
      _talker.warning('AuthRepository: cleared tokens — $reason');
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthRepository: failed to clear tokens ($reason)',
        error,
        stackTrace,
      );
    }
  }
}

/// Provides the auth remote datasource, honoring the flavor's mock flag.
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  if (ref.watch(appConfigProvider).useMockData) {
    return AuthMockDatasource();
  }
  return AuthApiDatasource(dio: ref.watch(dioProvider));
});

/// Provides the app-wide auth repository.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    socialAuthService: ref.watch(socialAuthServiceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    localStorage: ref.watch(localStorageProvider),
    talker: ref.watch(talkerProvider),
  ),
);
