import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:posely_ai/core/design/skeleton/pose_card_skeleton.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/home/presentation/screens/home_screen.dart';
import 'package:posely_ai/features/home/presentation/widgets/home_header.dart';
import 'package:posely_ai/features/pose/pose.dart';

class _MockPoseRepository extends Mock implements PoseRepository {}

/// Fake session: a guest user, so the header greets 'Creator'.
class _FakeAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => AuthUser.guest();
}

Pose _pose(String id, String name) => Pose(
      id: id,
      name: name,
      previewUrl: 'https://img.posely.test/.jpg',
      overlayUrl: 'https://img.posely.test/-overlay.png',
      tags: const <String>['studio'],
      difficulty: PoseDifficulty.values.first,
      gender: PoseGender.values.first,
      aiScore: 0.86,
      downloads: 1240,
      isPremium: true,
      categoryId: 'cat-1',
    );

PoseCategory _category(int index) => PoseCategory(
      id: 'cat-$index',
      name: 'Category $index',
      emoji: '📸',
    );

void main() {
  setUp(() {
    PoseCard.debugForcePlaceholder = true;
  });
  tearDown(() {
    PoseCard.debugForcePlaceholder = false;
  });

  void setPhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Stubs every repository call with a successful canned response.
  void stubSuccess(
    _MockPoseRepository repository, {
    List<Pose>? recent,
  }) {
    when(repository.getTrending).thenAnswer(
      (_) async => ApiSuccess<List<Pose>>(
        <Pose>[_pose('t1', 'Golden Hour Lean')],
      ),
    );
    when(repository.getRecommended).thenAnswer(
      (_) async => ApiSuccess<List<Pose>>(
        <Pose>[_pose('r1', 'Rooftop Stride')],
      ),
    );
    when(repository.getCategories).thenAnswer(
      (_) async => ApiSuccess<List<PoseCategory>>(
        <PoseCategory>[_category(1), _category(2)],
      ),
    );
    when(repository.getRecentlyUsed).thenAnswer(
      (_) async => recent ?? <Pose>[_pose('u1', 'Mirror Check')],
    );
  }

  Future<void> pumpHome(
    WidgetTester tester,
    _MockPoseRepository repository,
  ) async {
    setPhoneSurface(tester);
    final router = GoRouter(
      initialLocation: RoutePaths.home,
      routes: <RouteBase>[
        GoRoute(
          path: RoutePaths.home,
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.poseLibrary,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('library-stub'))),
        ),
        GoRoute(
          path: RoutePaths.poseDetail,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('detail-stub'))),
        ),
        GoRoute(
          path: RoutePaths.camera,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('camera-stub'))),
        ),
        GoRoute(
          path: RoutePaths.search,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('search-stub'))),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          poseRepositoryProvider.overrideWithValue(repository),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: PoselyTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows the header and skeleton rails while the feed is '
        'pending', (WidgetTester tester) async {
      final repository = _MockPoseRepository();
      final trending = Completer<ApiResult<List<Pose>>>();
      final recommended = Completer<ApiResult<List<Pose>>>();
      final categories = Completer<ApiResult<List<PoseCategory>>>();
      final recent = Completer<List<Pose>>();
      when(repository.getTrending).thenAnswer((_) => trending.future);
      when(repository.getRecommended)
          .thenAnswer((_) => recommended.future);
      when(repository.getCategories)
          .thenAnswer((_) => categories.future);
      when(repository.getRecentlyUsed)
          .thenAnswer((_) => recent.future);

      await pumpHome(tester, repository);
      // Bounded pumps only: the shimmer sweep repeats forever, so
      // pumpAndSettle would never return while skeletons are visible.
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(PoseCardSkeleton), findsNWidgets(9));

      trending.complete(
        ApiSuccess<List<Pose>>(<Pose>[_pose('t1', 'Golden Hour Lean')]),
      );
      recommended.complete(
        ApiSuccess<List<Pose>>(<Pose>[_pose('r1', 'Rooftop Stride')]),
      );
      categories.complete(
        ApiSuccess<List<PoseCategory>>(<PoseCategory>[_category(1)]),
      );
      recent.complete(const <Pose>[]);
      await tester.pumpAndSettle();

      expect(find.byType(PoseCardSkeleton), findsNothing);
      expect(find.text('Trending now'), findsOneWidget);
    });

    testWidgets('renders every section and its pose names with data',
        (WidgetTester tester) async {
      final repository = _MockPoseRepository();
      stubSuccess(repository);

      await pumpHome(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Creator'), findsOneWidget);
      expect(find.text('Search any pose or vibe…'), findsOneWidget);
      expect(find.text('📸 Category 1'), findsOneWidget);
      expect(find.text('All →'), findsOneWidget);
      expect(find.text('Recently used'), findsOneWidget);
      expect(find.text('Trending now'), findsOneWidget);
      expect(find.text('Picked for you'), findsOneWidget);
      expect(find.text('Mirror Check'), findsOneWidget);
      expect(find.text('Golden Hour Lean'), findsOneWidget);
      expect(find.text('Rooftop Stride'), findsOneWidget);

      // The promo banner sits below the fold; bring it into view.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Shoot with a ghost guide'), findsOneWidget);

      await tester.tap(find.text('Shoot with a ghost guide'));
      await tester.pumpAndSettle();

      expect(find.text('camera-stub'), findsOneWidget);
    });

    testWidgets('renders the empty hint when recently used is empty',
        (WidgetTester tester) async {
      final repository = _MockPoseRepository();
      stubSuccess(repository, recent: const <Pose>[]);

      await pumpHome(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Recently used'), findsOneWidget);
      expect(find.text('Poses you use will reappear here.'), findsOneWidget);
    });

    testWidgets("'See all' on a rail opens the pose library",
        (WidgetTester tester) async {
      final repository = _MockPoseRepository();
      stubSuccess(repository);

      await pumpHome(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text('See all').first);
      await tester.pumpAndSettle();

      expect(find.text('library-stub'), findsOneWidget);
    });

    testWidgets('search affordance navigates to the search screen',
        (WidgetTester tester) async {
      final repository = _MockPoseRepository();
      stubSuccess(repository);

      await pumpHome(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search any pose or vibe…'));
      await tester.pumpAndSettle();

      expect(find.text('search-stub'), findsOneWidget);
    });

    testWidgets('shows the error view when the feed fails and retry '
        'refetches', (WidgetTester tester) async {
      final repository = _MockPoseRepository();
      when(repository.getTrending).thenAnswer(
        (_) async => const ApiFailure<List<Pose>>(NetworkException()),
      );
      when(repository.getRecommended).thenAnswer(
        (_) async => const ApiFailure<List<Pose>>(ApiTimeoutException()),
      );
      when(repository.getCategories).thenAnswer(
        (_) async => const ApiFailure<List<PoseCategory>>(ServerException()),
      );
      when(repository.getRecentlyUsed)
          .thenAnswer((_) async => const <Pose>[]);

      await pumpHome(tester, repository);
      await tester.pumpAndSettle();

      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(const NetworkException().userMessage), findsOneWidget);
      verify(repository.getTrending).called(1);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      // Retry drove one more full fetch and, still failing, kept the
      // error view on screen.
      verify(repository.getTrending).called(1);
      expect(find.byType(AppErrorView), findsOneWidget);
    });
  });
}
