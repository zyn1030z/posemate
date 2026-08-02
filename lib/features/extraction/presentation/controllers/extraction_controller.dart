import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/extraction/data/repositories/extraction_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

class ExtractionController extends AsyncNotifier<Pose?> {
  @override
  FutureOr<Pose?> build() {
    return null;
  }

  /// Extracts a pose from the provided image file.
  Future<void> extractPose(File image) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(extractionRepositoryProvider);
      return await repository.extractPose(image);
    });
  }

  /// Resets the extraction state, e.g. when picking a new image.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final extractionControllerProvider =
    AsyncNotifierProvider<ExtractionController, Pose?>(
        ExtractionController.new);
