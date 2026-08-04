import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_coach.freezed.dart';
part 'ai_coach.g.dart';

/// Represents an AI Coach persona.
@freezed
abstract class AiCoach with _$AiCoach {
  /// Creates an [AiCoach].
  const factory AiCoach({
    required String id,
    required String name,
    required String specialization,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required String description,
    @Default(1.0) double voicePitch,
    @Default(0.5) double voiceRate,
  }) = _AiCoach;

  /// Creates an [AiCoach] from JSON.
  factory AiCoach.fromJson(Map<String, dynamic> json) => _$AiCoachFromJson(json);
}
