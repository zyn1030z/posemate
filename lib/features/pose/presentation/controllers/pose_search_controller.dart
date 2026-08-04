import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/core/shared/utils/debouncer.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Maximum number of recent search queries persisted.
const int _maxRecentSearches = 10;

/// State for the pose search feature.
///
/// Holds the current query, the result list (accumulated across pages),
/// and pagination bookkeeping.
class PoseSearchState {
  /// Creates a search state.
  const PoseSearchState({
    this.query = '',
    this.poses = const <Pose>[],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.error,
  });

  /// The current search query string.
  final String query;

  /// Accumulated search results across loaded pages.
  final List<Pose> poses;

  /// Whether a fetch is currently in-flight.
  final bool isLoading;

  /// Whether more pages are available.
  final bool hasMore;

  /// The last page that was successfully loaded (1-based).
  final int currentPage;

  /// The most recent error, if any.
  final Object? error;

  /// Derives a new state.
  PoseSearchState copyWith({
    String? query,
    List<Pose>? poses,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    Object? error = _noChange,
  }) => PoseSearchState(
    query: query ?? this.query,
    poses: poses ?? this.poses,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    currentPage: currentPage ?? this.currentPage,
    error: identical(error, _noChange) ? this.error : error,
  );
}

const Object _noChange = Object();

/// Controller for pose search with debounce and in-flight cancellation.
///
/// Key behaviors:
/// - Debounces keystrokes by 400ms before hitting the datasource.
/// - Cancels stale in-flight requests when the query changes.
/// - Supports infinite scroll by appending pages.
/// - Persists recent searches in Hive.
class PoseSearchController extends Notifier<PoseSearchState> {
  PoseRepository get _repository => ref.read(poseRepositoryProvider);
  LocalStorage get _localStorage => ref.read(localStorageProvider);

  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 400),
  );

  /// Monotonically increasing token: when a fetch completes, it checks
  /// whether its token matches the latest — if not, the result is stale.
  int _fetchToken = 0;

  @override
  PoseSearchState build() => const PoseSearchState();

  /// Updates the search query. Debounces the actual fetch.
  void updateQuery(String query) {
    final trimmed = query.trim();
    if (trimmed == state.query) return;
    state = state.copyWith(query: trimmed, error: null);
    if (trimmed.isEmpty) {
      _debouncer.cancel();
      _fetchToken++;
      state = const PoseSearchState();
      return;
    }
    _debouncer.run(() => _fetchPage(1, reset: true));
  }

  /// Loads the next page of results (infinite scroll).
  void loadNextPage() {
    if (state.isLoading || !state.hasMore || state.query.isEmpty) return;
    unawaited(_fetchPage(state.currentPage + 1));
  }

  Future<void> _fetchPage(int page, {bool reset = false}) async {
    final token = ++_fetchToken;
    state = state.copyWith(
      isLoading: true,
      error: null,
      poses: reset ? const <Pose>[] : null,
      currentPage: reset ? 0 : null,
    );

    final result = await _repository.searchPoses(
      query: state.query,
      page: page,
    );

    // Stale guard: if the query changed while waiting, discard the result.
    if (token != _fetchToken) return;

    switch (result) {
      case ApiSuccess<Paginated<Pose>>(:final data):
        final merged = reset ? data.items : [...state.poses, ...data.items];
        state = state.copyWith(
          poses: merged,
          currentPage: page,
          hasMore: data.hasMore,
          isLoading: false,
          error: null,
        );
        if (reset && state.query.isNotEmpty) {
          unawaited(_saveRecentSearch(state.query));
        }
      case ApiFailure<Paginated<Pose>>(:final exception):
        state = state.copyWith(isLoading: false, error: exception);
    }
  }

  /// Clears the search state entirely.
  void clear() {
    _debouncer.cancel();
    _fetchToken++;
    state = const PoseSearchState();
  }

  // --- Recent searches ---

  /// Returns the saved recent search queries.
  List<String> getRecentSearches() {
    final raw = _localStorage.get<List<dynamic>>(
      StorageBox.poses,
      StorageKeys.recentSearchQueries,
    );
    return (raw ?? const <dynamic>[]).whereType<String>().toList();
  }

  /// Clears all saved recent searches.
  Future<void> clearRecentSearches() async {
    await _localStorage.delete(
      StorageBox.poses,
      StorageKeys.recentSearchQueries,
    );
  }

  Future<void> _saveRecentSearch(String query) async {
    final searches = getRecentSearches()
      ..remove(query)
      ..insert(0, query);
    final capped = searches.take(_maxRecentSearches).toList();
    await _localStorage.put(
      StorageBox.poses,
      StorageKeys.recentSearchQueries,
      capped,
    );
  }
}

/// Never auto-retry: the UI offers explicit retry and new queries.
Duration? _noRetry(int retryCount, Object error) => null;

/// Provides the search controller and its state.
final poseSearchControllerProvider =
    NotifierProvider<PoseSearchController, PoseSearchState>(
      PoseSearchController.new,
      retry: _noRetry,
    );
