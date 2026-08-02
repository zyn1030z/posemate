import 'package:dio/dio.dart';
import 'package:posely_ai/core/config/constants/api_endpoints.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/storage/secure_storage.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Key in `RequestOptions.extra` that marks a request as unauthenticated.
///
/// Set it to true on endpoints that must not carry an Authorization header,
/// such as login, registration, or public catalog calls.
const String kSkipAuthKey = 'skipAuth';

/// Key in `RequestOptions.extra` marking a request already replayed once
/// after a token refresh, so it is never replayed a second time.
const String kRetriedAfterRefreshKey = 'retriedAfterRefresh';

/// Convenience access to the skip-auth marker on request options.
extension SkipAuthRequestOptionsX on RequestOptions {
  /// Whether this request opted out of the Authorization header.
  bool get skipAuth => extra[kSkipAuthKey] == true;
}

/// Attaches the stored access token to outgoing requests and transparently
/// refreshes an expired session.
///
/// Requests flagged with `kSkipAuthKey` pass through untouched. On a 401
/// response the interceptor runs the rotation flow from
/// docs/API_CONTRACTS.md: a single-flight POST to the refresh endpoint using
/// a bare Dio (no interceptors, so the flow cannot recurse), then a one-time
/// replay of the original request through the owning Dio with the fresh
/// token. When no refresh token exists or the refresh itself fails, tokens
/// are cleared, the session-expired callback fires, and the original error
/// is forwarded.
class AuthInterceptor extends Interceptor {
  /// Creates the interceptor with its token source and logger.
  ///
  /// `retryDio` is the Dio instance owning this interceptor; it is used to
  /// replay the original request after a successful refresh so the replay
  /// runs through the full interceptor chain. Without it, refreshed tokens
  /// are saved but the failing request is not replayed.
  ///
  /// `refreshDioFactory` is a test seam: it builds the short-lived bare Dio
  /// used for the refresh call itself. Production code uses the default.
  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    required Talker talker,
    Dio? retryDio,
    this.onSessionExpired,
    Dio Function(BaseOptions options)? refreshDioFactory,
  })  : _tokenStorage = tokenStorage,
        _talker = talker,
        _retryDio = retryDio,
        _refreshDioFactory = refreshDioFactory ?? Dio.new;

  /// Invoked once per failed refresh after tokens are cleared, so the app
  /// can route to the sign-in screen. Settable after construction because
  /// the router outlives the Dio provider wiring.
  void Function()? onSessionExpired;

  final SecureTokenStorage _tokenStorage;
  final Talker _talker;
  final Dio? _retryDio;
  final Dio Function(BaseOptions options) _refreshDioFactory;

  /// The in-flight single-flight refresh, shared by concurrent 401s.
  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.skipAuth) {
      handler.next(options);
      return;
    }
    try {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (error, stackTrace) {
      // A failed keychain read must not fail the request itself; the server
      // will answer 401 if the token was actually required.
      _talker.warning(
        'AuthInterceptor: failed to read access token',
        error,
        stackTrace,
      );
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || options.skipAuth) {
      handler.next(err);
      return;
    }
    if (options.extra[kRetriedAfterRefreshKey] == true) {
      // The replay itself came back 401 — never refresh-and-replay twice.
      _talker.warning(
        'AuthInterceptor: 401 on ${options.path} after refresh replay — '
        'giving up',
      );
      handler.next(err);
      return;
    }

    final String? newAccessToken;
    try {
      newAccessToken = await _sharedRefresh(options);
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthInterceptor: unexpected refresh failure',
        error,
        stackTrace,
      );
      handler.next(err);
      return;
    }
    if (newAccessToken == null) {
      // Refresh missing or rejected; the session was already expired and
      // cleared inside the refresh path.
      handler.next(err);
      return;
    }

    final retryDio = _retryDio;
    if (retryDio == null) {
      _talker.warning(
        'AuthInterceptor: refreshed tokens but no retry Dio was injected — '
        'forwarding original 401',
      );
      handler.next(err);
      return;
    }
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    // Copy-on-write: the caller may have supplied an unmodifiable extra map.
    options.extra = <String, dynamic>{
      ...options.extra,
      kRetriedAfterRefreshKey: true,
    };
    try {
      final response = await retryDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (error, stackTrace) {
      handler.next(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Joins the in-flight refresh, or starts one when none is running.
  ///
  /// Returns the fresh access token, or null when the session could not be
  /// refreshed (tokens are already cleared in that case).
  Future<String?> _sharedRefresh(RequestOptions failedRequest) {
    return _refreshFuture ??= _refreshTokens(failedRequest).whenComplete(() {
      _refreshFuture = null;
    });
  }

  /// Runs one refresh round trip against the failing request's base URL.
  Future<String?> _refreshTokens(RequestOptions failedRequest) async {
    final String? refreshToken;
    try {
      refreshToken = await _tokenStorage.readRefreshToken();
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthInterceptor: failed to read refresh token',
        error,
        stackTrace,
      );
      await _expireSession('refresh token unreadable');
      return null;
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession('no refresh token stored');
      return null;
    }

    // A bare Dio with no interceptors: the refresh call must never recurse
    // into this interceptor or be retried/logged like a normal request.
    final refreshDio = _refreshDioFactory(
      BaseOptions(
        baseUrl: failedRequest.baseUrl,
        connectTimeout: AppConstants.apiConnectTimeout,
        receiveTimeout: AppConstants.apiReceiveTimeout,
        contentType: Headers.jsonContentType,
      ),
    );
    try {
      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: <String, dynamic>{'refresh_token': refreshToken},
        options: Options(extra: <String, dynamic>{kSkipAuthKey: true}),
      );
      final data = response.data;
      final Object? accessToken = data?['access_token'];
      if (accessToken is! String || accessToken.isEmpty) {
        await _expireSession('refresh response carried no access token');
        return null;
      }
      final Object? newRefreshToken = data?['refresh_token'];
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken is String ? newRefreshToken : null,
      );
      _talker.info('AuthInterceptor: token refresh succeeded');
      return accessToken;
    } on DioException catch (error) {
      await _expireSession(
        'refresh request failed '
        '(${error.response?.statusCode ?? error.type.name})',
      );
      return null;
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthInterceptor: unexpected error during token refresh',
        error,
        stackTrace,
      );
      await _expireSession('unexpected refresh error');
      return null;
    } finally {
      refreshDio.close();
    }
  }

  /// Clears the dead session and notifies the app exactly once per failure.
  Future<void> _expireSession(String reason) async {
    _talker.warning('AuthInterceptor: session expired — $reason');
    try {
      await _tokenStorage.clearTokens();
    } catch (error, stackTrace) {
      _talker.warning(
        'AuthInterceptor: failed to clear tokens after refresh failure',
        error,
        stackTrace,
      );
    }
    onSessionExpired?.call();
  }
}
