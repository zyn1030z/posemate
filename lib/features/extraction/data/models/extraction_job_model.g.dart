// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extraction_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExtractionJobModel _$ExtractionJobModelFromJson(Map<String, dynamic> json) =>
    _ExtractionJobModel(
      id: json['id'] as String,
      status: $enumDecode(_$ExtractionStatusEnumMap, json['status']),
      result: _readPoseResult(json, 'result') == null
          ? null
          : PoseModel.fromJson(
              _readPoseResult(json, 'result') as Map<String, dynamic>,
            ),
      errorMessage: json['error_message'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ExtractionJobModelToJson(_ExtractionJobModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$ExtractionStatusEnumMap[instance.status]!,
      'result': ?instance.result?.toJson(),
      'error_message': ?instance.errorMessage,
      'progress': instance.progress,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };

const _$ExtractionStatusEnumMap = {
  ExtractionStatus.uploading: 'uploading',
  ExtractionStatus.processing: 'processing',
  ExtractionStatus.completed: 'completed',
  ExtractionStatus.failed: 'failed',
};
