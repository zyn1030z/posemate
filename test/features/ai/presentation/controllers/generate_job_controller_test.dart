import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:posely_ai/features/ai/domain/entities/ai_job.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';
import 'package:posely_ai/features/ai/domain/repositories/ai_repository.dart';
import 'package:posely_ai/features/ai/presentation/controllers/generate_job_controller.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

class MockAiRepository extends Mock implements AiRepository {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  late MockAiRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const GeneratePrompt(
        prompt: 'test',
        count: 1,
        style: 'test',
        peopleCount: PeopleCount.solo,
      ),
    );
    registerFallbackValue(GenerateJobState.idle());
  });

  setUp(() {
    mockRepository = MockAiRepository();
    container = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GenerateJobController', () {
    const tPrompt = GeneratePrompt(
      prompt: 'test',
      count: 4,
      style: 'photo',
      peopleCount: PeopleCount.solo,
    );

    test('initial state is idle', () {
      final state = container.read(generateJobControllerProvider);
      expect(state.isIdle, isTrue);
    });

    test('submit sets error on failure', () async {
      when(() => mockRepository.submitGenerateJob(any()))
          .thenAnswer((_) async => const ApiFailure(UnknownException(message: 'Failed')));

      final controller = container.read(generateJobControllerProvider.notifier);
      await controller.submit(tPrompt);

      final state = container.read(generateJobControllerProvider);
      expect(state.error, 'Failed');
      expect(state.isIdle, isFalse);
    });

    test('submit starts polling and updates state to success on completion', () async {
      when(() => mockRepository.submitGenerateJob(any()))
          .thenAnswer((_) async => const ApiSuccess('job-123'));

      // First poll: queued
      when(() => mockRepository.pollGenerateJob('job-123')).thenAnswer(
          (_) async => const ApiSuccess(AiJob<List<Pose>>(
                jobId: 'job-123',
                status: AiJobStatus.queued,
              )));

      final listener = Listener<GenerateJobState>();
      container.listen(
        generateJobControllerProvider,
        listener.call,
        fireImmediately: true,
      );

      final controller = container.read(generateJobControllerProvider.notifier);
      await controller.submit(tPrompt);

      // Verify submit transition
      verify(() => listener.call(any(), any())).called(greaterThan(0));

      final state = container.read(generateJobControllerProvider);
      expect(state.isPolling, isTrue);
      expect(state.job?.jobId, 'job-123');

      // Next poll: success
      when(() => mockRepository.pollGenerateJob('job-123')).thenAnswer(
          (_) async => const ApiSuccess(AiJob<List<Pose>>(
                jobId: 'job-123',
                status: AiJobStatus.succeeded,
                result: [],
              )));

      // Wait for timer to tick (2 seconds)
      await Future<void>.delayed(const Duration(seconds: 3));

      final finalState = container.read(generateJobControllerProvider);
      expect(finalState.error, isNull);
      expect(finalState.job?.status, AiJobStatus.succeeded);
    });
  });
}
