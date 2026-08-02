import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Initializes Firebase and wires global error handlers to Crashlytics.
///
/// Firebase configuration files are generated per flavor with the
/// `flutterfire configure` CLI — see docs/FIREBASE_SETUP.md for the exact
/// commands and per-flavor bundle ids. When `AppConfig.enableFirebase` is
/// false, initialization is skipped entirely and the talker-only error
/// handlers installed by `bootstrap` remain in charge.
abstract final class FirebaseBootstrapper {
  /// Initializes Firebase according to the given configuration.
  ///
  /// On success, replaces the global Flutter and platform error handlers so
  /// fatal errors are reported to Crashlytics and mirrored to the given
  /// `talker`. Failures are logged and swallowed — the app keeps running
  /// without Firebase rather than crashing at startup.
  static Future<void> init({
    required AppConfig config,
    required Talker talker,
  }) async {
    if (!config.enableFirebase) {
      talker.info(
        'Firebase disabled for ${config.flavor.label} flavor — skipping init',
      );
      return;
    }

    try {
      await Firebase.initializeApp();

      FlutterError.onError = (FlutterErrorDetails details) {
        unawaited(
          FirebaseCrashlytics.instance.recordFlutterFatalError(details),
        );
        talker.handle(details.exception, details.stack, 'FlutterError');
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        unawaited(
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
        );
        talker.handle(error, stack, 'PlatformDispatcher');
        return true;
      };

      talker.info('Firebase initialized for ${config.flavor.label} flavor');
    } catch (e, st) {
      talker.warning('Firebase init failed — continuing without it', e, st);
    }
  }
}
