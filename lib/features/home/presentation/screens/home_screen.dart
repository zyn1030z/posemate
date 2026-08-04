import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/home/presentation/controllers/home_feed_controller.dart';
import 'package:posely_ai/features/home/presentation/widgets/category_quick_row.dart';
import 'package:posely_ai/features/home/presentation/widgets/home_header.dart';
import 'package:posely_ai/features/home/presentation/widgets/pose_rail.dart';

/// The Home tab: greeting, search affordance, category quick row, pose
/// rails, and the camera promo banner over the ambient aurora backdrop.
///
/// The greeting header stays visible in every state; below it the feed
/// swaps between shimmer rails while loading, a branded error view with
/// retry, and the staggered content sections once data lands. Pull to
/// refresh reloads the whole feed.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Delay step between consecutive section entrances.
  static const Duration _stagger = Duration(milliseconds: 70);

  /// Bottom padding so content scrolls clear of the floating shell bar.
  static const double _bottomBarClearance = 110;

  /// Height of the slim search affordance card.
  static const double _searchCardHeight = 48;

  Future<void> _refresh() =>
      ref.read(homeFeedControllerProvider.notifier).refresh();

  void _showSearchTeaser() {
    context.push(RoutePaths.search);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(homeFeedControllerProvider);
    final slivers = switch (feedState) {
      AsyncData<HomeFeed>(:final value) => _dataSlivers(value),
      AsyncError<HomeFeed>(:final error) => _errorSlivers(error),
      _ => _loadingSlivers(),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.backgroundAurora),
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator.adaptive(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: slivers,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _headerSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          0,
        ),
        child: HomeHeader(),
      ),
    );
  }

  List<Widget> _dataSlivers(HomeFeed feed) {
    var sectionIndex = 0;
    Widget entrance(Widget child) {
      final delay = _stagger * sectionIndex;
      sectionIndex++;
      return child
          .animate()
          .fadeIn(delay: delay, duration: AppDurations.base)
          .slideY(
            begin: 0.06,
            end: 0,
            delay: delay,
            duration: AppDurations.slow,
            curve: AppDurations.easeOutExpo,
          );
    }

    return <Widget>[
      _headerSliver(),
      SliverToBoxAdapter(
        child: entrance(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: _buildSearchCard(),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: entrance(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
            child: CategoryQuickRow(categories: feed.categories),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: entrance(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
            child: PoseRail(
              title: 'Recently used',
              poses: feed.recentlyUsed,
              emptyHint: 'Poses you use will reappear here.',
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: entrance(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
            child: PoseRail(
              title: 'Trending now',
              poses: feed.trending,
              onSeeAll: () => context.push(RoutePaths.poseLibrary),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: entrance(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
            child: PoseRail(
              title: 'Picked for you',
              poses: feed.recommended,
              onSeeAll: () => context.push(RoutePaths.poseLibrary),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: entrance(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
            child: _buildPromoBanner(),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: _bottomBarClearance)),
    ];
  }

  List<Widget> _loadingSlivers() {
    return <Widget>[
      _headerSliver(),
      for (var i = 0; i < 3; i++)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.sectionGap),
            child: _RailSkeleton(),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: _bottomBarClearance)),
    ];
  }

  List<Widget> _errorSlivers(Object error) {
    final message = error is AppException
        ? error.userMessage
        : 'Something unexpected went wrong. Please try again.';
    return <Widget>[
      _headerSliver(),
      SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(message: message, onRetry: _refresh),
      ),
    ];
  }

  Widget _buildSearchCard() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: SizedBox(
        height: _searchCardHeight,
        width: double.infinity,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          borderRadius: AppRadius.brLg,
          onTap: _showSearchTeaser,
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Search any pose or vibe…',
                  style: AppTypography.bodyMuted.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push(RoutePaths.coachSelection),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.blue400.withValues(alpha: 0.16),
                AppColors.blue600.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Shoot with a ghost guide',
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Overlay any pose in the camera and match it live.',
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.blueHero,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.blueGlow,
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 24,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading placeholder for one pose rail: a shimmer title line above a
/// non-scrolling row of three pose-card skeletons.
class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton();

  /// Width of each skeleton card, matching the real rail's card width.
  static const double _cardWidth = 150;

  /// Number of skeleton cards per rail.
  static const int _cardCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: AppSpacing.screenPadding,
          child: ShimmerBox(
            width: 140,
            height: 18,
            borderRadius: AppRadius.brSm,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Row(
            children: <Widget>[
              for (var i = 0; i < _cardCount; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                const SizedBox(width: _cardWidth, child: PoseCardSkeleton()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
