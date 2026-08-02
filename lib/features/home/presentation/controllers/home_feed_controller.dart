import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/pose/pose.dart';

/// Everything the Home screen renders, loaded in one concurrent sweep.
class HomeFeed {
  /// Creates an immutable snapshot of the home feed.
  const HomeFeed({
    required this.trending,
    required this.recommended,
    required this.recentlyUsed,
    required this.categories,
  });

  /// Poses trending across the community right now.
  final List<Pose> trending;

  /// Poses picked for the current user.
  final List<Pose> recommended;

  /// Poses the user recently opened; empty until they start creating.
  final List<Pose> recentlyUsed;

  /// Browsable pose categories for the quick row.
  final List<PoseCategory> categories;
}

/// Loads and refreshes the aggregated home feed.
///
/// All four sources are fetched concurrently. Trending and recommended
/// are the feed's backbone: when only one of them fails it folds to an
/// empty list so the rest of the feed still renders, but when both fail
/// the feed is meaningless and the first failure is thrown so the screen
/// shows its error state. Recently-used poses and categories are
/// garnish — their failures always fold to empty lists.
class HomeFeedController extends AsyncNotifier<HomeFeed> {
  @override
  Future<HomeFeed> build() {
    // Watch so swapping the repository (tests, flavors) rebuilds the feed.
    ref.watch(poseRepositoryProvider);
    return _load();
  }

  /// Reloads the whole feed through a fresh loading state.
  ///
  /// Shared by pull-to-refresh and the error state's retry action.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<HomeFeed> _load() async {
    final repository = ref.read(poseRepositoryProvider);
    final results = await Future.wait<Object>(<Future<Object>>[
      repository.getTrending(),
      repository.getRecommended(),
      repository.getCategories(),
      _recentlyUsedOrEmpty(repository),
    ]);
    final trendingResult = results[0] as ApiResult<List<Pose>>;
    final recommendedResult = results[1] as ApiResult<List<Pose>>;
    final categoriesResult = results[2] as ApiResult<List<PoseCategory>>;
    final recentlyUsed = results[3] as List<Pose>;

    if (trendingResult is ApiFailure<List<Pose>> &&
        recommendedResult is ApiFailure<List<Pose>>) {
      // Both backbone sections are gone; surface the first failure so the
      // screen renders a real error state instead of an empty husk.
      throw trendingResult.exception;
    }

    return HomeFeed(
      trending: _posesOrEmpty(trendingResult),
      recommended: _posesOrEmpty(recommendedResult),
      recentlyUsed: recentlyUsed,
      categories: categoriesResult.fold(
        onSuccess: (data) => data,
        onFailure: (_) => const <PoseCategory>[],
      ),
    );
  }

  static List<Pose> _posesOrEmpty(ApiResult<List<Pose>> result) => result.fold(
        onSuccess: (data) => data,
        onFailure: (_) => const <Pose>[],
      );

  static Future<List<Pose>> _recentlyUsedOrEmpty(
    PoseRepository repository,
  ) async {
    try {
      return await repository.getRecentlyUsed();
    } catch (_) {
      return const <Pose>[];
    }
  }
}

/// Never auto-retry a failed feed: Home offers pull-to-refresh and an
/// explicit retry button, so backoff timers would only fight the user.
Duration? _noRetry(int retryCount, Object error) => null;

/// The aggregated home feed: loading, data, or a screen-level error when
/// both backbone sections fail.
final homeFeedControllerProvider =
    AsyncNotifierProvider<HomeFeedController, HomeFeed>(
  HomeFeedController.new,
  retry: _noRetry,
);
