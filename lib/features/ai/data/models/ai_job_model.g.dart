// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiJobModel<T> _$AiJobModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _AiJobModel<T>(
  jobId: json['job_id'] as String,
  status: json['status'] as String,
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  estimatedSeconds: (json['estimated_seconds'] as num?)?.toInt(),
  result: _$nullableGenericFromJson(json['result'], fromJsonT),
  error: json['error'] as String?,
);

Map<String, dynamic> _$AiJobModelToJson<T>(
  _AiJobModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'job_id': instance.jobId,
  'status': instance.status,
  'progress': instance.progress,
  'estimated_seconds': ?instance.estimatedSeconds,
  'result': ?_$nullableGenericToJson(instance.result, toJsonT),
  'error': ?instance.error,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
