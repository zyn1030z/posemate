import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Device-level identity verification via biometrics or device credentials.
///
/// Wraps local_auth 3.x, which reports recoverable failures by throwing
/// `LocalAuthException` (user cancel, lockout, missing hardware, ...). This
/// wrapper collapses every failure mode — including raw platform-channel
/// errors — into a plain false, so callers get a single "verified or not"
/// outcome and never need a try/catch of their own.
class BiometricService {
  /// Creates the service.
  ///
  /// A custom `LocalAuthentication` can be injected for tests; production
  /// code uses the plugin default.
  BiometricService({
    required Talker talker,
    LocalAuthentication? localAuth,
  })  : _talker = talker,
        _localAuth = localAuth ?? LocalAuthentication();

  final Talker _talker;
  final LocalAuthentication _localAuth;

  /// Whether the device can verify the user locally, either with biometrics
  /// or by falling back to a device credential (pin, pattern, passcode).
  Future<bool> get isSupported async {
    try {
      return await _localAuth.isDeviceSupported();
    } on LocalAuthException catch (error, stackTrace) {
      _talker.warning(
        'BiometricService: support check failed (${error.code.name})',
        error,
        stackTrace,
      );
      return false;
    } on PlatformException catch (error, stackTrace) {
      _talker.warning(
        'BiometricService: support check failed at the platform channel',
        error,
        stackTrace,
      );
      return false;
    }
  }

  /// Prompts the user to verify their identity, showing the given reason.
  ///
  /// Returns true only when verification succeeded. Dismissal, lockout,
  /// unenrolled biometrics, and platform errors all resolve to false — the
  /// cause is logged, never thrown — so a denied prompt and a broken sensor
  /// read the same to the auth flow: not verified.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(localizedReason: reason);
    } on LocalAuthException catch (error, stackTrace) {
      _talker.warning(
        'BiometricService: authentication failed (${error.code.name})',
        error,
        stackTrace,
      );
      return false;
    } on PlatformException catch (error, stackTrace) {
      _talker.warning(
        'BiometricService: authentication failed at the platform channel',
        error,
        stackTrace,
      );
      return false;
    }
  }
}

/// Provides the app-wide biometric service.
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(talker: ref.watch(talkerProvider)),
);
