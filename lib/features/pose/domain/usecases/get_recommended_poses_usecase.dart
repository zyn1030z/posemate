import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Fetches personalized pose recommendations for the current user.
class GetRecommendedPosesUseCase {
  /// Creates the use case over the repository.
  const GetRecommendedPosesUseCase(this._repository);

  final PoseRepository _repository;

  /// Executes the fetch and returns the recommended poses.
  Future<ApiResult<List<Pose>>> call() => _repository.getRecommended();
}

/// Provides the recommended-poses use case.
final getRecommendedPosesUseCaseProvider = Provider<GetRecommendedPosesUseCase>(
  (ref) => GetRecommendedPosesUseCase(ref.watch(poseRepositoryProvider)),
);
