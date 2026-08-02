import 'dart:math';
import 'package:posely_ai/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:posely_ai/features/ai/data/models/ai_job_model.dart';
import 'package:posely_ai/features/ai/data/models/generate_prompt_model.dart';

/// Simulates a 3-5 second generation process over a series of polling calls.
class AiMockDatasource implements AiRemoteDatasource {
  final Map<String, int> _jobPollCounts = {};
  final Random _random = Random();

  @override
  Future<String> submitGenerateJob(GeneratePromptModel prompt) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final jobId = 'mock_job_${DateTime.now().millisecondsSinceEpoch}';
    _jobPollCounts[jobId] = 0;
    return jobId;
  }

  @override
  Future<AiJobModel<Map<String, dynamic>>> getJobStatus(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    final polls = _jobPollCounts[jobId] ?? 0;
    _jobPollCounts[jobId] = polls + 1;

    if (polls == 0) {
      return AiJobModel<Map<String, dynamic>>(
        jobId: jobId,
        status: 'queued',
        estimatedSeconds: 4,
      );
    } else if (polls < 3) {
      return AiJobModel<Map<String, dynamic>>(
        jobId: jobId,
        status: 'running',
        progress: polls * 33,
        estimatedSeconds: 4 - polls,
      );
    } else {
      // Succeeded after ~3 polls (6 seconds total if polled every 2s)
      return AiJobModel<Map<String, dynamic>>(
        jobId: jobId,
        status: 'succeeded',
        progress: 100,
        result: {
          'poses': [
            {
              'id': 'gen_${_random.nextInt(1000)}',
              'name': 'Generated Pose 1',
              'preview_url': 'https://storage.googleapis.com/posely-assets/mock/generated_1.jpg',
              'overlay_url': 'https://storage.googleapis.com/posely-assets/mock/generated_1_overlay.png',
              'tags': ['generated', 'ai'],
              'difficulty': 'beginner',
              'gender': 'unisex',
              'ai_score': 0.95,
              'downloads': 0,
              'is_premium': false,
              'category_id': 'generated',
            },
            {
              'id': 'gen_${_random.nextInt(1000)}',
              'name': 'Generated Pose 2',
              'preview_url': 'https://storage.googleapis.com/posely-assets/mock/generated_2.jpg',
              'overlay_url': 'https://storage.googleapis.com/posely-assets/mock/generated_2_overlay.png',
              'tags': ['generated', 'ai'],
              'difficulty': 'intermediate',
              'gender': 'unisex',
              'ai_score': 0.88,
              'downloads': 0,
              'is_premium': false,
              'category_id': 'generated',
            }
          ]
        },
      );
    }
  }
}
