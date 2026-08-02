import 'package:dio/dio.dart';
import 'package:posely_ai/core/config/constants/api_endpoints.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/ai/data/models/ai_job_model.dart';
import 'package:posely_ai/features/ai/data/models/generate_prompt_model.dart';

/// Remote source of truth for AI endpoints (generation, extraction).
abstract interface class AiRemoteDatasource {
  /// Submits a prompt to generate poses. Returns a job ID.
  Future<String> submitGenerateJob(GeneratePromptModel prompt);

  /// Polls the status of an AI job.
  ///
  /// For pose generation, the generic type `T` will be decoded into a Map containing
  /// the 'poses' list, which will then be parsed into `PoseModel` objects in the repo.
  Future<AiJobModel<Map<String, dynamic>>> getJobStatus(String jobId);
}

/// Dio-backed implementation talking to the real backend.
class AiApiDatasource implements AiRemoteDatasource {
  /// Creates the datasource with the app-wide Dio client.
  const AiApiDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<String> submitGenerateJob(GeneratePromptModel prompt) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.generatePoses,
      data: prompt.toJson(),
    );
    final data = _requireBody(response);
    final jobId = data['job_id'] as String?;
    if (jobId == null) {
      throw const UnknownException(
        message: 'Missing job_id in generate-poses response.',
      );
    }
    return jobId;
  }

  @override
  Future<AiJobModel<Map<String, dynamic>>> getJobStatus(String jobId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.generatePoses.replaceFirst('generate-poses', 'jobs')}/$jobId', // Quick string replace for /ai/jobs/{id}
    );
    final data = _requireBody(response);
    return AiJobModel<Map<String, dynamic>>.fromJson(
      data,
      (json) => json as Map<String, dynamic>,
    );
  }

  static Map<String, dynamic> _requireBody(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data;
    if (data == null) {
      throw UnknownException(
        message: 'Empty AI response body from ${response.requestOptions.path}.',
      );
    }
    return data;
  }
}
