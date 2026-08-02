import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:posely_ai/features/ai/data/models/ai_job_model.dart';
import 'package:posely_ai/features/ai/data/models/generate_prompt_model.dart';
import 'package:posely_ai/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:posely_ai/features/ai/domain/entities/ai_job.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

class MockAiRemoteDatasource extends Mock implements AiRemoteDatasource {}

void main() {
  late MockAiRemoteDatasource mockDatasource;
  late AiRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const GeneratePromptModel(
        prompt: 'test',
        count: 1,
        style: 'test',
        peopleCount: 'solo',
      ),
    );
  });

  setUp(() {
    mockDatasource = MockAiRemoteDatasource();
    repository = AiRepositoryImpl(remoteDatasource: mockDatasource);
  });

  group('submitGenerateJob', () {
    const tPrompt = GeneratePrompt(
      prompt: 'test',
      count: 4,
      style: 'photo',
      peopleCount: PeopleCount.solo,
    );

    test('returns job ID on success', () async {
      when(() => mockDatasource.submitGenerateJob(any()))
          .thenAnswer((_) async => 'job-123');

      final result = await repository.submitGenerateJob(tPrompt);

      result.fold(
        onSuccess: (jobId) => expect(jobId, 'job-123'),
        onFailure: (_) => fail('Should succeed'),
      );
    });

    test('returns exception on failure', () async {
      when(() => mockDatasource.submitGenerateJob(any()))
          .thenThrow(const UnknownException(message: 'Network error'));

      final result = await repository.submitGenerateJob(tPrompt);

      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (exception) => expect(exception, isA<UnknownException>()),
      );
    });
  });

  group('pollGenerateJob', () {
    test('returns job on success', () async {
      const tJobModel = AiJobModel<Map<String, dynamic>>(
        jobId: 'job-123',
        status: 'queued',
      );

      when(() => mockDatasource.getJobStatus('job-123'))
          .thenAnswer((_) async => tJobModel);

      final result = await repository.pollGenerateJob('job-123');

      result.fold(
        onSuccess: (job) {
          expect(job.jobId, 'job-123');
          expect(job.status, AiJobStatus.queued);
        },
        onFailure: (_) => fail('Should succeed'),
      );
    });
  });
}
