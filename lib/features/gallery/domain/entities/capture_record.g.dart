// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaptureRecord _$CaptureRecordFromJson(Map<String, dynamic> json) =>
    _CaptureRecord(
      id: json['id'] as String,
      localPath: json['local_path'] as String,
      remoteUrl: json['remote_url'] as String?,
      poseId: json['pose_id'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
    );

Map<String, dynamic> _$CaptureRecordToJson(_CaptureRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'local_path': instance.localPath,
      'remote_url': ?instance.remoteUrl,
      'pose_id': ?instance.poseId,
      'score': ?instance.score,
      'timestamp': instance.timestamp.toIso8601String(),
      'is_synced': instance.isSynced,
    };
