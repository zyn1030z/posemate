import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/config/constants/api_endpoints.dart';
import 'package:posely_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:posely_ai/core/storage/secure_storage.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Minimal fake transport: routes every request through a single handler.
class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}

/// In-memory token store tracking saves and clears.
class _FakeTokenStorage implements SecureTokenStorage {
  String? accessToken;
  String? refreshToken;
  int clearCount = 0;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    this.accessToken = accessToken;
    if (refreshToken != null) {
      this.refreshToken = refreshToken;
    }
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    clearCount += 1;
  }
}

ResponseBody _jsonResponse(int statusCode, Map<String, Object?> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );

ResponseBody _unauthorizedResponse() => _jsonResponse(401, <String, Object?>{
  'error': <String, Object?>{
    'code': 'token_expired',
    'message': 'The access token has expired.',
  },
});

Dio _buildDio({
  required _FakeHttpAdapter adapter,
  required _FakeTokenStorage storage,
  void Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: storage,
      talker: Talker(settings: TalkerSettings(enabled: false)),
      retryDio: dio,
      onSessionExpired: onSessionExpired,
      refreshDioFactory: (options) =>
          Dio(options)..httpClientAdapter = adapter,
    ),
  );
  return dio;
}

void main() {
  late _FakeTokenStorage storage;

  setUp(() {
    storage = _FakeTokenStorage()
      ..accessToken = 'old_access'
      ..refreshToken = 'old_refresh';
  });

  test('401 triggers refresh, saves tokens, and replays', () async {
    var refreshCalls = 0;
    final refreshBodies = <Object?>[];
    final adapter = _FakeHttpAdapter((options) async {
      if (options.path == ApiEndpoints.refresh) {
        refreshCalls += 1;
        refreshBodies.add(options.data);
        return _jsonResponse(200, <String, Object?>{
          'access_token': 'new_access',
          'refresh_token': 'new_refresh',
          'expires_in': 900,
          'token_type': 'Bearer',
        });
      }
      if (options.headers['Authorization'] == 'Bearer new_access') {
        return _jsonResponse(200, <String, Object?>{'ok': true});
      }
      return _unauthorizedResponse();
    });
    final dio = _buildDio(adapter: adapter, storage: storage);

    final response = await dio.get<Map<String, dynamic>>(ApiEndpoints.me);

    expect(response.statusCode, 200);
    expect(response.data?['ok'], true);
    expect(refreshCalls, 1);
    expect(refreshBodies.single, <String, Object?>{
      'refresh_token': 'old_refresh',
    });
    expect(storage.accessToken, 'new_access');
    expect(storage.refreshToken, 'new_refresh');
    expect(storage.clearCount, 0);
  });

  test('failed refresh forwards the error and expires session', () async {
    var refreshCalls = 0;
    var sessionExpiredCalls = 0;
    final adapter = _FakeHttpAdapter((options) async {
      if (options.path == ApiEndpoints.refresh) {
        refreshCalls += 1;
      }
      return _unauthorizedResponse();
    });
    final dio = _buildDio(
      adapter: adapter,
      storage: storage,
      onSessionExpired: () => sessionExpiredCalls += 1,
    );

    await expectLater(
      dio.get<Map<String, dynamic>>(ApiEndpoints.me),
      throwsA(
        isA<DioException>()
            .having((e) => e.response?.statusCode, 'statusCode', 401)
            .having(
              (e) => e.requestOptions.path,
              'original request path',
              ApiEndpoints.me,
            ),
      ),
    );
    expect(refreshCalls, 1);
    expect(storage.accessToken, isNull);
    expect(storage.refreshToken, isNull);
    expect(storage.clearCount, 1);
    expect(sessionExpiredCalls, 1);
  });

  test('concurrent 401s share a single refresh', () async {
    var refreshCalls = 0;
    final adapter = _FakeHttpAdapter((options) async {
      if (options.path == ApiEndpoints.refresh) {
        refreshCalls += 1;
        // Hold the refresh open long enough for every concurrent 401 to
        // join the in-flight future rather than starting its own.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return _jsonResponse(200, <String, Object?>{
          'access_token': 'new_access',
          'refresh_token': 'new_refresh',
        });
      }
      if (options.headers['Authorization'] == 'Bearer new_access') {
        return _jsonResponse(200, <String, Object?>{'path': options.path});
      }
      return _unauthorizedResponse();
    });
    final dio = _buildDio(adapter: adapter, storage: storage);

    final responses = await Future.wait([
      dio.get<Map<String, dynamic>>(ApiEndpoints.me),
      dio.get<Map<String, dynamic>>(ApiEndpoints.poses),
    ]);

    expect(refreshCalls, 1);
    expect(responses[0].statusCode, 200);
    expect(responses[0].data?['path'], ApiEndpoints.me);
    expect(responses[1].statusCode, 200);
    expect(responses[1].data?['path'], ApiEndpoints.poses);
    expect(storage.accessToken, 'new_access');
  });
}
