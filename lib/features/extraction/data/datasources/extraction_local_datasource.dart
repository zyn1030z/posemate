import 'dart:io';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as mlkit;
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:uuid/uuid.dart';

abstract interface class ExtractionLocalDatasource {
  /// Uses ML Kit to extract a pose skeleton locally.
  Future<PoseModel> extractPose(File image);
}

final class ExtractionLocalDatasourceImpl implements ExtractionLocalDatasource {
  const ExtractionLocalDatasourceImpl();

  @override
  Future<PoseModel> extractPose(File image) async {
    final inputImage = mlkit.InputImage.fromFile(image);
    
    // We use the base pose detector for fast local extraction.
    final poseDetector = mlkit.PoseDetector(
      options: mlkit.PoseDetectorOptions(
        mode: mlkit.PoseDetectionMode.single,
      ),
    );

    try {
      final poses = await poseDetector.processImage(inputImage);
      if (poses.isEmpty) {
        throw const NoPoseDetectedException();
      }

      // We don't have a backend-generated overlay URL.
      // We return the local file path as a placeholder, and the UI
      // would need to adapt to rendering ML Kit poses or local files.
      // For Phase 7, we just construct the model.
      return PoseModel(
        id: 'local_${const Uuid().v4()}',
        name: 'Extracted Pose',
        previewUrl: 'file://${image.path}',
        overlayUrl: 'file://${image.path}', // Would require local drawing to be a real overlay
        categoryId: 'extracted',
        tags: ['local', 'extracted'],
      );
    } finally {
      await poseDetector.close();
    }
  }
}
