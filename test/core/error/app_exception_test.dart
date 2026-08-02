import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/error/app_exception.dart';

DioException _dioException({
  DioExceptionType type = DioExceptionType.badResponse,
  int? statusCode,
  Object? data,
  Object? error,
}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    error: error,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  group('AppException.fromDio', () {
    test('maps timeout types to ApiTimeoutException', () {
      const timeoutTypes = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ];
      for (final type in timeoutTypes) {
        final exception = AppException.fromDio(_dioException(type: type));
        expect(
          exception,
          isA<ApiTimeoutException>(),
          reason: 'expected ApiTimeoutException for $type',
        );
      }
    });

    test('maps connectionError to NetworkException', () {
      final exception = AppException.fromDio(
        _dioException(type: DioExceptionType.connectionError),
      );
      expect(exception, isA<NetworkException>());
    });

    test('maps cancel to CancelledException', () {
      final exception = AppException.fromDio(
        _dioException(type: DioExceptionType.cancel),
      );
      expect(exception, isA<CancelledException>());
    });

    test('maps unknown with SocketException to NetworkException', () {
      final exception = AppException.fromDio(
        _dioException(
          type: DioExceptionType.unknown,
          error: const SocketException('connection refused'),
        ),
      );
      expect(exception, isA<NetworkException>());
    });

    test('maps unknown without cause to UnknownException', () {
      final exception = AppException.fromDio(
        _dioException(type: DioExceptionType.unknown),
      );
      expect(exception, isA<UnknownException>());
    });

    test('maps bad response statuses to the matching subtype', () {
      const expectations = <int, Type>{
        401: UnauthorizedException,
        403: ForbiddenException,
        404: NotFoundException,
        409: ConflictException,
        422: ValidationException,
        429: RateLimitException,
        500: ServerException,
        502: ServerException,
        503: ServerException,
      };
      for (final entry in expectations.entries) {
        final exception = AppException.fromDio(
          _dioException(statusCode: entry.key),
        );
        expect(
          exception.runtimeType,
          entry.value,
          reason: 'wrong exception type for HTTP ${entry.key}',
        );
      }
    });

    test('carries the status code on ServerException', () {
      final exception = AppException.fromDio(_dioException(statusCode: 503));
      expect(exception, isA<ServerException>());
      expect((exception as ServerException).statusCode, 503);
    });

    test('maps unrecognized bad response status to UnknownException', () {
      final exception = AppException.fromDio(_dioException(statusCode: 418));
      expect(exception, isA<UnknownException>());
    });

    test('preserves the DioException as cause', () {
      final dioError = _dioException(statusCode: 500);
      final exception = AppException.fromDio(dioError);
      expect(exception.cause, same(dioError));
    });
  });

  group('AppException.fromDio validation errors', () {
    test('parses field errors from the documented body shape', () {
      final exception = AppException.fromDio(
        _dioException(
          statusCode: 422,
          data: <String, dynamic>{
            'errors': <String, dynamic>{
              'email': <String>['Email is invalid', 'Email is taken'],
              'name': <String>['Name is required'],
            },
          },
        ),
      );
      expect(exception, isA<ValidationException>());
      final validation = exception as ValidationException;
      expect(validation.fieldErrors, hasLength(2));
      expect(
        validation.fieldErrors['email'],
        ['Email is invalid', 'Email is taken'],
      );
      expect(validation.fieldErrors['name'], ['Name is required']);
    });

    test('accepts a single string per field', () {
      final exception = AppException.fromDio(
        _dioException(
          statusCode: 422,
          data: <String, dynamic>{
            'errors': <String, dynamic>{'age': 'Must be a number'},
          },
        ),
      );
      final validation = exception as ValidationException;
      expect(validation.fieldErrors['age'], ['Must be a number']);
    });

    test('yields empty field errors for malformed bodies', () {
      const malformedBodies = <Object?>[
        null,
        'plain text',
        42,
        <String, dynamic>{},
        <String, dynamic>{'errors': 'not a map'},
        <String, dynamic>{'errors': <dynamic>[]},
        <String, dynamic>{
          'errors': <String, dynamic>{
            'field': <dynamic>[1, 2, 3],
          },
        },
      ];
      for (final body in malformedBodies) {
        final exception = AppException.fromDio(
          _dioException(statusCode: 422, data: body),
        );
        expect(
          exception,
          isA<ValidationException>(),
          reason: 'expected ValidationException for body: $body',
        );
        expect(
          (exception as ValidationException).fieldErrors,
          isEmpty,
          reason: 'expected empty field errors for body: $body',
        );
      }
    });
  });

  group('userMessage', () {
    test('is non-empty for every exception type', () {
      const allExceptions = <AppException>[
        NetworkException(),
        ApiTimeoutException(),
        UnauthorizedException(),
        ForbiddenException(),
        NotFoundException(),
        ConflictException(),
        RateLimitException(),
        ServerException(),
        ValidationException(),
        CacheException(),
        CancelledException(),
        UnknownException(),
      ];
      for (final exception in allExceptions) {
        expect(
          exception.userMessage,
          isNotEmpty,
          reason: 'empty userMessage on $exception',
        );
        expect(
          exception.message,
          isNotEmpty,
          reason: 'empty message on $exception',
        );
      }
    });
  });

  group('toString', () {
    test('includes the type, message, and cause when present', () {
      const bare = NetworkException();
      expect(bare.toString(), 'NetworkException: No internet connection.');

      const withCause = CacheException(cause: 'disk full');
      expect(withCause.toString(), contains('CacheException'));
      expect(withCause.toString(), contains('disk full'));
    });
  });
}
