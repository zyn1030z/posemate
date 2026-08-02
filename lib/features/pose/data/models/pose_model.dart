import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

part 'pose_model.freezed.dart';
part 'pose_model.g.dart';

/// Wire model for a pose object returned by the pose endpoints.
///
/// Keys arrive in snake_case and are renamed automatically by the global
/// json_serializable configuration. Difficulty and gender travel as plain
/// strings and are converted to enums only when mapping to the entity, so
/// an unknown server value degrades to a sensible default instead of
/// failing the whole decode.
@freezed
abstract class PoseModel with _$PoseModel {
  /// Creates the wire model.
  const factory PoseModel({
    /// Opaque server-issued pose identifier.
    required String id,

    /// Display name of the pose.
    required String name,

    /// URL of the full-color preview photograph.
    required String previewUrl,

    /// URL of the transparent overlay used as the camera guide.
    required String overlayUrl,

    /// Free-form descriptive tags.
    @Default(<String>[]) List<String> tags,

    /// Difficulty as sent on the wire: easy, medium, or hard.
    @Default('easy') String difficulty,

    /// Target audience as sent on the wire: female, male, couple, or any.
    @Default('any') String gender,

    /// Direction the subject's body faces.
    @Default('front') String bodyDirection,

    /// Suggested camera height.
    @Default('eye-level') String cameraAngle,

    /// Community quality score on a five-point scale.
    @Default(0) double aiScore,

    /// How many times the pose has been downloaded.
    @Default(0) int downloads,

    /// Whether the pose requires an active premium subscription.
    @Default(false) bool isPremium,

    /// Identifier of the category this pose belongs to.
    required String categoryId,
  }) = _PoseModel;

  const PoseModel._();

  /// Decodes the model from a decoded JSON map.
  factory PoseModel.fromJson(Map<String, dynamic> json) =>
      _$PoseModelFromJson(json);

  /// Maps this wire model onto the domain entity.
  ///
  /// Unknown difficulty or gender strings fall back to the entity defaults
  /// rather than throwing, keeping the app tolerant of contract additions.
  Pose toEntity() => Pose(
    id: id,
    name: name,
    previewUrl: previewUrl,
    overlayUrl: overlayUrl,
    tags: tags,
    difficulty: PoseDifficulty.tryParse(difficulty) ?? PoseDifficulty.easy,
    gender: PoseGender.tryParse(gender) ?? PoseGender.any,
    bodyDirection: bodyDirection,
    cameraAngle: cameraAngle,
    aiScore: aiScore,
    downloads: downloads,
    isPremium: isPremium,
    categoryId: categoryId,
  );
}
