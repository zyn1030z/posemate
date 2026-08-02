import 'dart:math';

import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:posely_ai/features/auth/data/models/auth_response_model.dart';
import 'package:posely_ai/features/auth/data/models/auth_user_model.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:uuid/uuid.dart';

/// Deterministic in-memory auth backend used by the dev flavor.
///
/// Seeded with one demo account (demo@posely.app / posely123) so the app is
/// usable immediately. Behavior mirrors the real contract: wrong credentials
/// throw `UnauthorizedException`, duplicate registration throws
/// `ConflictException`, and every call resolves after a simulated latency.
class AuthMockDatasource implements AuthRemoteDatasource {
  /// Creates the mock backend.
  ///
  /// A custom `latency` source can be injected for tests (for example
  /// returning `Duration.zero`); by default each call waits a random
  /// 350–700 ms to imitate a network round trip.
  AuthMockDatasource({
    Duration Function()? latency,
  }) : _latency = latency ?? _randomLatency;

  /// Email of the seeded demo account.
  static const String demoEmail = 'demo@posely.app';

  /// Password of the seeded demo account.
  static const String demoPassword = 'posely123';

  static const Uuid _uuid = Uuid();

  static final Random _random = Random();

  final Duration Function() _latency;

  /// Registered accounts keyed by normalized email.
  final Map<String, _MockAccount> _accounts = <String, _MockAccount>{
    demoEmail: _MockAccount(
      id: 'mock_user_demo',
      email: demoEmail,
      password: demoPassword,
      displayName: 'Demo Creator',
      isPremium: true,
      createdAt: DateTime.utc(2026, 1, 15),
    ),
  };

  @override
  Future<AuthResponseModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _delay();
    final account = _accounts[_normalize(email)];
    if (account == null || account.password != password) {
      throw const UnauthorizedException(
        message: 'Invalid email or password.',
      );
    }
    return _sessionFor(account);
  }

  @override
  Future<AuthResponseModel> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await _delay();
    final key = _normalize(email);
    if (_accounts.containsKey(key)) {
      throw const ConflictException(
        message: 'An account with this email already exists.',
      );
    }
    final account = _MockAccount(
      id: 'mock_user_${_uuid.v4()}',
      email: key,
      password: password,
      displayName: displayName,
      createdAt: DateTime.now().toUtc(),
    );
    _accounts[key] = account;
    return _sessionFor(account);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    // Always succeeds, mirroring a backend that never reveals whether an
    // email is registered.
    await _delay();
  }

  @override
  Future<AuthResponseModel> socialLogin({
    required SocialProvider provider,
    required String idToken,
  }) async {
    await _delay();
    final email = '${provider.name}.user@posely.app';
    final account = _accounts.putIfAbsent(
      email,
      () => _MockAccount(
        id: 'mock_user_${provider.name}',
        email: email,
        // Social accounts have no usable password in the mock registry.
        password: 'social_${_uuid.v4()}',
        displayName: '${provider.label} Creator',
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return _sessionFor(account);
  }

  Future<void> _delay() => Future<void>.delayed(_latency());

  AuthResponseModel _sessionFor(_MockAccount account) => AuthResponseModel(
    user: AuthUserModel(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      isPremium: account.isPremium,
      createdAt: account.createdAt,
    ),
    accessToken: 'mock_access_${_uuid.v4()}',
    refreshToken: 'mock_refresh_${_uuid.v4()}',
    expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
  );

  static String _normalize(String email) => email.trim().toLowerCase();

  static Duration _randomLatency() =>
      Duration(milliseconds: 350 + _random.nextInt(351));
}

/// A registered account in the in-memory registry.
class _MockAccount {
  _MockAccount({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
    this.isPremium = false,
    this.createdAt,
  });

  final String id;
  final String email;
  final String password;
  final String displayName;
  final bool isPremium;
  final DateTime? createdAt;
}
