import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

/// A single pose by id for the detail screen.
///
/// Auto-disposed so a closed detail screen does not pin stale data;
/// failures are rethrown as the provider's error for AsyncValue
/// consumers to render.
final poseDetailProvider =
    FutureProvider.autoDispose.family<Pose, String>((ref, id) async {
  final result = await ref.watch(poseRepositoryProvider).getPoseById(id);
  return result.fold(
    onSuccess: (pose) => pose,
    onFailure: (exception) => throw exception,
  );
});
