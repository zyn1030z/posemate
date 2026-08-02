import 'dart:math';

import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Key in `RequestOptions.extra` tracking how many retries a request has used.
const String kRetryAttemptKey = 'retryAttempt';

/// Retries transient failures for idempotent GET requests.
///
/// A request is retried at most twice, only when the failure is a connection
/// error, a connect or receive timeout, or a 502/503/504 response, and never
/// after cancellation. Each retry waits an exponentially growing delay with
/// random jitter (base 400 ms) before re-firing the original request through
/// the owning Dio instance, so the full interceptor chain runs again.
class RetryInterceptor extends Interceptor {
  /// Creates the interceptor bound to the Dio instance that owns it.
  ///
  /// A custom random source can be injected for deterministic tests.
  RetryInterceptor({
    required this._dio,
    required this._talker,
    Random? random,
  }) : _random = random ?? Random();

  /// Maximum number of retries after the initial attempt.
  static const int _maxRetries = 2;

  /// Base backoff delay; doubled on each subsequent retry.
  static const int _baseDelayMs = 400;

  /// Gateway statuses considered transient.
  static const Set<int> _retryableStatusCodes = {502, 503, 504};

  /// Failure types considered transient.
  static const Set<DioExceptionType> _retryableTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
  };

  final Dio _dio;
  final Talker _talker;
  final Random _random;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }
    final options = err.requestOptions;
    final attempt = (options.extra[kRetryAttemptKey] as int? ?? 0) + 1;
    if (attempt > _maxRetries) {
      handler.next(err);
      return;
    }
    // Copy-on-write: the caller may have supplied an unmodifiable extra map.
    options.extra = <String, dynamic>{
      ...options.extra,
      kRetryAttemptKey: attempt,
    };

    final delay = _backoffDelay(attempt);
    _talker.warning(
      'RetryInterceptor: retrying ${options.method} ${options.path} '
      '(attempt $attempt/$_maxRetries in ${delay.inMilliseconds} ms) '
      'after ${err.type.name}',
    );
    await Future<void>.delayed(delay);

    if (options.cancelToken?.isCancelled ?? false) {
      // Cancelled while waiting to retry — surface the original error.
      handler.next(err);
      return;
    }
    try {
      final response = await _dio.fetch<dynamic>(options);
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

  /// Whether the failure is transient and the request is safe to replay.
  bool _shouldRetry(DioException err) {
    // Never retry a cancelled request.
    if (err.type == DioExceptionType.cancel) {
      return false;
    }
    if (err.requestOptions.cancelToken?.isCancelled ?? false) {
      return false;
    }
    // Only idempotent GETs are safe to re-fire blindly.
    if (err.requestOptions.method.toUpperCase() != 'GET') {
      return false;
    }
    if (_retryableTypes.contains(err.type)) {
      return true;
    }
    final statusCode = err.response?.statusCode;
    return err.type == DioExceptionType.badResponse &&
        statusCode != null &&
        _retryableStatusCodes.contains(statusCode);
  }

  /// Exponential backoff with additive jitter: base * 2^(attempt - 1) plus a
  /// random 0–50% of that value, so parallel clients do not retry in lockstep.
  Duration _backoffDelay(int attempt) {
    final backoffMs = _baseDelayMs << (attempt - 1);
    final jitterMs = _random.nextInt(backoffMs ~/ 2 + 1);
    return Duration(milliseconds: backoffMs + jitterMs);
  }
}
