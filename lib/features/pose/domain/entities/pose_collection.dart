/// A named user-created group of poses.
///
/// Collections are stored device-locally and hold only pose ids — the actual
/// pose data is fetched on-demand from the library. This keeps the storage
/// footprint minimal and avoids stale copies.
class PoseCollection {
  /// Creates a collection.
  const PoseCollection({
    required this.id,
    required this.name,
    this.poseIds = const <String>[],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for the collection.
  final String id;

  /// User-chosen display name.
  final String name;

  /// Ordered list of pose ids belonging to this collection.
  final List<String> poseIds;

  /// When the collection was first created.
  final DateTime createdAt;

  /// When the collection was last modified (renamed, pose added/removed).
  final DateTime updatedAt;

  /// Creates a copy with the given fields replaced.
  PoseCollection copyWith({
    String? id,
    String? name,
    List<String>? poseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoseCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      poseIds: poseIds ?? this.poseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes to a JSON-compatible map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'pose_ids': poseIds,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Deserializes from a JSON-compatible map.
  ///
  /// Returns null when the map is corrupt or missing required fields.
  static PoseCollection? tryFromJson(Map<String, dynamic> json) {
    try {
      return PoseCollection(
        id: json['id'] as String,
        name: json['name'] as String,
        poseIds: (json['pose_ids'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const <String>[],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! PoseCollection) {
      return false;
    }
    if (id != other.id ||
        name != other.name ||
        createdAt != other.createdAt ||
        updatedAt != other.updatedAt ||
        poseIds.length != other.poseIds.length) {
      return false;
    }
    for (var i = 0; i < poseIds.length; i++) {
      if (poseIds[i] != other.poseIds[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(poseIds));

  @override
  String toString() =>
      'PoseCollection(id: $id, name: $name, poses: ${poseIds.length})';
}
