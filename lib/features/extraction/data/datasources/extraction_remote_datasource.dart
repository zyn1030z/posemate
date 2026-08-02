import 'dart:io';

import 'package:dio/dio.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:uuid/uuid.dart';

abstract interface class ExtractionRemoteDatasource {
  /// Uploads an image to extract a pose skeleton from it.
  Future<Pose> extractPose(File image);
}

final class ExtractionRemoteDatasourceImpl implements ExtractionRemoteDatasource {
  const ExtractionRemoteDatasourceImpl(this._dio);

  final Dio _dio;

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

    final response = await _dio.post(
      '/ai/extract-pose',
      data: formData,
      options: Options(
        headers: {
          'Idempotency-Key': idempotencyKey,
        },
      ),
    );

    return PoseModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }
}
