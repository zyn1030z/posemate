import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/presentation/controllers/pose_library_controller.dart';
import 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';

/// Distance from the bottom of the scroll extent at which the next
/// page starts loading.
const double _loadMoreThreshold = 400;

/// Trailing scroll clearance so the floating shell bar never covers
/// the last grid row.
const double _bottomBarClearance = 110;

/// Height of the horizontal category chip row.
const double _chipRowHeight = 44;

/// Fallback copy for failures that are not typed AppException values.
const String _genericErrorMessage =
    'Something unexpected went wrong. Please try again.';

/// The browsable pose library: category chips, difficulty and gender
/// pickers, and an infinitely scrolling 2-column grid of pose cards.
class PoseLibraryScreen extends ConsumerStatefulWidget {
  /// Creates the pose library screen, optionally pre-filtered to a
  /// category (deep links from home).
  const PoseLibraryScreen({super.key, this.initialCategoryId});

  /// Category applied once after the first frame, when provided.
  final String? initialCategoryId;

  @override
  ConsumerState<PoseLibraryScreen> createState() => _PoseLibraryScreenState();
}

class _PoseLibraryScreenState extends ConsumerState<PoseLibraryScreen> {
  /// The last filter set the user asked for. The controller state lags
  /// behind while a reload is in flight, so chips highlight from here.
  PoseLibraryFilters _filters = const PoseLibraryFilters();

