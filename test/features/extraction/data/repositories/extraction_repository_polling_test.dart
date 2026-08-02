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
    id: 'pose_999',
    name: 'Tree Pose',
    previewUrl: 'https://example.com/tree.jpg',
    overlayUrl: 'https://example.com/tree_overlay.png',
    categoryId: 'balance',
  );

  group('uploadAndExtract', () {
    test('returns job immediately when upload returns status completed', () async {
      const completedJob = ExtractionJobModel(
        id: 'job_100',
        status: ExtractionStatus.completed,
        progress: 1.0,
        result: samplePoseModel,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => completedJob);

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
      );

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.id, equals('job_100'));
      expect(result.dataOrNull?.status, equals(ExtractionStatus.completed));
      expect(result.dataOrNull?.result, equals(samplePoseModel.toEntity()));

      verify(() => remote.uploadImage(fakeImage)).called(1);
      verifyNever(() => remote.getJobStatus(any()));
    });

    test('returns job immediately when upload returns status failed', () async {
      const failedJob = ExtractionJobModel(
        id: 'job_101',
        status: ExtractionStatus.failed,
        errorMessage: 'Invalid image format',
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => failedJob);

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
      );

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.id, equals('job_101'));
      expect(result.dataOrNull?.status, equals(ExtractionStatus.failed));
      expect(result.dataOrNull?.errorMessage, equals('Invalid image format'));

      verify(() => remote.uploadImage(fakeImage)).called(1);
      verifyNever(() => remote.getJobStatus(any()));
    });

    test('polls until job completes when upload returns status processing', () async {
      const initialJob = ExtractionJobModel(
        id: 'job_102',
        status: ExtractionStatus.processing,
        progress: 0.1,
      );
      const intermediateJob = ExtractionJobModel(
        id: 'job_102',
        status: ExtractionStatus.processing,
        progress: 0.5,
      );
      const finalJob = ExtractionJobModel(
        id: 'job_102',
        status: ExtractionStatus.completed,
        progress: 1.0,
        result: samplePoseModel,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => initialJob);
      var callCount = 0;
      when(() => remote.getJobStatus('job_102')).thenAnswer((_) async {
        callCount++;
        return callCount == 1 ? intermediateJob : finalJob;
      });

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 10),
        timeout: const Duration(seconds: 1),
      );

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.id, equals('job_102'));
      expect(result.dataOrNull?.status, equals(ExtractionStatus.completed));
      expect(result.dataOrNull?.result, equals(samplePoseModel.toEntity()));

      verify(() => remote.uploadImage(fakeImage)).called(1);
      verify(() => remote.getJobStatus('job_102')).called(2);
    });

    test('polls until job fails when status changes to failed', () async {
      const initialJob = ExtractionJobModel(
        id: 'job_103',
        status: ExtractionStatus.uploading,
        progress: 0.2,
      );
      const failedJob = ExtractionJobModel(
        id: 'job_103',
        status: ExtractionStatus.failed,
        errorMessage: 'Extraction engine crash',
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => initialJob);
      when(() => remote.getJobStatus('job_103')).thenAnswer((_) async => failedJob);

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 10),
        timeout: const Duration(seconds: 1),
      );

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.id, equals('job_103'));
      expect(result.dataOrNull?.status, equals(ExtractionStatus.failed));
      expect(result.dataOrNull?.errorMessage, equals('Extraction engine crash'));

      verify(() => remote.uploadImage(fakeImage)).called(1);
      verify(() => remote.getJobStatus('job_103')).called(1);
    });

    test('returns ApiFailure with ApiTimeoutException when polling exceeds timeout', () async {
      const initialJob = ExtractionJobModel(
        id: 'job_104',
        status: ExtractionStatus.processing,
        progress: 0.2,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => initialJob);
      when(() => remote.getJobStatus('job_104')).thenAnswer(
        (_) async => initialJob,
      );

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 20),
        timeout: const Duration(milliseconds: 50),
      );

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ApiTimeoutException>());
      expect(result.exceptionOrNull?.message, equals('Pose extraction job timed out'));
    });

    test('returns ApiFailure when DioException occurs during upload', () async {
      when(() => remote.uploadImage(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
      );

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<NetworkException>());
    });

    test('returns ApiFailure when DioException occurs during polling', () async {
      const initialJob = ExtractionJobModel(
        id: 'job_105',
        status: ExtractionStatus.processing,
      );

      when(() => remote.uploadImage(any())).thenAnswer((_) async => initialJob);
      when(() => remote.getJobStatus('job_105')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 500,
          ),
        ),
      );

      final result = await repository.uploadAndExtract(
        imageFile: fakeImage,
        pollInterval: const Duration(milliseconds: 10),
      );

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<ServerException>());
    });
  });

  group('getJobStatus', () {
    test('returns ApiSuccess with mapped entity when fetch succeeds', () async {
      const jobModel = ExtractionJobModel(
        id: 'job_200',
        status: ExtractionStatus.completed,
        progress: 1.0,
        result: samplePoseModel,
      );

      when(() => remote.getJobStatus('job_200')).thenAnswer((_) async => jobModel);

      final result = await repository.getJobStatus('job_200');

      expect(result, isA<ApiSuccess<ExtractionJob>>());
      expect(result.dataOrNull?.id, equals('job_200'));
      expect(result.dataOrNull?.status, equals(ExtractionStatus.completed));
      expect(result.dataOrNull?.result, equals(samplePoseModel.toEntity()));
    });

    test('returns ApiFailure when remote fetch fails', () async {
      when(() => remote.getJobStatus('job_201')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 404,
          ),
        ),
      );

      final result = await repository.getJobStatus('job_201');

      expect(result, isA<ApiFailure<ExtractionJob>>());
      expect(result.exceptionOrNull, isA<NotFoundException>());
    });
  });
}
