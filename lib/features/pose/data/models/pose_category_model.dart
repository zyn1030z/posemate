import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';

part 'pose_category_model.freezed.dart';
part 'pose_category_model.g.dart';

/// Wire model for a category object returned by the taxonomy endpoint.
@freezed
abstract class PoseCategoryModel with _$PoseCategoryModel {
  /// Creates the wire model.
  const factory PoseCategoryModel({
    /// Opaque server-issued category identifier.
    required String id,

    /// Display name of the category.
    required String name,

    /// Single emoji used as the category glyph.
    required String emoji,
  }) = _PoseCategoryModel;

  const PoseCategoryModel._();

  /// Decodes the model from a decoded JSON map.
  factory PoseCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$PoseCategoryModelFromJson(json);

  /// Maps this wire model onto the domain entity.
  PoseCategory toEntity() => PoseCategory(id: id, name: name, emoji: emoji);
}
