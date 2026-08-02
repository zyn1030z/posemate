import 'package:dio/dio.dart';
import 'package:posely_ai/core/error/app_exception.dart';

/// The outcome of an API call: either `ApiSuccess` carrying data or
/// `ApiFailure` carrying an `AppException`.
///
/// Being sealed, results can be exhaustively pattern-matched, and the
/// convenience members below cover the common non-matching call sites.
sealed class ApiResult<T> {
  /// Enables const constructors on subtypes.
  const ApiResult();

  /// Collapses the result into a single value by applying exactly one of the
  /// two callbacks.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException exception) onFailure,
  }) => switch (this) {
    ApiSuccess<T>(:final data) => onSuccess(data),
    ApiFailure<T>(:final exception) => onFailure(exception),
  };

  /// Transforms the success value, passing failures through untouched.
  ///
  /// If the transform itself throws, the error is captured as an
  /// `ApiFailure` wrapping an `UnknownException` rather than propagating.
  ApiResult<R> map<R>(R Function(T data) transform) {
    switch (this) {
      case ApiSuccess<T>(:final data):
        try {
          return ApiSuccess<R>(transform(data));
        } catch (error, stackTrace) {
          return ApiFailure<R>(
            UnknownException(
              message: 'Failed to transform response data.',
              cause: error,
              stackTrace: stackTrace,
            ),
          );
        }
      case ApiFailure<T>(:final exception):
        return ApiFailure<R>(exception);
    }
  }

  /// The success value, or null when this is a failure.
  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(:final data) => data,
    ApiFailure<T>() => null,
  };

  /// The failure, or null when this is a success.
  AppException? get exceptionOrNull => switch (this) {
    ApiSuccess<T>() => null,
    ApiFailure<T>(:final exception) => exception,
  };

  /// Whether this result carries data.
  bool get isSuccess => this is ApiSuccess<T>;
}

/// A successful API call carrying the decoded response data.
final class ApiSuccess<T> extends ApiResult<T> {
  /// Wraps the decoded response data.
  const ApiSuccess(this.data);

  /// The decoded response payload.
  final T data;
}

/// A failed API call carrying the mapped domain exception.
final class ApiFailure<T> extends ApiResult<T> {
  /// Wraps the failure that ended the call.
  const ApiFailure(this.exception);

  /// The domain-level description of what went wrong.
  final AppException exception;
}

/// Runs an async operation and captures every failure as an `ApiFailure`.
///
/// `DioException` is translated via `AppException.fromDio`, an already-typed
/// `AppException` is wrapped as-is, and anything else becomes an
/// `UnknownException` carrying the original error and stack trace. The
/// returned future therefore never completes with an error.
Future<ApiResult<T>> guardApi<T>(Future<T> Function() run) async {
  try {
    return ApiSuccess<T>(await run());
  } on DioException catch (error) {
    return ApiFailure<T>(AppException.fromDio(error));
  } on AppException catch (exception) {
    return ApiFailure<T>(exception);
  } catch (error, stackTrace) {
    return ApiFailure<T>(
      UnknownException(cause: error, stackTrace: stackTrace),
    );
  }
}
