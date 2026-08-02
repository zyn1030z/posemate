import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Fetches one page of the pose library with optional filters.
class GetPosesUseCase {
  /// Creates the use case over the repository.
  const GetPosesUseCase(this._repository);

  final PoseRepository _repository;

  /// Executes the fetch and returns the requested page.
  Future<ApiResult<Paginated<Pose>>> call({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? categoryId,
    PoseDifficulty? difficulty,
    PoseGender? gender,
  }) => _repository.getPoses(
    page: page,
    pageSize: pageSize,
    categoryId: categoryId,
    difficulty: difficulty,
    gender: gender,
  );
}

/// Provides the pose-list use case.
final getPosesUseCaseProvider = Provider<GetPosesUseCase>(
  (ref) => GetPosesUseCase(ref.watch(poseRepositoryProvider)),
);
