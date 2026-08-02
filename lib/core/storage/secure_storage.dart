import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';

/// Stores and retrieves auth tokens in the platform keychain or keystore.
///
/// This is the only component that touches token persistence; everything
/// else (interceptors, auth repository) goes through it so key names and
/// storage backend stay in one place.
class SecureTokenStorage {
  /// Creates the storage wrapper.
  ///
  /// A custom `FlutterSecureStorage` can be injected for tests; production
  /// code uses the platform default.
  const SecureTokenStorage({
    this._storage = const FlutterSecureStorage(),
  });

  final FlutterSecureStorage _storage;

  /// Reads the stored access token, or null when the user is signed out.
  Future<String?> readAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  /// Reads the stored refresh token, or null when none was issued.
  Future<String?> readRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  /// Persists a fresh token pair.
  ///
  /// When the refresh token is omitted the previously stored one is kept,
  /// matching OAuth servers that only rotate refresh tokens occasionally.
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(
        key: StorageKeys.refreshToken,
        value: refreshToken,
      );
    }
  }

  /// Deletes both tokens, signing the device out of the session.
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }
}

/// Provides the app-wide secure token storage.
final secureTokenStorageProvider = Provider<SecureTokenStorage>(
  (ref) => const SecureTokenStorage(),
);
