import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:posely_ai/core/network/interceptors/retry_interceptor.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/storage/secure_storage.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// Provides the app-wide Dio HTTP client.
///
/// Configured from the active flavor's base URL and the shared timeout
/// constants. Interceptor order matters: auth first so the retry re-fire and
/// the logger both see the final headers, retry second so replays go through
/// the whole chain, logging last so every attempt is recorded. Response
/// bodies and the Authorization header are kept out of logs.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final talker = ref.watch(talkerProvider);
  final tokenStorage = ref.watch(secureTokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: AppConstants.apiConnectTimeout,
      receiveTimeout: AppConstants.apiReceiveTimeout,
      headers: <String, dynamic>{Headers.acceptHeader: 'application/json'},
      contentType: Headers.jsonContentType,
      // Explicit even though it matches the dio default: the API contract
      // is JSON and must not drift with package defaults.
      // ignore: avoid_redundant_argument_values
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(tokenStorage: tokenStorage, talker: talker, retryDio: dio),
    RetryInterceptor(dio: dio, talker: talker),
    TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        // Explicit even where it matches today's package defaults: header
        // and body logging must stay off even if defaults ever flip.
        // ignore: avoid_redundant_argument_values
        printRequestHeaders: false,
        printResponseData: false,
        hiddenHeaders: {'authorization'},
      ),
    ),
  ]);

  ref.onDispose(dio.close);
  return dio;
});

/// Provides a builder that turns an endpoint path into a full WebSocket URI.
///
/// The path is appended to the flavor's WebSocket base URL, normalizing
/// slashes so both `pose/live` and `/pose/live` produce the same URI.
final webSocketUriProvider = Provider<Uri Function(String path)>((ref) {
  final wsBaseUrl = ref.watch(appConfigProvider).wsBaseUrl;
  return (String path) {
    final base = wsBaseUrl.endsWith('/')
        ? wsBaseUrl.substring(0, wsBaseUrl.length - 1)
        : wsBaseUrl;
    final suffix = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$suffix');
  };
});
