import 'package:freezed_annotation/freezed_annotation.dart';

part 'pose_score.freezed.dart';
part 'pose_score.g.dart';

/// Represents the real-time scoring metrics of a pose match.
@freezed
abstract class PoseScore with _$PoseScore {
  /// Creates a [PoseScore].
  const factory PoseScore({
    /// Overall match percentage (0.0 to 1.0).
    required double matchPercentage,
    
    /// Body balance score (0.0 to 1.0).
    required double bodyBalance,
    
    /// True if lighting is considered good.
    @Default(true) bool goodLighting,
    
    /// True if the body is fully visible.
    @Default(true) bool bodyVisible,
    
    /// Optional specific feedback messages.
    @Default([]) List<String> feedback,
  }) = _PoseScore;

  /// Creates a [PoseScore] from JSON.
  factory PoseScore.fromJson(Map<String, dynamic> json) => _$PoseScoreFromJson(json);
}
