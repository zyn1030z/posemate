import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/ai/data/datasources/ai_mock_datasource.dart';
import 'package:posely_ai/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:posely_ai/features/ai/data/models/generate_prompt_model.dart';
import 'package:posely_ai/features/ai/domain/entities/ai_job.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';
import 'package:posely_ai/features/ai/domain/repositories/ai_repository.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl({required AiRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  final AiRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<String>> submitGenerateJob(GeneratePrompt prompt) async {
    return guardApi(() async {
      return _remoteDatasource.submitGenerateJob(
        GeneratePromptModel.fromEntity(prompt),
      );
    });
  }

  @override
  Future<ApiResult<AiJob<List<Pose>>>> pollGenerateJob(String jobId) async {
    return guardApi(() async {
      final jobModel = await _remoteDatasource.getJobStatus(jobId);
      return jobModel.toEntity((Map<String, dynamic> rawResult) {
        final posesJson = rawResult['poses'] as List<dynamic>? ?? <dynamic>[];
        return posesJson.map((dynamic p) {
          return PoseModel.fromJson(p as Map<String, dynamic>).toEntity();
        }).toList();
      });
    });
  }
}

/// Provides the remote AI datasource. Uses the mock implementation for development.
final aiRemoteDatasourceProvider = Provider<AiRemoteDatasource>((ref) {
  // In a real app we'd switch based on flavor/env. Using mock for Phase 6 dev.
  return AiMockDatasource();
});

/// Provides the AI repository.
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(
    remoteDatasource: ref.watch(aiRemoteDatasourceProvider),
  );
});
