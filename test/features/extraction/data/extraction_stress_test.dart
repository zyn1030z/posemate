import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_local_datasource.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_remote_datasource.dart';
import 'package:posely_ai/features/extraction/data/models/extraction_job_model.dart';
import 'package:posely_ai/features/extraction/data/repositories/extraction_repository_impl.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_job.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';

class MockExtractionRemoteDatasource extends Mock implements ExtractionRemoteDatasource {}

class MockExtractionLocalDatasource extends Mock implements ExtractionLocalDatasource {}

class FakeFile extends Fake implements File {}

void main() {
  late MockExtractionRemoteDatasource remote;
  late MockExtractionLocalDatasource local;
  late ExtractionRepositoryImpl repository;
  late File fakeImage;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    remote = MockExtractionRemoteDatasource();
    local = MockExtractionLocalDatasource();
    repository = ExtractionRepositoryImpl(remote, local);
    fakeImage = File('fake.png');
  });

  const samplePoseModel = PoseModel(
    id: 'pose_stress_1',
    name: 'Stress Test Pose',
    previewUrl: 'https://example.com/stress.jpg',
    overlayUrl: 'https://example.com/stress_overlay.png',
    categoryId: 'stress',
  );

  group('STRESS TEST 1: Status Enum & Deserialization Boundaries', () {
    test('deserializes standard valid statuses (uploading, processing, completed, failed)', () {
      final statuses = ['uploading', 'processing', 'completed', 'failed'];
      final expectedEnums = [
        ExtractionStatus.uploading,
        ExtractionStatus.processing,
        ExtractionStatus.completed,
        ExtractionStatus.failed,
      ];

      for (var i = 0; i < statuses.length; i++) {
        final json = {
          'id': 'job_status_$i',
          'status': statuses[i],
        };
        final model = ExtractionJobModel.fromJson(json);
        expect(model.status, equals(expectedEnums[i]));
      }
    });

    test('throws ArgumentError on unknown/unsupported status strings (e.g. queued, pending, uppercase)', () {
      final invalidStatuses = ['queued', 'pending', 'canceled', 'COMPLETED', 'Processing', 'UNKNOWN', ''];

      for (final invalidStatus in invalidStatuses) {
        final json = {
          'id': 'job_invalid',
          'status': invalidStatus,
        };

        expect(
          () => ExtractionJobModel.fromJson(json),
          throwsA(isA<ArgumentError>()),
          reason: 'Status string "$invalidStatus" should throw ArgumentError during enum decoding',
        );
      }
    });

    test('throws ArgumentError on null status in JSON', () {
      final json = <String, dynamic>{
        'id': 'job_null_status',
        'status': null,
      };

      expect(
        () => ExtractionJobModel.fromJson(json),
        throwsA(isA<ArgumentError>()),
        reason: 'Null status should throw ArgumentError',
      );
    });

    test('throws ArgumentError on non-string status type (int, bool, map)', () {
      final nonStringStatuses = [123, true, <String, dynamic>{'status': 'completed'}];

      for (final val in nonStringStatuses) {
        final json = <String, dynamic>{
          'id': 'job_non_string',
          'status': val,
        };

        expect(
          () => ExtractionJobModel.fromJson(json),
          throwsA(isA<ArgumentError>()),
          reason: 'Non-string status "$val" should fail enum decoding',
        );
      }
    });
  });

  group('STRESS TEST 2: Null Handling & JSON Field Parsing Edge Cases', () {
    test('throws TypeError when mandatory id field is missing or null', () {
      final json = <String, dynamic>{
        'status': 'completed',
      };

      expect(
        () => ExtractionJobModel.fromJson(json),
        throwsA(isA<TypeError>()),
        reason: 'Missing id field should fail with TypeError',
      );
    });

    test('defaults progress to 0.0 when missing or null', () {
      final jsonMissingProgress = <String, dynamic>{
        'id': 'job_no_prog',
        'status': 'processing',
      };
      final model1 = ExtractionJobModel.fromJson(jsonMissingProgress);
      expect(model1.progress, equals(0.0));

      final jsonNullProgress = <String, dynamic>{
        'id': 'job_null_prog',
        'status': 'processing',
        'progress': null,
      };
      final model2 = ExtractionJobModel.fromJson(jsonNullProgress);
      expect(model2.progress, equals(0.0));
    });

    test('converts integer progress to double', () {
      final jsonIntProgress = <String, dynamic>{
        'id': 'job_int_prog',
        'status': 'completed',
        'progress': 1,
      };
      final model = ExtractionJobModel.fromJson(jsonIntProgress);
      expect(model.progress, equals(1.0));
    });

    test('prefers "result" field over "pose" field when both are present', () {
      const pose1 = PoseModel(
        id: 'p1',
        name: 'Primary Result',
        previewUrl: 'preview1',
        overlayUrl: 'overlay1',
        categoryId: 'cat1',
      );
      final jsonBoth = <String, dynamic>{
        'id': 'job_both',
        'status': 'completed',
        'result': {
          'id': 'p1',
          'name': 'Primary Result',
          'preview_url': 'preview1',
          'overlay_url': 'overlay1',
          'category_id': 'cat1',
        },
        'pose': {
          'id': 'p2',
          'name': 'Secondary Pose',
          'preview_url': 'preview2',
          'overlay_url': 'overlay2',
          'category_id': 'cat2',
        },
      };

      final model = ExtractionJobModel.fromJson(jsonBoth);
      expect(model.result, equals(pose1));
      expect(model.result?.name, equals('Primary Result'));
    });

    test('falls back to "pose" field when "result" field is null', () {
      const pose2 = PoseModel(
        id: 'p2',
        name: 'Secondary Pose',
        previewUrl: 'preview2',
        overlayUrl: 'overlay2',
        categoryId: 'cat2',
      );
      final jsonPoseOnly = <String, dynamic>{
        'id': 'job_pose_only',
        'status': 'completed',
        'result': null,
        'pose': {
          'id': 'p2',
          'name': 'Secondary Pose',
          'preview_url': 'preview2',
          'overlay_url': 'overlay2',
          'category_id': 'cat2',
        },
      };

      final model = ExtractionJobModel.fromJson(jsonPoseOnly);
      expect(model.result, equals(pose2));
    });

    test('throws FormatException on malformed ISO8601 date string', () {
      final jsonBadDate = <String, dynamic>{
        'id': 'job_bad_date',
        'status': 'processing',
        'created_at': '2026-99-99 INVALID DATE',
      };

      expect(
        () => ExtractionJobModel.fromJson(jsonBadDate),
        throwsA(isA<FormatException>()),
        reason: 'Invalid date string should throw FormatException',
      );
    });
  });

  group('STRESS TEST 3: Polling Logic & State Transitions', () {
    test('immediate completion on initial upload does not poll remote.getJobStatus', () async {
      const completedJob = ExtractionJobModel(
        id: 'job_fast_complete',
        status: ExtractionStatus.completed,
        progress: 1.0,
        result: samplePoseModel,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => completedJob);

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.status, equals(ExtractionStatus.completed));
      verify(() => remote.uploadImage(fakeImage)).called(1);
      verifyNever(() => remote.getJobStatus(any()));
    });

    test('immediate failure on initial upload does not poll remote.getJobStatus', () async {
      const failedJob = ExtractionJobModel(
        id: 'job_fast_fail',
        status: ExtractionStatus.failed,
        errorMessage: 'Corrupted image payload',
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => failedJob);

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.status, equals(ExtractionStatus.failed));
      expect(result.dataOrNull?.errorMessage, equals('Corrupted image payload'));
      verify(() => remote.uploadImage(fakeImage)).called(1);
      verifyNever(() => remote.getJobStatus(any()));
    });

    test('handles status transition: uploading -> processing -> processing -> completed', () async {
      const job1 = ExtractionJobModel(id: 'j_seq', status: ExtractionStatus.uploading);
      const job2 = ExtractionJobModel(id: 'j_seq', status: ExtractionStatus.processing, progress: 0.3);
      const job3 = ExtractionJobModel(id: 'j_seq', status: ExtractionStatus.processing, progress: 0.7);
      const job4 = ExtractionJobModel(id: 'j_seq', status: ExtractionStatus.completed, progress: 1.0, result: samplePoseModel);

      when(() => remote.uploadImage(any())).thenAnswer((_) async => job1);
      var pollCount = 0;
      when(() => remote.getJobStatus('j_seq')).thenAnswer((_) async {
        pollCount++;
        if (pollCount == 1) return job2;
        if (pollCount == 2) return job3;
        return job4;
      });

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 5),
        timeout: const Duration(seconds: 1),
      );

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.status, equals(ExtractionStatus.completed));
      expect(pollCount, equals(3));
      verify(() => remote.getJobStatus('j_seq')).called(3);
    });

    test('handles status regression gracefully (processing -> uploading -> completed)', () async {
      const jobInit = ExtractionJobModel(id: 'j_regr', status: ExtractionStatus.processing, progress: 0.5);
      const jobRegr = ExtractionJobModel(id: 'j_regr', status: ExtractionStatus.uploading, progress: 0.1);
      const jobDone = ExtractionJobModel(id: 'j_regr', status: ExtractionStatus.completed, progress: 1.0, result: samplePoseModel);

      when(() => remote.uploadImage(any())).thenAnswer((_) async => jobInit);
      var pollCount = 0;
      when(() => remote.getJobStatus('j_regr')).thenAnswer((_) async {
        pollCount++;
        return pollCount == 1 ? jobRegr : jobDone;
      });

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 5),
        timeout: const Duration(seconds: 1),
      );

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.status, equals(ExtractionStatus.completed));
      expect(pollCount, equals(2));
    });
  });

  group('STRESS TEST 4: Timeout & Boundary Conditions', () {
    test('zero timeout throws ApiTimeoutException immediately without polling', () async {
      const initialJob = ExtractionJobModel(
        id: 'job_zero_timeout',
        status: ExtractionStatus.processing,
        progress: 0.1,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => initialJob);

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 10),
        timeout: Duration.zero,
      );

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ApiTimeoutException>());
      expect(result.exceptionOrNull?.message, equals('Pose extraction job timed out'));
      verify(() => remote.uploadImage(fakeImage)).called(1);
      verifyNever(() => remote.getJobStatus(any()));
    });

    test('slow remote responses cause cumulative timeout expiration', () async {
      const initialJob = ExtractionJobModel(
        id: 'job_slow_remote',
        status: ExtractionStatus.processing,
        progress: 0.1,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => initialJob);
      when(() => remote.getJobStatus('job_slow_remote')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        return initialJob;
      });

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 5),
        timeout: const Duration(milliseconds: 50),
      );

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ApiTimeoutException>());
    });
  });

  group('STRESS TEST 5: Exception Mapping & Network Failure Scenarios', () {
    test('maps Dio connectionTimeout to ApiTimeoutException', () async {
      when(() => remote.uploadImage(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ApiTimeoutException>());
    });

    test('maps Dio badResponse 401 to UnauthorizedException', () async {
      when(() => remote.uploadImage(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 401),
        ),
      );

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<UnauthorizedException>());
    });

    test('maps Dio badResponse 403 to ForbiddenException', () async {
      when(() => remote.uploadImage(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(), statusCode: 403),
        ),
      );

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ForbiddenException>());
    });

    test('maps Dio badResponse 422 with no_pose_detected to NoPoseDetectedException', () async {
      when(() => remote.uploadImage(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 422,
            data: {'code': 'no_pose_detected'},
          ),
        ),
      );

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<NoPoseDetectedException>());
    });

    test('maps Dio badResponse 422 with field errors to ValidationException', () async {
      when(() => remote.uploadImage(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 422,
            data: {
              'errors': {
                'image': ['Image resolution is too low.'],
              },
            },
          ),
        ),
      );

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ValidationException>());
      final valEx = result.exceptionOrNull as ValidationException;
      expect(valEx.fieldErrors['image'], contains('Image resolution is too low.'));
    });

    test('maps non-Dio unexpected error to UnknownException inside guardApi', () async {
      when(() => remote.uploadImage(any())).thenThrow(StateError('Database disconnected unexpectedly'));

      final result = await repository.uploadAndExtract(imageFile: fakeImage);

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<UnknownException>());
      expect(result.exceptionOrNull?.cause, isA<StateError>());
    });
  });
}
