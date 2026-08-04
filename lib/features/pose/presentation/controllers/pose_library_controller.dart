import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Sentinel default for copyWith parameters that must distinguish
/// "not passed" from "explicitly set to null".
const Object _sentinel = Object();

/// The active pose library filters: category, difficulty, gender, people
/// count, and body direction.
///
/// A plain immutable value type. Every field is nullable, where null
/// means "no filter applied" for that dimension. Use copyWith to derive
/// a new set of filters; passing an explicit null clears that filter.
class PoseLibraryFilters {
  /// Creates a filter set; omitted fields apply no filter.
  const PoseLibraryFilters({
    this.categoryId,
    this.difficulty,
    this.gender,
    this.peopleCount,
    this.bodyDirection,
  });

  /// Selected category id, or null for all categories.
  final String? categoryId;

  /// Selected difficulty, or null for any difficulty.
  final PoseDifficulty? difficulty;

  /// Selected gender, or null for any gender.
  final PoseGender? gender;

  /// Selected people count, or null for any count.
  final PeopleCount? peopleCount;

  /// Selected body direction, or null for any direction.
  final BodyDirection? bodyDirection;

  /// Derives a new filter set, treating an explicit null as "clear".
  PoseLibraryFilters copyWith({
    Object? categoryId = _sentinel,
    Object? difficulty = _sentinel,
    Object? gender = _sentinel,
    Object? peopleCount = _sentinel,
    Object? bodyDirection = _sentinel,
  }) {
    return PoseLibraryFilters(
      categoryId: identical(categoryId, _sentinel)
          ? this.categoryId
          : categoryId as String?,
      difficulty: identical(difficulty, _sentinel)
          ? this.difficulty
          : difficulty as PoseDifficulty?,
      gender: identical(gender, _sentinel)
          ? this.gender
          : gender as PoseGender?,
      peopleCount: identical(peopleCount, _sentinel)
          ? this.peopleCount
          : peopleCount as PeopleCount?,
      bodyDirection: identical(bodyDirection, _sentinel)
          ? this.bodyDirection
          : bodyDirection as BodyDirection?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PoseLibraryFilters &&
        other.categoryId == categoryId &&
        other.difficulty == difficulty &&
        other.gender == gender &&
        other.peopleCount == peopleCount &&
        other.bodyDirection == bodyDirection;
  }

  @override
  int get hashCode =>
      Object.hash(categoryId, difficulty, gender, peopleCount, bodyDirection);
}

/// Accumulated pose library data: every loaded page plus paging flags.
class PoseLibraryState {
  /// Creates a library state snapshot.
  const PoseLibraryState({
    required this.poses,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.filters,
    this.loadMoreError,
  });

  /// All poses loaded so far, across every fetched page.
  final List<Pose> poses;

  /// One-based index of the most recently loaded page.
  final int page;

  /// Whether another page can be fetched after the current one.
  final bool hasMore;

  /// Whether a next-page fetch is currently in flight.
  final bool isLoadingMore;

  /// The filters this state was loaded with.
  final PoseLibraryFilters filters;

  /// The failure of the most recent loadMore attempt, if any.
  ///
  /// Surfacing it here keeps the loaded poses on screen while the UI
  /// decides how to present the failure (typically a toast), after
  /// which it calls clearLoadMoreError on the controller.
  final AppException? loadMoreError;

  /// Derives a new snapshot; passing an explicit null for the load-more
  /// error clears it.
  PoseLibraryState copyWith({
    List<Pose>? poses,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    PoseLibraryFilters? filters,
    Object? loadMoreError = _sentinel,
  }) {
    return PoseLibraryState(
      poses: poses ?? this.poses,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
      loadMoreError: identical(loadMoreError, _sentinel)
          ? this.loadMoreError
          : loadMoreError as AppException?,
    );
  }
}

/// Drives the pose library: first page on build, infinite scrolling via
/// loadMore, filter changes via setFilters, and pull-to-refresh.
///
/// Filter changes race against slow responses, so every full reload
/// carries a monotonically increasing request id; a completion whose id
/// is no longer current is dropped instead of overwriting newer data.
class PoseLibraryController extends AsyncNotifier<PoseLibraryState> {
  int _requestId = 0;
  PoseLibraryFilters _filters = const PoseLibraryFilters();

  PoseRepository get _repository => ref.read(poseRepositoryProvider);

  /// First page index requested from the repository.
  ///
  /// Instance getters (rather than call-site constants) keep the paging
  /// knobs in one place regardless of repository parameter defaults.
  int get _firstPage => 1;

  /// Page size requested from the repository.
  int get _pageSize => AppConstants.defaultPageSize;

  @override
  Future<PoseLibraryState> build() {
    _filters = const PoseLibraryFilters();
    return _loadFirstPage(_filters);
  }

