import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

part 'extraction_job.freezed.dart';

/// Domain entity representing a pose extraction job and its current progress/result.
@freezed
abstract class ExtractionJob with _$ExtractionJob {
  const factory ExtractionJob({
    required String id,
    required ExtractionStatus status,
    Pose? result,
    String? errorMessage,
    @Default(0.0) double progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ExtractionJob;
}
