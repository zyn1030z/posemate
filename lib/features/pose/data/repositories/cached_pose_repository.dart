import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// In-memory cache entry with expiry tracking.
class _CacheEntry<T> {
  _CacheEntry(this.value) : createdAt = DateTime.now();

  final T value;
  final DateTime createdAt;

  /// Whether this entry is still fresh (under 15 minutes old).
  bool get isFresh =>
      DateTime.now().difference(createdAt) < const Duration(minutes: 15);
}

/// Decorator that adds cache-aside to any [PoseRepository].
///
/// First-page reads for pose lists and categories are served from an
/// in-memory cache when fresh, avoiding redundant network calls during
/// rapid filter toggling or tab switches. Subsequent pages, writes
/// (toggle favorite, mark used), and single-pose reads always hit the
/// delegate.
///
/// Cache is invalidated by calling [clearCache], which the controller
/// triggers on pull-to-refresh.
class CachedPoseRepository implements PoseRepository {
  /// Wraps a delegate repository with in-memory caching.
  CachedPoseRepository(this._delegate);

  final PoseRepository _delegate;

  final Map<String, _CacheEntry<ApiResult<Paginated<Pose>>>> _posesCache = {};
  _CacheEntry<ApiResult<List<PoseCategory>>>? _categoriesCache;

  /// Builds a stable cache key from the query parameters.
  static String _posesKey({
    required int page,
    required int pageSize,
    String? categoryId,
    PoseDifficulty? difficulty,
    PoseGender? gender,
    PeopleCount? peopleCount,
    BodyDirection? bodyDirection,
  }) =>
      'poses:$page:$pageSize:$categoryId:${difficulty?.name}:'
      '${gender?.name}:${peopleCount?.name}:${bodyDirection?.name}';

  @override
  Future<ApiResult<Paginated<Pose>>> getPoses({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? categoryId,
    PoseDifficulty? difficulty,
    PoseGender? gender,
    PeopleCount? peopleCount,
    BodyDirection? bodyDirection,
  }) async {
    final key = _posesKey(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
      difficulty: difficulty,
      gender: gender,
      peopleCount: peopleCount,
      bodyDirection: bodyDirection,
    );
    final cached = _posesCache[key];
    if (cached != null && cached.isFresh && cached.value.isSuccess) {
      return cached.value;
    }
    final result = await _delegate.getPoses(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
      difficulty: difficulty,
      gender: gender,
      peopleCount: peopleCount,
      bodyDirection: bodyDirection,
    );
    if (result.isSuccess) {
      _posesCache[key] = _CacheEntry(result);
    }
    return result;
  }

  @override
  Future<ApiResult<List<PoseCategory>>> getCategories() async {
    final cached = _categoriesCache;
    if (cached != null && cached.isFresh && cached.value.isSuccess) {
      return cached.value;
    }
    final result = await _delegate.getCategories();
    if (result.isSuccess) {
      _categoriesCache = _CacheEntry(result);
    }
    return result;
  }

  /// Evicts all cached data, forcing the next read to hit the delegate.
  void clearCache() {
    _posesCache.clear();
    _categoriesCache = null;
  }

  // ── Pass-through methods (no caching) ──────────────────────────────

  @override
  Future<ApiResult<Pose>> getPoseById(String id) =>
      _delegate.getPoseById(id);

  @override
  Future<ApiResult<List<Pose>>> getTrending() => _delegate.getTrending();

  @override
  Future<ApiResult<List<Pose>>> getRecommended() =>
      _delegate.getRecommended();

  @override
  Future<List<Pose>> getRecentlyUsed() => _delegate.getRecentlyUsed();

  @override
  Future<void> markUsed(Pose pose) => _delegate.markUsed(pose);

  @override
  Future<Set<String>> getFavoriteIds() => _delegate.getFavoriteIds();

  @override
  Future<bool> toggleFavorite(String poseId) =>
      _delegate.toggleFavorite(poseId);
}
