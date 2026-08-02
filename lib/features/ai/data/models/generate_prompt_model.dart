import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';

part 'generate_prompt_model.freezed.dart';
part 'generate_prompt_model.g.dart';

/// Wire model for submitting a generation prompt.
///
/// Converts domain enums to wire strings (e.g., people_count).
@freezed
abstract class GeneratePromptModel with _$GeneratePromptModel {
  /// Creates the wire model.
  const factory GeneratePromptModel({
    required String prompt,
    required int count,
    required String style,
    required String peopleCount,
  }) = _GeneratePromptModel;

  const GeneratePromptModel._();

  /// Decodes from JSON.
  factory GeneratePromptModel.fromJson(Map<String, dynamic> json) =>
      _$GeneratePromptModelFromJson(json);

  /// Creates a wire model from a domain entity.
  factory GeneratePromptModel.fromEntity(GeneratePrompt entity) =>
      GeneratePromptModel(
        prompt: entity.prompt,
        count: entity.count,
        style: entity.style,
        peopleCount: entity.peopleCount.name,
      );
}
