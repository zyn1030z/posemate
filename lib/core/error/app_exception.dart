import 'dart:io';

import 'package:dio/dio.dart';
// PHASE-14: if a web target is ever added, gate the SocketException check
// behind a conditional import; dart:io is fine for the mobile-only app.

/// Base type for every recoverable failure surfaced by the data layer.
///
/// The hierarchy is sealed so callers can exhaustively switch over failure
/// kinds; repositories should only ever throw or return `AppException`
/// subtypes, never raw `DioException` or platform errors.
sealed class AppException implements Exception {
  /// Creates an exception with a developer-facing message and optional
  /// original cause and stack trace for diagnostics.
  const AppException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// Maps a `DioException` onto the closest `AppException` subtype.
  ///
  /// Connectivity-level failures become `NetworkException`, timeouts become
  /// `ApiTimeoutException`, cancellations become `CancelledException`, and
  /// HTTP error responses are mapped by status code. Anything unrecognized
  /// falls back to `UnknownException` so no failure is ever lost.
  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiTimeoutException(cause: e, stackTrace: e.stackTrace);
      case DioExceptionType.connectionError:
        return NetworkException(cause: e, stackTrace: e.stackTrace);
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Failed to establish a secure connection.',
          cause: e,
          stackTrace: e.stackTrace,
        );
      case DioExceptionType.cancel:
        return CancelledException(cause: e, stackTrace: e.stackTrace);
      case DioExceptionType.badResponse:
        return _fromBadResponse(e);
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return NetworkException(cause: e, stackTrace: e.stackTrace);
        }
        return UnknownException(cause: e, stackTrace: e.stackTrace);
    }
  }

  /// Developer-facing description of the failure; safe for logs, not for UI.
  final String message;

  /// The original error that triggered this exception, when available.
  final Object? cause;

  /// The stack trace captured at the original failure site, when available.
  final StackTrace? stackTrace;

  /// Human-friendly, jargon-free text suitable for showing directly to users.
  String get userMessage => switch (this) {
    NetworkException() =>
      'You appear to be offline. Check your connection and try again.',
    ApiTimeoutException() => 'This is taking longer than expected. '
        'Please try again in a moment.',
    UnauthorizedException() => 'Your session has expired. '
        'Please sign in again.',
    ForbiddenException() => 'You do not have access to this content.',
    NotFoundException() => 'We could not find what you were looking for.',
    ConflictException() => 'That change could not be saved because something '
        'was updated elsewhere. Please try again.',
    RateLimitException() => 'You are going a little too fast. '
        'Please wait a moment and try again.',
    ServerException() => 'Something went wrong on our side. '
        'Please try again shortly.',
    ValidationException() => 'Some of the information looks incorrect. '
        'Please review it and try again.',
    CacheException() => 'We could not load your saved data. '
        'Please try again.',
    CancelledException() => 'The request was cancelled.',
    UnknownException() => 'Something unexpected went wrong. '
        'Please try again.',
    NoPoseDetectedException() => 'We could not detect a person in this photo. '
        'Please try another photo.',
  };

  /// Maps an HTTP error response onto a status-specific subtype.
  static AppException _fromBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    return switch (statusCode) {
      401 => UnauthorizedException(cause: e, stackTrace: e.stackTrace),
      403 => ForbiddenException(cause: e, stackTrace: e.stackTrace),
      404 => NotFoundException(cause: e, stackTrace: e.stackTrace),
      409 => ConflictException(cause: e, stackTrace: e.stackTrace),
      422 => _parse422(e),
      429 => RateLimitException(cause: e, stackTrace: e.stackTrace),
      final int code when code >= 500 => ServerException(
        statusCode: code,
        cause: e,
        stackTrace: e.stackTrace,
      ),
      _ => UnknownException(
        message: 'Unexpected HTTP status: $statusCode.',
        cause: e,
        stackTrace: e.stackTrace,
      ),
    };
  }

  static AppException _parse422(DioException e) {
    final data = e.response?.data;
    if (data is Map<dynamic, dynamic>) {
      if (data['code'] == 'no_pose_detected') {
        return NoPoseDetectedException(
          cause: e,
          stackTrace: e.stackTrace,
        );
      }
    }
    return ValidationException(
      fieldErrors: _parseFieldErrors(data),
      cause: e,
      stackTrace: e.stackTrace,
    );
  }

  /// Defensively extracts per-field validation messages from a response body
  /// shaped like `{"errors": {"field": ["message", ...]}}`.
  ///
  /// Unexpected shapes never throw; anything unparseable yields an empty map.
  static Map<String, List<String>> _parseFieldErrors(Object? data) {
    if (data is! Map<dynamic, dynamic>) {
      return const <String, List<String>>{};
    }
    final Object? errors = data['errors'];
    if (errors is! Map<dynamic, dynamic>) {
      return const <String, List<String>>{};
    }
    final result = <String, List<String>>{};
    for (final entry in errors.entries) {
      final Object? key = entry.key;
      if (key is! String) {
        continue;
      }
      final Object? value = entry.value;
      if (value is List<dynamic>) {
        final messages = value.whereType<String>().toList();
        if (messages.isNotEmpty) {
          result[key] = List<String>.unmodifiable(messages);
        }
      } else if (value is String) {
        result[key] = List<String>.unmodifiable(<String>[value]);
      }
    }
    return Map<String, List<String>>.unmodifiable(result);
  }

  /// Stable type name for toString; safe under release-mode minification,
  /// unlike interpolating runtimeType.
  String get _typeName => switch (this) {
    NetworkException() => 'NetworkException',
    ApiTimeoutException() => 'ApiTimeoutException',
    UnauthorizedException() => 'UnauthorizedException',
    ForbiddenException() => 'ForbiddenException',
    NotFoundException() => 'NotFoundException',
    ConflictException() => 'ConflictException',
    RateLimitException() => 'RateLimitException',
    ServerException() => 'ServerException',
    ValidationException() => 'ValidationException',
    CacheException() => 'CacheException',
    CancelledException() => 'CancelledException',
    NoPoseDetectedException() => 'NoPoseDetectedException',
    UnknownException() => 'UnknownException',
  };

  @override
  String toString() {
    final buffer = StringBuffer('$_typeName: $message');
    if (cause != null) {
      buffer.write(' (cause: $cause)');
    }
    return buffer.toString();
  }
}

