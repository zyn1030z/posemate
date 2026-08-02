import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_job.freezed.dart';

/// The status of an asynchronous AI job.
enum AiJobStatus {
  queued,
  running,
  succeeded,
  failed,
}

/// A generic envelope for polling async backend jobs (e.g. pose generation).
@Freezed(genericArgumentFactories: true)
abstract class AiJob<T> with _$AiJob<T> {
  const factory AiJob({
    /// The unique identifier used for polling.
    required String jobId,

    /// The current state of the job.
    required AiJobStatus status,

    /// Progress percentage (0-100).
    @Default(0) int progress,

    /// Estimated time remaining in seconds.
    int? estimatedSeconds,

    /// The final result payload, present only when status is succeeded.
    T? result,

    /// Error details, present only when status is failed.
    String? error,
  }) = _AiJob<T>;
}
