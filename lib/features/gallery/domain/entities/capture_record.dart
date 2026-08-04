import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture_record.freezed.dart';
part 'capture_record.g.dart';

/// Represents a local capture and its sync state with the remote gallery.
@freezed
abstract class CaptureRecord with _$CaptureRecord {
  const factory CaptureRecord({
    /// Unique identifier for this capture.
    required String id,

    /// Local file path on the device.
    required String localPath,

    /// Remote URL if synced with the server. Null if not synced.
    String? remoteUrl,

    /// The ID of the pose template used, if any.
    String? poseId,

    /// The match percentage score achieved (0.0 to 1.0).
    double? score,

    /// When the photo was captured.
    required DateTime timestamp,

    /// Whether this record has been successfully synced to the backend.
    @Default(false) bool isSynced,
  }) = _CaptureRecord;

  /// Creates a [CaptureRecord] from a JSON map (used for API and Hive).
  factory CaptureRecord.fromJson(Map<String, dynamic> json) =>
      _$CaptureRecordFromJson(json);
}
