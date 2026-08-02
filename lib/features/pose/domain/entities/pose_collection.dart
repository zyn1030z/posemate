import 'package:freezed_annotation/freezed_annotation.dart';

part 'pose_collection.freezed.dart';

/// A named user-created group of poses.
///
/// Collections are stored device-locally and hold only pose ids — the actual
/// pose data is fetched on-demand from the library. This keeps the storage
/// footprint minimal and avoids stale copies.
@freezed
abstract class PoseCollection with _$PoseCollection {
  /// Creates a collection.
  const factory PoseCollection({
    /// Unique identifier for the collection.
    required String id,

    /// User-chosen display name.
    required String name,

    /// Ordered list of pose ids belonging to this collection.
    @Default(<String>[]) List<String> poseIds,

    /// When the collection was first created.
    required DateTime createdAt,

    /// When the collection was last modified (renamed, pose added/removed).
    required DateTime updatedAt,
  }) = _PoseCollection;
}
