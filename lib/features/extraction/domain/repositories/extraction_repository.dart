import 'dart:io';

import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_job.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

/// Contract for the pose extraction repository.
abstract interface class ExtractionRepository {
  /// Uploads an image to initiate pose extraction and polls until the job reaches
  /// a terminal state ([ExtractionStatus.completed] or [ExtractionStatus.failed])
  /// or times out.
  Future<ApiResult<ExtractionJob>> uploadAndExtract({
    required File imageFile,
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(milliseconds: 500),
  });

  /// Fetches the current status of an ongoing pose extraction job.
  Future<ApiResult<ExtractionJob>> getJobStatus(String jobId);

  /// Extracts a pose from the given image (retained for backward compatibility).
  ///
  /// Tries the remote API first; falls back to on-device ML Kit on network errors.
  Future<Pose> extractPose(File image);
}
