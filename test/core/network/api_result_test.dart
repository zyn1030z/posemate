import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';

void main() {
  group('guardApi', () {
    test('wraps the returned value in ApiSuccess', () async {
      final result = await guardApi<int>(() async => 42);
      expect(result, isA<ApiSuccess<int>>());
      expect(result.dataOrNull, 42);
      expect(result.isSuccess, isTrue);
    });

    test('maps DioException through AppException.fromDio', () async {
      final result = await guardApi<int>(() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
      });
      expect(result, isA<ApiFailure<int>>());
      expect(result.exceptionOrNull, isA<ApiTimeoutException>());
    });

    test('passes an already-typed AppException through unchanged', () async {
      const thrown = CacheException(message: 'corrupt box');
      final result = await guardApi<int>(() async => throw thrown);
      expect(result, isA<ApiFailure<int>>());
      expect(result.exceptionOrNull, same(thrown));
    });

    test('wraps arbitrary errors in UnknownException with cause', () async {
      final result = await guardApi<int>(
        () async => throw StateError('boom'),
      );
      final exception = result.exceptionOrNull;
      expect(exception, isA<UnknownException>());
      expect(exception!.cause, isA<StateError>());
      expect(exception.stackTrace, isNotNull);
    });

    test('never completes with an error', () async {
      await expectLater(
        guardApi<int>(() async => throw ArgumentError('bad')),
        completes,
      );
    });
  });

  group('fold', () {
    test('invokes onSuccess for a success', () {
      const ApiResult<int> result = ApiSuccess(7);
      final folded = result.fold(
        onSuccess: (data) => 'data:$data',
        onFailure: (exception) => 'error:${exception.message}',
      );
      expect(folded, 'data:7');
    });

    test('invokes onFailure for a failure', () {
      const ApiResult<int> result = ApiFailure(NetworkException());
      final folded = result.fold(
        onSuccess: (data) => 'data:$data',
        onFailure: (exception) => 'error:${exception.message}',
      );
      expect(folded, 'error:No internet connection.');
    });
  });

  group('map', () {
    test('transforms the success value', () {
      const ApiResult<int> result = ApiSuccess(21);
      final mapped = result.map((value) => value * 2);
      expect(mapped.dataOrNull, 42);
    });

    test('passes the failure through with the same exception', () {
      const exception = NotFoundException();
      const ApiResult<int> result = ApiFailure(exception);
      final mapped = result.map((value) => '$value');
      expect(mapped, isA<ApiFailure<String>>());
      expect(mapped.exceptionOrNull, same(exception));
    });

    test('captures a throwing transform as UnknownException', () {
      const ApiResult<int> result = ApiSuccess(1);
      final mapped = result.map<int>((value) => throw StateError('bad map'));
      final exception = mapped.exceptionOrNull;
      expect(exception, isA<UnknownException>());
      expect(exception!.cause, isA<StateError>());
    });
  });

  group('accessors', () {
    test('success exposes data and hides exception', () {
      const ApiResult<String> result = ApiSuccess('ok');
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 'ok');
      expect(result.exceptionOrNull, isNull);
    });

    test('failure exposes exception and hides data', () {
      const ApiResult<String> result = ApiFailure(ServerException());
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.exceptionOrNull, isA<ServerException>());
    });
  });
}
