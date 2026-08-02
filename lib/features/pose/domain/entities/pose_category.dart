import 'package:freezed_annotation/freezed_annotation.dart';

part 'pose_category.freezed.dart';

/// A themed group in the pose library taxonomy, such as Beach or Cafe.
///
/// A pure entity: mapping from the API payload happens in the data layer via
/// the category wire model.
@freezed
abstract class PoseCategory with _$PoseCategory {
  /// Creates a category.
  const factory PoseCategory({
    /// Opaque server-issued category identifier.
    required String id,

    /// Display name shown on chips and section headers.
    required String name,

    /// Single emoji used as the category glyph.
    required String emoji,
  }) = _PoseCategory;
}