/// No connectivity: DNS failure, socket error, or the device is offline.
final class NetworkException extends AppException {
  /// Creates a connectivity failure.
  const NetworkException({
    super.message = 'No internet connection.',
    super.cause,
    super.stackTrace,
  });
}

/// The request exceeded a connect, send, or receive timeout.
final class ApiTimeoutException extends AppException {
  /// Creates a timeout failure.
  const ApiTimeoutException({
    super.message = 'The request timed out.',
    super.cause,
    super.stackTrace,
  });
}

/// The server rejected the request as unauthenticated (HTTP 401).
final class UnauthorizedException extends AppException {
  /// Creates an authentication failure.
  const UnauthorizedException({
    super.message = 'Authentication required (401).',
    super.cause,
    super.stackTrace,
  });
}

/// The server refused access to the resource (HTTP 403).
final class ForbiddenException extends AppException {
  /// Creates an authorization failure.
  const ForbiddenException({
    super.message = 'Access denied (403).',
    super.cause,
    super.stackTrace,
  });
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundException extends AppException {
  /// Creates a missing-resource failure.
  const NotFoundException({
    super.message = 'Resource not found (404).',
    super.cause,
    super.stackTrace,
  });
}

/// The request conflicted with the current server state (HTTP 409).
final class ConflictException extends AppException {
  /// Creates a state-conflict failure.
  const ConflictException({
    super.message = 'Request conflicts with current state (409).',
    super.cause,
    super.stackTrace,
  });
}

/// The client sent too many requests (HTTP 429).
final class RateLimitException extends AppException {
  /// Creates a rate-limit failure.
  const RateLimitException({
    super.message = 'Too many requests (429).',
    super.cause,
    super.stackTrace,
  });
}

/// The server failed to process the request (HTTP 5xx).
final class ServerException extends AppException {
  /// Creates a server-side failure, optionally carrying the HTTP status.
  const ServerException({
    this.statusCode,
    super.message = 'Internal server error.',
    super.cause,
    super.stackTrace,
  });

  /// The HTTP status code returned by the server, when known.
  final int? statusCode;
}

/// The server rejected the request payload as invalid (HTTP 422).
final class ValidationException extends AppException {
  /// Creates a validation failure with optional per-field messages.
  const ValidationException({
    this.fieldErrors = const <String, List<String>>{},
    super.message = 'Validation failed (422).',
    super.cause,
    super.stackTrace,
  });

  /// Validation messages keyed by the offending field name.
  final Map<String, List<String>> fieldErrors;
}

/// Reading from or writing to local storage failed.
final class CacheException extends AppException {
  /// Creates a local-storage failure.
  const CacheException({
    super.message = 'Local cache operation failed.',
    super.cause,
    super.stackTrace,
  });
}

/// The request was cancelled before completing, usually by navigation.
final class CancelledException extends AppException {
  /// Creates a cancellation marker.
  const CancelledException({
    super.message = 'The request was cancelled.',
    super.cause,
    super.stackTrace,
  });
}

/// A failure that matched no other category; always carries its cause.
final class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unknown error occurred.',
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when an image upload for pose extraction does not contain any detected people.
class NoPoseDetectedException extends AppException {
  const NoPoseDetectedException({
    super.message = 'No person could be detected in the uploaded image.',
    super.cause,
    super.stackTrace,
  });
}
