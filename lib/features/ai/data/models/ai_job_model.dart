import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/ai/domain/entities/ai_job.dart';

part 'ai_job_model.freezed.dart';
part 'ai_job_model.g.dart';

/// Wire model for an AI job response.
///
/// Keys arrive in snake_case. `T` is the type of the result payload.
@Freezed(genericArgumentFactories: true)
abstract class AiJobModel<T> with _$AiJobModel<T> {
  /// Creates the wire model.
  const factory AiJobModel({
    required String jobId,
    required String status,
    @Default(0) int progress,
    int? estimatedSeconds,
    T? result,
    String? error,
  }) = _AiJobModel<T>;

  const AiJobModel._();

  /// Decodes from JSON.
  factory AiJobModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$AiJobModelFromJson(json, fromJsonT);

  /// Converts the wire model to a domain entity.
  AiJob<E> toEntity<E>(E Function(T) resultMapper) {
    return AiJob<E>(
      jobId: jobId,
      status: _mapStatus(status),
      progress: progress,
      estimatedSeconds: estimatedSeconds,
      result: result != null ? resultMapper(result as T) : null,
      error: error,
    );
  }

  AiJobStatus _mapStatus(String status) {
    return switch (status) {
      'queued' => AiJobStatus.queued,
      'running' => AiJobStatus.running,
      'succeeded' => AiJobStatus.succeeded,
      'failed' => AiJobStatus.failed,
      _ => AiJobStatus.failed, // Fallback for unknown status
    };
  }
}
