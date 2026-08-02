// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_prompt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GeneratePromptModel _$GeneratePromptModelFromJson(Map<String, dynamic> json) =>
    _GeneratePromptModel(
      prompt: json['prompt'] as String,
      count: (json['count'] as num).toInt(),
      style: json['style'] as String,
      peopleCount: json['people_count'] as String,
    );

Map<String, dynamic> _$GeneratePromptModelToJson(
  _GeneratePromptModel instance,
) => <String, dynamic>{
  'prompt': instance.prompt,
  'count': instance.count,
  'style': instance.style,
  'people_count': instance.peopleCount,
};
