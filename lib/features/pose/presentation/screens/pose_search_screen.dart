import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/pose/presentation/controllers/pose_search_controller.dart';
import 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';

/// The generic error message for non-AppException errors.
const String _genericErrorMessage =
    'Something unexpected went wrong. Please try again.';

/// Suggestion chips shown when the search is empty.
const List<String> _suggestions = [
  'Portrait',
  'Standing',
  'Sitting',
  'Couple',
  'Headshot',
  'Full body',
  'Fashion',
  'Outdoor',
];

/// Full-screen search UI: a text field at the top, suggestion chips or
/// recent searches when idle, and a paginated result grid when searching.
class PoseSearchScreen extends ConsumerStatefulWidget {
  /// Creates the search screen.
  ///
  /// An optional [initialQuery] can pre-fill the search field (used when
  /// navigating from a category chip on the home screen).
  const PoseSearchScreen({super.key, this.initialQuery});

  /// Optional pre-filled query from deep link.
  final String? initialQuery;

  @override
  ConsumerState<PoseSearchScreen> createState() => _PoseSearchScreenState();
}

class _PoseSearchScreenState extends ConsumerState<PoseSearchScreen> {
  late final TextEditingController _textController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController.addListener(_onScroll);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      // Fire the initial query after the first frame so the controller
      // is fully built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(poseSearchControllerProvider.notifier)
            .updateQuery(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(poseSearchControllerProvider.notifier).loadNextPage();
    }
  }

  void _onQueryChanged(String value) {
    ref.read(poseSearchControllerProvider.notifier).updateQuery(value);
  }

  void _onClear() {
    _textController.clear();
    ref.read(poseSearchControllerProvider.notifier).clear();
  }

  void _onSuggestionTapped(String suggestion) {
    _textController.text = suggestion;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    ref.read(poseSearchControllerProvider.notifier).updateQuery(suggestion);
  }

  void _onRecentTapped(String query) {
    _textController.text = query;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    ref.read(poseSearchControllerProvider.notifier).updateQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(poseSearchControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Search header
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              topPadding + AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              border: const Border(
                bottom: BorderSide(
                  color: AppColors.surfaceElevated,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                PoselyIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 18,
                  onPressed: () => context.pop(),
                  semanticLabel: 'Back',
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    onChanged: _onQueryChanged,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Search poses...',
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: AppColors.textSecondary,
                              onPressed: _onClear,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: searchState.query.isEmpty
                ? _IdleBody(
                    onSuggestionTapped: _onSuggestionTapped,
                    onRecentTapped: _onRecentTapped,
                  )
                : _SearchResults(
                    searchState: searchState,
                    scrollController: _scrollController,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shows suggestion chips and recent searches when no query is active.
class _IdleBody extends ConsumerWidget {
  const _IdleBody({
    required this.onSuggestionTapped,
    required this.onRecentTapped,
  });

  final ValueChanged<String> onSuggestionTapped;
  final ValueChanged<String> onRecentTapped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches =
        ref.read(poseSearchControllerProvider.notifier).getRecentSearches();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: <Widget>[
        const SectionHeader(title: 'Suggestions'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final s in _suggestions)
              PoselyChip(label: s, onTap: () => onSuggestionTapped(s)),
          ],
        ),
        if (recentSearches.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.sectionGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SectionHeader(title: 'Recent'),
              GestureDetector(
                onTap: () {
                  ref
                      .read(poseSearchControllerProvider.notifier)
                      .clearRecentSearches();
                  // Force rebuild
                  ref.invalidate(poseSearchControllerProvider);
                },
                child: Text(
                  'Clear all',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final query in recentSearches)
            _RecentSearchTile(
              query: query,
              onTap: () => onRecentTapped(query),
            ),
        ],
      ],
    );
  }
}

/// A single recent search entry.
class _RecentSearchTile extends StatelessWidget {
  const _RecentSearchTile({
    required this.query,
    required this.onTap,
  });

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.history_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(query, style: AppTypography.body),
            ),
            const Icon(
              Icons.north_west_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search results grid with loading/error/empty states.
class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.searchState,
    required this.scrollController,
  });

  final PoseSearchState searchState;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final error = searchState.error;
    if (error != null && searchState.poses.isEmpty) {
      return AppErrorView(
        message:
            error is AppException ? error.userMessage : _genericErrorMessage,
      );
    }

    if (!searchState.isLoading && searchState.poses.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results',
        message: 'Try a different search term.',
      );
    }

    if (searchState.isLoading && searchState.poses.isEmpty) {
      return const SkeletonGrid();
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 3 / 4,
      ),
      itemCount: searchState.poses.length + (searchState.isLoading ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= searchState.poses.length) {
          return const ShimmerBox();
        }
        final pose = searchState.poses[index];
        return PoseCard(
          pose: pose,
          onTap: () => unawaited(
            context.push(
              RoutePaths.poseDetail.replaceFirst(':poseId', pose.id),
            ),
          ),
        );
      },
    );
  }
}
