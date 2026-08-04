// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiCoach _$AiCoachFromJson(Map<String, dynamic> json) => _AiCoach(
  id: json['id'] as String,
  name: json['name'] as String,
  specialization: json['specialization'] as String,
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['review_count'] as num).toInt(),
  imageUrl: json['image_url'] as String,
  description: json['description'] as String,
  voicePitch: (json['voice_pitch'] as num?)?.toDouble() ?? 1.0,
  voiceRate: (json['voice_rate'] as num?)?.toDouble() ?? 0.5,
);

Map<String, dynamic> _$AiCoachToJson(_AiCoach instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'specialization': instance.specialization,
  'rating': instance.rating,
  'review_count': instance.reviewCount,
  'image_url': instance.imageUrl,
  'description': instance.description,
  'voice_pitch': instance.voicePitch,
  'voice_rate': instance.voiceRate,
};
