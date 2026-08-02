import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

part 'pose.freezed.dart';

/// A single reference pose in the library as seen by the domain layer.
///
/// A pure entity: no wire-format concerns live here — mapping from the API
/// payload happens in the data layer via the pose wire model.
@freezed
abstract class Pose with _$Pose {
  /// Creates a pose.
  const factory Pose({
    /// Opaque server-issued pose identifier.
    required String id,

    /// Display name shown on cards and the detail screen.
    required String name,

    /// URL of the full-color preview photograph.
    required String previewUrl,

    /// URL of the transparent overlay used as the camera guide.
    required String overlayUrl,

    /// Free-form descriptive tags for search and discovery.
    @Default(<String>[]) List<String> tags,

    /// How hard the pose is to recreate.
    @Default(PoseDifficulty.easy) PoseDifficulty difficulty,

    /// Who the pose is designed for.
    @Default(PoseGender.any) PoseGender gender,

    /// Direction the subject's body faces: front, back, side, three-quarter.
    @Default('front') String bodyDirection,

    /// Suggested camera height: eye-level, low, or high.
    @Default('eye-level') String cameraAngle,

    /// Community quality score on a five-point scale.
    @Default(0) double aiScore,

    /// How many times the pose has been downloaded.
    @Default(0) int downloads,

    /// Whether the pose requires an active premium subscription.
    @Default(false) bool isPremium,

    /// Identifier of the category this pose belongs to.
    required String categoryId,
  }) = _Pose;
}
