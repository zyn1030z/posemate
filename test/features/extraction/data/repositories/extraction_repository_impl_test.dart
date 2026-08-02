import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_local_datasource.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_remote_datasource.dart';
import 'package:posely_ai/features/extraction/data/repositories/extraction_repository_impl.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

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

  const dummyPoseEntity = Pose(
    id: 'pose_123',
    name: 'Extracted Pose',
    previewUrl: 'https://example.com/preview.png',
    overlayUrl: 'https://example.com/overlay.png',
    categoryId: 'extracted',
  );

  const dummyLocalPoseModel = PoseModel(
    id: 'local_123',
    name: 'Local Pose',
    previewUrl: 'file://fake.png',
    overlayUrl: 'file://fake.png',
    categoryId: 'extracted',
  );

  test('extractPose returns remote pose on success', () async {
    when(() => remote.extractPose(any())).thenAnswer((_) async => dummyPoseEntity);

    final result = await repository.extractPose(fakeImage);

    expect(result, equals(dummyPoseEntity));
    verify(() => remote.extractPose(fakeImage)).called(1);
    verifyNever(() => local.extractPose(any()));
  });

  test('extractPose falls back to local on network error', () async {
    when(() => remote.extractPose(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );
    when(() => local.extractPose(any())).thenAnswer((_) async => dummyLocalPoseModel);

    final result = await repository.extractPose(fakeImage);

    expect(result, equals(dummyLocalPoseModel.toEntity()));
    verify(() => remote.extractPose(fakeImage)).called(1);
    verify(() => local.extractPose(fakeImage)).called(1);
  });

  test('extractPose throws NoPoseDetectedException if remote throws it', () async {
    final dioError = DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: 422,
        data: {'code': 'no_pose_detected'},
      ),
    );
    when(() => remote.extractPose(any())).thenThrow(dioError);

    expect(
      () => repository.extractPose(fakeImage),
      throwsA(isA<NoPoseDetectedException>()),
    );
    verify(() => remote.extractPose(fakeImage)).called(1);
    verifyNever(() => local.extractPose(any()));
  });
}
