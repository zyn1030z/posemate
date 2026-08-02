import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

/// Contract for browsing the pose library and tracking per-device usage.
///
/// Remote reads return an `ApiResult` so failures surface as typed
/// exceptions; local reads and writes (favorites, recently used) are backed
/// by device storage and never fail with network errors.
abstract interface class PoseRepository {
  /// Fetches the full category taxonomy.
  Future<ApiResult<List<PoseCategory>>> getCategories();

  /// Fetches one page of the pose library, optionally filtered.
  Future<ApiResult<Paginated<Pose>>> getPoses({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? categoryId,
    PoseDifficulty? difficulty,
    PoseGender? gender,
    PeopleCount? peopleCount,
    BodyDirection? bodyDirection,
  });

  /// Fetches a single pose by its identifier.
  Future<ApiResult<Pose>> getPoseById(String id);

  /// Fetches the poses currently trending across the community.
  Future<ApiResult<List<Pose>>> getTrending();

  /// Fetches personalized pose recommendations for the current user.
  Future<ApiResult<List<Pose>>> getRecommended();

  /// Returns locally stored recently used poses, most recent first.
  Future<List<Pose>> getRecentlyUsed();

  /// Records that the pose was just used, keeping the recent list capped
  /// and free of duplicates.
  Future<void> markUsed(Pose pose);

  /// Returns the ids of every pose the user marked as favorite.
  Future<Set<String>> getFavoriteIds();

  /// Flips the favorite state of the pose and returns the new state:
  /// true when the pose is now a favorite, false when it no longer is.
  Future<bool> toggleFavorite(String poseId);
}
