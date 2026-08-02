import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/dio_client.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_local_datasource.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_remote_datasource.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_job.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/extraction/domain/repositories/extraction_repository.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

export 'package:posely_ai/features/extraction/domain/repositories/extraction_repository.dart';

class ExtractionRepositoryImpl implements ExtractionRepository {
  const ExtractionRepositoryImpl(this._remote, this._local);

  final ExtractionRemoteDatasource _remote;
  final ExtractionLocalDatasource _local;

  @override
  Future<ApiResult<ExtractionJob>> uploadAndExtract({
    required File imageFile,
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(milliseconds: 500),
  }) {
    return guardApi(() async {
      final initialJobModel = await _remote.uploadImage(imageFile);
      if (initialJobModel.status == ExtractionStatus.completed ||
          initialJobModel.status == ExtractionStatus.failed) {
        return initialJobModel.toEntity();
      }

      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed < timeout) {
        await Future<void>.delayed(pollInterval);
        final currentJobModel = await _remote.getJobStatus(initialJobModel.id);
        if (currentJobModel.status == ExtractionStatus.completed ||
            currentJobModel.status == ExtractionStatus.failed) {
          return currentJobModel.toEntity();
        }
      }

      throw const AppException.apiTimeout(
        message: 'Pose extraction job timed out',
      );
    });
  }

  @override
  Future<ApiResult<ExtractionJob>> getJobStatus(String jobId) {
    return guardApi(() async {
      final jobModel = await _remote.getJobStatus(jobId);
      return jobModel.toEntity();
    });
  }

  @override
  Future<Pose> extractPose(File image) async {
    try {
      return await _remote.extractPose(image);
    } on DioException catch (e) {
      final appException = AppException.fromDio(e);

      // If the API explicitly says no pose detected (422 code), throw it
      // so the user knows. No need to fallback if the cloud model says no pose.
      if (appException is NoPoseDetectedException) {
        throw appException;
      }

      // For network errors, timeouts, or server errors, fallback to local ML Kit.
      if (appException is NetworkException ||
          appException is ApiTimeoutException ||
          appException is ServerException) {
        final localModel = await _local.extractPose(image);
        return localModel.toEntity();
      }

      // For other exceptions (like 401 Unauthorized), let them bubble up.
      throw appException;
    } catch (e) {
      // For any other unexpected errors, try fallback.
      final localModel = await _local.extractPose(image);
      return localModel.toEntity();
    }
  }
}

final extractionRepositoryProvider = Provider<ExtractionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExtractionRepositoryImpl(
    ExtractionRemoteDatasourceImpl(dio),
    const ExtractionLocalDatasourceImpl(),
  );
});