  /// Fetches the next page and appends it to the current list.
  ///
  /// A no-op while a page is already loading, while no data is
  /// available, or when the last page has been reached. On failure the
  /// loaded poses are kept and the failure lands in the state's
  /// loadMoreError for the UI to toast and clear.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }
    final requestId = _requestId;
    state = AsyncData<PoseLibraryState>(current.copyWith(isLoadingMore: true));
    final result = await _repository.getPoses(
      page: current.page + 1,
      pageSize: _pageSize,
      categoryId: current.filters.categoryId,
      difficulty: current.filters.difficulty,
      gender: current.filters.gender,
      peopleCount: current.filters.peopleCount,
      bodyDirection: current.filters.bodyDirection,
    );
    if (requestId != _requestId) {
      // Filters changed while this page was in flight; drop it.
      return;
    }
    final latest = state.value;
    if (latest == null) {
      return;
    }
    result.fold(
      onSuccess: (pageData) {
        state = AsyncData<PoseLibraryState>(
          latest.copyWith(
            poses: List<Pose>.unmodifiable(<Pose>[
              ...latest.poses,
              ...pageData.items,
            ]),
            page: pageData.page,
            hasMore: pageData.hasMore,
            isLoadingMore: false,
            loadMoreError: null,
          ),
        );
      },
      onFailure: (exception) {
        state = AsyncData<PoseLibraryState>(
          latest.copyWith(isLoadingMore: false, loadMoreError: exception),
        );
      },
    );
  }

  /// Applies a new filter set and reloads from the first page.
  ///
  /// The state moves through loading so the grid shows skeletons, and
  /// stale completions from superseded filter changes are discarded.
  Future<void> setFilters(PoseLibraryFilters filters) async {
    _filters = filters;
    final requestId = ++_requestId;
    state = const AsyncLoading<PoseLibraryState>();
    try {
      final fresh = await _loadFirstPage(filters);
      if (requestId != _requestId) {
        return;
      }
      state = AsyncData<PoseLibraryState>(fresh);
    } catch (error, stackTrace) {
      if (requestId != _requestId) {
        return;
      }
      state = AsyncError<PoseLibraryState>(error, stackTrace);
    }
  }

  /// Reloads the first page with the current filters.
  ///
  /// Existing data stays on screen while the refresh runs (pull-to-
  /// refresh UX); when there is no data yet — a failed first load being
  /// retried — the state moves through loading instead.
  Future<void> refresh() async {
    final requestId = ++_requestId;
    if (!state.hasValue) {
      state = const AsyncLoading<PoseLibraryState>();
    }
    try {
      final fresh = await _loadFirstPage(_filters);
      if (requestId != _requestId) {
        return;
      }
      state = AsyncData<PoseLibraryState>(fresh);
    } catch (error, stackTrace) {
      if (requestId != _requestId) {
        return;
      }
      state = AsyncError<PoseLibraryState>(error, stackTrace);
    }
  }

  /// Clears a previously surfaced load-more failure.
  ///
  /// Called by the UI after it has shown the failure, so the same
  /// toast is not raised again on the next rebuild.
  void clearLoadMoreError() {
    final current = state.value;
    if (current == null || current.loadMoreError == null) {
      return;
    }
    state = AsyncData<PoseLibraryState>(current.copyWith(loadMoreError: null));
  }

  Future<PoseLibraryState> _loadFirstPage(PoseLibraryFilters filters) async {
    final result = await _repository.getPoses(
      page: _firstPage,
      pageSize: _pageSize,
      categoryId: filters.categoryId,
      difficulty: filters.difficulty,
      gender: filters.gender,
      peopleCount: filters.peopleCount,
      bodyDirection: filters.bodyDirection,
    );
    return result.fold(
      onSuccess: (pageData) => PoseLibraryState(
        poses: List<Pose>.unmodifiable(pageData.items),
        page: pageData.page,
        hasMore: pageData.hasMore,
        isLoadingMore: false,
        filters: filters,
      ),
      onFailure: (exception) => throw exception,
    );
  }
}

/// Never auto-retry: the UI offers pull-to-refresh and an explicit retry action.
Duration? _noRetry(int retryCount, Object error) => null;

/// The pose library list: loading on first build and on filter changes,
/// then accumulated pages as data.
final poseLibraryControllerProvider =
    AsyncNotifierProvider<PoseLibraryController, PoseLibraryState>(
      PoseLibraryController.new,
      retry: _noRetry,
    );

/// All pose categories for the filter chip row.
///
/// Failures are rethrown as the provider's error so consumers decide
/// how visible a missing category row should be.
final poseCategoriesProvider = FutureProvider<List<PoseCategory>>((ref) async {
  final result = await ref.watch(poseRepositoryProvider).getCategories();
  return result.fold(
    onSuccess: (categories) => categories,
    onFailure: (exception) => throw exception,
  );
}, retry: _noRetry);
