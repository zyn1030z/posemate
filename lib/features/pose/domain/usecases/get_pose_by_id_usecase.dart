import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Fetches a single pose by its identifier.
class GetPoseByIdUseCase {
  /// Creates the use case over the repository.
  const GetPoseByIdUseCase(this._repository);

  final PoseRepository _repository;

  /// Executes the fetch and returns the pose with the given id.
  Future<ApiResult<Pose>> call(String id) => _repository.getPoseById(id);
}

/// Provides the single-pose use case.
final getPoseByIdUseCaseProvider = Provider<GetPoseByIdUseCase>(
  (ref) => GetPoseByIdUseCase(ref.watch(poseRepositoryProvider)),
);
