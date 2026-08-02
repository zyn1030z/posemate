import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/ai/domain/entities/ai_job.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

/// Repository for AI generation and extraction operations.
abstract interface class AiRepository {
  /// Submits a prompt to generate poses. Returns the job ID on success.
  Future<ApiResult<String>> submitGenerateJob(GeneratePrompt prompt);

  /// Polls the status of a pose generation job.
  Future<ApiResult<AiJob<List<Pose>>>> pollGenerateJob(String jobId);
}