  @override
  void initState() {
    super.initState();
    final categoryId = widget.initialCategoryId;
    if (categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _applyFilters(PoseLibraryFilters(categoryId: categoryId));
      });
    }
  }

  void _applyFilters(PoseLibraryFilters filters) {
    setState(() => _filters = filters);
    unawaited(
      ref.read(poseLibraryControllerProvider.notifier).setFilters(filters),
    );
  }

  void _onLibraryStateChanged(
    AsyncValue<PoseLibraryState>? previous,
    AsyncValue<PoseLibraryState> next,
  ) {
    final error = next.value?.loadMoreError;
    if (error == null || identical(previous?.value?.loadMoreError, error)) {
      return;
    }
    PoselyToast.show(
      context,
      message: error.userMessage,
      kind: PoselyToastKind.error,
    );
    ref.read(poseLibraryControllerProvider.notifier).clearLoadMoreError();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Ignore the horizontal category row; only the grid paginates.
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification.metrics.extentAfter < _loadMoreThreshold) {
      unawaited(ref.read(poseLibraryControllerProvider.notifier).loadMore());
    }
    return false;
  }

  void _pickDifficulty() {
    unawaited(
      _showOptionSheet<PoseDifficulty>(
        title: 'Difficulty',
        options: PoseDifficulty.values,
        labelOf: (option) => option.label,
        selected: _filters.difficulty,
        onSelected: (option) =>
            _applyFilters(_filters.copyWith(difficulty: option)),
      ),
    );
  }

  void _pickGender() {
    unawaited(
      _showOptionSheet<PoseGender>(
        title: 'Gender',
        // PoseGender.any is a pose attribute; the unfiltered choice is
        // the null 'Any' row the sheet prepends.
        options: const <PoseGender>[
          PoseGender.female,
          PoseGender.male,
          PoseGender.couple,
        ],
        labelOf: (option) => option.label,
        selected: _filters.gender,
        onSelected: (option) => _applyFilters(_filters.copyWith(gender: option)),
      ),
    );
  }

  Future<void> _showOptionSheet<T>({
    required String title,
    required List<T> options,
    required String Function(T option) labelOf,
    required T? selected,
    required ValueChanged<T?> onSelected,
  }) {
    return showPoselyBottomSheet<void>(
      context: context,
      title: title,
      builder: (BuildContext sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _OptionTile(
              label: 'Any',
              selected: selected == null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onSelected(null);
              },
            ),
            for (final option in options)
              _OptionTile(
                label: labelOf(option),
                selected: option == selected,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelected(option);
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(poseLibraryControllerProvider);
    ref.listen<AsyncValue<PoseLibraryState>>(
      poseLibraryControllerProvider,
      _onLibraryStateChanged,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(poseLibraryControllerProvider.notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                _buildHeader(async.value),
                _buildCategoryRow(),
                _buildFilterRow(),
                ..._buildBody(async),
                const SliverToBoxAdapter(
                  child: SizedBox(height: _bottomBarClearance),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PoseLibraryState? value) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Pose Library', style: AppTypography.screenTitle),
            if (value != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${value.poses.length} poses',
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categoriesAsync = ref.watch(poseCategoriesProvider);
    return SliverToBoxAdapter(
      child: categoriesAsync.when(
        data: (categories) => SizedBox(
          height: _chipRowHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            children: <Widget>[
              PoselyChip(
                label: 'All',
                selected: _filters.categoryId == null,
                onTap: () => _applyFilters(_filters.copyWith(categoryId: null)),
              ),
              for (final category in categories) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                PoselyChip(
                  label: '${category.emoji} ${category.name}',
                  selected: _filters.categoryId == category.id,
                  onTap: () => _applyFilters(
                    _filters.copyWith(categoryId: category.id),
                  ),
                ),
              ],
            ],
          ),
        ),
        loading: () => SizedBox(
          height: _chipRowHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            children: <Widget>[
              for (var i = 0; i < 4; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: ShimmerBox(width: 88, borderRadius: AppRadius.brPill),
                ),
              ],
            ],
          ),
        ),
        // A failed category fetch hides the row silently; the library
        // stays fully browsable through 'All'.
        error: (Object error, StackTrace stackTrace) =>
            const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            _FilterPickerChip(
              label: _filters.difficulty?.label ?? 'Difficulty',
              active: _filters.difficulty != null,
              onTap: _pickDifficulty,
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterPickerChip(
              label: _filters.gender?.label ?? 'Gender',
              active: _filters.gender != null,
              onTap: _pickGender,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(AsyncValue<PoseLibraryState> async) {
    if (async.isLoading) {
      return const <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SkeletonGrid(),
          ),
        ),
      ];
    }
    if (async.hasError) {
      final error = async.error;
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorView(
            message:
                error is AppException ? error.userMessage : _genericErrorMessage,
            onRetry: () => unawaited(
              ref.read(poseLibraryControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      ];
    }
    final value = async.value;
    if (value == null || value.poses.isEmpty) {
      return const <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: 'No poses found',
            message: 'Try a different category or filter.',
          ),
        ),
      ];
    }
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 3 / 4,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final pose = value.poses[index];
              return PoseCard(
                pose: pose,
                onTap: () => unawaited(
                  context.push<Object?>(RoutePaths.poseDetailFor(pose.id)),
                ),
              );
            },
            childCount: value.poses.length,
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildFooter(value)),
    ];
  }

  Widget _buildFooter(PoseLibraryState value) {
    if (value.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: _PulseDotsLoader(),
      );
    }
    if (!value.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            'You have seen them all ✨',
            style: AppTypography.caption,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Glass dropdown-style chip opening a bottom-sheet picker.
///
/// Turns blue-tinted while its filter is active and shows the
/// selected value as its label.
class _FilterPickerChip extends StatelessWidget {
  const _FilterPickerChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  void _handleTap() {
    unawaited(HapticFeedback.selectionClick());
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final posely = context.posely;
    final foreground = active ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Container(
            height: 36,
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : posely.glassSurface,
              borderRadius: AppRadius.brPill,
              border: Border.all(
                color: active ? AppColors.primary : posely.glassStroke,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: foreground,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single row inside a filter picker sheet, with a trailing check on
/// the selected option.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  void _handleTap() {
    unawaited(HapticFeedback.selectionClick());
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: AppRadius.brMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three blue dots pulsing in sequence while the next page loads.
class _PulseDotsLoader extends StatefulWidget {
  const _PulseDotsLoader();

  @override
  State<_PulseDotsLoader> createState() => _PulseDotsLoaderState();
}

class _PulseDotsLoaderState extends State<_PulseDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOpacity(int index) {
    final phase = (_controller.value - index / 3) % 1;
    // Triangle wave peaking mid-phase, staggered per dot.
    final wave = 1 - (phase - 0.5).abs() * 2;
    return 0.25 + 0.75 * wave;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading more poses',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var i = 0; i < 3; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Opacity(
                  opacity: _dotOpacity(i),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 8, height: 8),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
