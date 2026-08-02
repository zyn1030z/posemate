import 'dart:io';

import 'package:dio/dio.dart';
import 'package:posely_ai/core/config/constants/api_endpoints.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/extraction/data/models/extraction_job_model.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:uuid/uuid.dart';

abstract interface class ExtractionRemoteDatasource {
  /// Uploads an image to start pose extraction, returning the initial [ExtractionJobModel].
  Future<ExtractionJobModel> uploadImage(File image);

  /// Queries the status of an ongoing extraction job.
  Future<ExtractionJobModel> getJobStatus(String jobId);

  /// Uploads an image to extract a pose skeleton directly (retained for backward compatibility).
  Future<Pose> extractPose(File image);
}

final class ExtractionRemoteDatasourceImpl implements ExtractionRemoteDatasource {
  const ExtractionRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ExtractionJobModel> uploadImage(File image) async {
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    final idempotencyKey = const Uuid().v4();

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.extractPose,
      data: formData,
      options: Options(
        headers: {
          'Idempotency-Key': idempotencyKey,
        },
      ),
    );

    return ExtractionJobModel.fromJson(response.data!);
  }

  @override
  Future<ExtractionJobModel> getJobStatus(String jobId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.extractPose}/status/$jobId',
    );

    return ExtractionJobModel.fromJson(response.data!);
  }

  @override
  Future<Pose> extractPose(File image) async {
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    final idempotencyKey = const Uuid().v4();

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.extractPose,
      data: formData,
      options: Options(
        headers: {
          'Idempotency-Key': idempotencyKey,
        },
      ),
    );

    final jobModel = ExtractionJobModel.fromJson(response.data!);
    if (jobModel.result != null) {
      return jobModel.result!.toEntity();
    }
    if (jobModel.status == ExtractionStatus.failed) {
      throw UnknownException(
        message: jobModel.errorMessage ?? 'Pose extraction failed on server.',
      );
    }
    throw const UnknownException(
      message: 'Pose extraction job incomplete or missing result.',
    );
  }
}
