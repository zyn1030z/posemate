import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Fetches the poses currently trending across the community.
class GetTrendingPosesUseCase {
  /// Creates the use case over the repository.
  const GetTrendingPosesUseCase(this._repository);

  final PoseRepository _repository;

  /// Executes the fetch and returns the trending poses.
  Future<ApiResult<List<Pose>>> call() => _repository.getTrending();
}

/// Provides the trending-poses use case.
final getTrendingPosesUseCaseProvider = Provider<GetTrendingPosesUseCase>(
  (ref) => GetTrendingPosesUseCase(ref.watch(poseRepositoryProvider)),
);
