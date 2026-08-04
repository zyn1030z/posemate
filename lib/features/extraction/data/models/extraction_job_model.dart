import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_job.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';

part 'extraction_job_model.freezed.dart';
part 'extraction_job_model.g.dart';

Object? _readPoseResult(Map<dynamic, dynamic> json, String key) {
  return json['result'] ?? json['pose'];
}

/// Wire model for pose extraction job returned by the server endpoints.
@freezed
abstract class ExtractionJobModel with _$ExtractionJobModel {
  /// Creates the wire model.
  const factory ExtractionJobModel({
    required String id,
    required ExtractionStatus status,
    @JsonKey(readValue: _readPoseResult) PoseModel? result,
    String? errorMessage,
    @Default(0.0) double progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ExtractionJobModel;

  const ExtractionJobModel._();

  /// Decodes the model from a JSON map.
  factory ExtractionJobModel.fromJson(Map<String, dynamic> json) =>
      _$ExtractionJobModelFromJson(json);

  /// Maps this wire model onto the domain entity [ExtractionJob].
  ExtractionJob toEntity() => ExtractionJob(
    id: id,
    status: status,
    result: result?.toEntity(),
    errorMessage: errorMessage,
    progress: progress,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
