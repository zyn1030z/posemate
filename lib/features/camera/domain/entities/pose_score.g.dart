// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pose_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PoseScore _$PoseScoreFromJson(Map<String, dynamic> json) => _PoseScore(
  matchPercentage: (json['match_percentage'] as num).toDouble(),
  bodyBalance: (json['body_balance'] as num).toDouble(),
  goodLighting: json['good_lighting'] as bool? ?? true,
  bodyVisible: json['body_visible'] as bool? ?? true,
  feedback:
      (json['feedback'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PoseScoreToJson(_PoseScore instance) =>
    <String, dynamic>{
      'match_percentage': instance.matchPercentage,
      'body_balance': instance.bodyBalance,
      'good_lighting': instance.goodLighting,
      'body_visible': instance.bodyVisible,
      'feedback': instance.feedback,
    };
