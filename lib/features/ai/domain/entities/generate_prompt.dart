import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

part 'generate_prompt.freezed.dart';

/// Immutable prompt specifying what kind of pose to generate.
@freezed
abstract class GeneratePrompt with _$GeneratePrompt {
  const factory GeneratePrompt({
    /// The free-text scene description.
    required String prompt,

    /// How many pose variations to generate.
    required int count,

    /// The artistic style (e.g. 'photo', 'illustration', 'sketch').
    required String style,

    /// How many people are in the scene (solo, duo).
    required PeopleCount peopleCount,
  }) = _GeneratePrompt;
}
