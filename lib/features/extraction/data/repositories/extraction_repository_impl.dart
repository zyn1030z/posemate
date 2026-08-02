import 'dart:io';

import 'package:dio/dio.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/dio_client.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_local_datasource.dart';
import 'package:posely_ai/features/extraction/data/datasources/extraction_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

abstract interface class ExtractionRepository {
  /// Extracts a pose from the given image.
  /// 
  /// Tries the remote API first. If it fails due to connectivity or server
  /// errors, falls back to the on-device ML Kit extraction.
  /// Throws [NoPoseDetectedException] if no person is found in the image.
  Future<Pose> extractPose(File image);
}

class ExtractionRepositoryImpl implements ExtractionRepository {
  const ExtractionRepositoryImpl(this._remote, this._local);

  final ExtractionRemoteDatasource _remote;
  final ExtractionLocalDatasource _local;

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
