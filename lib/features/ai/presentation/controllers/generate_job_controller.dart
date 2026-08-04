import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posely_ai/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:posely_ai/features/ai/domain/entities/ai_job.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';
import 'package:posely_ai/features/ai/domain/repositories/ai_repository.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

/// State of the AI pose generation job.
class GenerateJobState {
  const GenerateJobState({
    this.isIdle = true,
    this.isSubmitting = false,
    this.isPolling = false,
    this.job,
    this.error,
  });

  factory GenerateJobState.idle() => const GenerateJobState();

  factory GenerateJobState.submitting() =>
      const GenerateJobState(isIdle: false, isSubmitting: true);

  factory GenerateJobState.polling(AiJob<List<Pose>> job) =>
      GenerateJobState(isIdle: false, isPolling: true, job: job);

  factory GenerateJobState.success(AiJob<List<Pose>> job) =>
      GenerateJobState(isIdle: false, job: job);

  factory GenerateJobState.error(String message, {AiJob<List<Pose>>? job}) =>
      GenerateJobState(isIdle: false, error: message, job: job);

  final bool isIdle;
  final bool isSubmitting;
  final bool isPolling;
  final AiJob<List<Pose>>? job;
  final String? error;

  bool get isGenerating => isSubmitting || isPolling;
}

/// Controller managing the submit and poll lifecycle of a pose generation job.
class GenerateJobController extends Notifier<GenerateJobState> {
  Timer? _pollingTimer;

  AiRepository get _repository => ref.read(aiRepositoryProvider);

  @override
  GenerateJobState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return GenerateJobState.idle();
  }

  /// Submits the prompt and starts polling automatically.
  Future<void> submit(GeneratePrompt prompt) async {
    if (state.isGenerating) return;
    state = GenerateJobState.submitting();

    final submitResult = await _repository.submitGenerateJob(prompt);

    submitResult.fold(
      onSuccess: (jobId) {
        _startPolling(jobId);
      },
      onFailure: (exception) {
        state = GenerateJobState.error(exception.message);
      },
    );
  }

  void _startPolling(String jobId) {
    // Initial synthetic polling state
    state = GenerateJobState.polling(
      AiJob<List<Pose>>(jobId: jobId, status: AiJobStatus.queued),
    );

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final pollResult = await _repository.pollGenerateJob(jobId);

      pollResult.fold(
        onSuccess: (job) {
          switch (job.status) {
            case AiJobStatus.queued:
            case AiJobStatus.running:
              state = GenerateJobState.polling(job);
            case AiJobStatus.succeeded:
              timer.cancel();
              state = GenerateJobState.success(job);
            case AiJobStatus.failed:
              timer.cancel();
              state = GenerateJobState.error(
                job.error ?? 'Generation failed',
                job: job,
              );
          }
        },
        onFailure: (exception) {
          timer.cancel();
          state = GenerateJobState.error(exception.message, job: state.job);
        },
      );
    });
  }

  /// Resets the generator state to idle, allowing a new prompt.
  void reset() {
    _pollingTimer?.cancel();
    state = GenerateJobState.idle();
  }
}

final generateJobControllerProvider =
    NotifierProvider<GenerateJobController, GenerateJobState>(
      GenerateJobController.new,
    );
