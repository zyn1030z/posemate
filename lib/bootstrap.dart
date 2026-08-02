import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/app.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/flavor.dart';
import 'package:posely_ai/core/services/firebase/firebase_bootstrapper.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Shared startup sequence for every flavor entrypoint.
///
/// Builds the flavor's `AppConfig`, initializes logging, system chrome,
/// local storage, and Firebase, installs global error handlers, and finally
/// mounts `PoselyApp` inside a fully wired `ProviderScope`.
Future<void> bootstrap({required Flavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.forFlavor(flavor);
  final talker = TalkerFlutter.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Talker-only error handlers. FirebaseBootstrapper.init replaces both when
  // Firebase is enabled, so Crashlytics wins — keep it after these lines.
  FlutterError.onError = (FlutterErrorDetails details) {
    talker.handle(details.exception, details.stack, 'FlutterError');
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    talker.handle(error, stack, 'PlatformDispatcher');
    return true;
  };

  final localStorage = await HiveLocalStorage.init();

  await FirebaseBootstrapper.init(config: config, talker: talker);

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        localStorageProvider.overrideWithValue(localStorage),
        talkerProvider.overrideWithValue(talker),
      ],
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: const TalkerRiverpodLoggerSettings(
            printProviderAdded: false,
          ),
        ),
      ],
      child: const PoselyApp(),
    ),
  );
}
