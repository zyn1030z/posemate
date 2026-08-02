import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Fetches the pose category taxonomy.
class GetCategoriesUseCase {
  /// Creates the use case over the repository.
  const GetCategoriesUseCase(this._repository);

  final PoseRepository _repository;

  /// Executes the fetch and returns every category.
  Future<ApiResult<List<PoseCategory>>> call() => _repository.getCategories();
}

/// Provides the category-list use case.
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>(
  (ref) => GetCategoriesUseCase(ref.watch(poseRepositoryProvider)),
);
