// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pose_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PoseModel _$PoseModelFromJson(Map<String, dynamic> json) => _PoseModel(
  id: json['id'] as String,
  name: json['name'] as String,
  previewUrl: json['preview_url'] as String,
  overlayUrl: json['overlay_url'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  difficulty: json['difficulty'] as String? ?? 'easy',
  gender: json['gender'] as String? ?? 'any',
  bodyDirection: json['body_direction'] as String? ?? 'front',
  cameraAngle: json['camera_angle'] as String? ?? 'eye-level',
  aiScore: (json['ai_score'] as num?)?.toDouble() ?? 0,
  downloads: (json['downloads'] as num?)?.toInt() ?? 0,
  isPremium: json['is_premium'] as bool? ?? false,
  categoryId: json['category_id'] as String,
);

Map<String, dynamic> _$PoseModelToJson(_PoseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'preview_url': instance.previewUrl,
      'overlay_url': instance.overlayUrl,
      'tags': instance.tags,
      'difficulty': instance.difficulty,
      'gender': instance.gender,
      'body_direction': instance.bodyDirection,
      'camera_angle': instance.cameraAngle,
      'ai_score': instance.aiScore,
      'downloads': instance.downloads,
      'is_premium': instance.isPremium,
      'category_id': instance.categoryId,
    };
