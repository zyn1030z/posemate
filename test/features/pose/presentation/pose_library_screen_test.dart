// ignore_for_file: avoid_redundant_argument_values
// Explicit argument values inside mocktail verify blocks are assertions
// about the call, not redundant defaults — keep them spelled out.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';
import 'package:posely_ai/features/pose/presentation/screens/pose_library_screen.dart';
import 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockPoseRepository extends Mock implements PoseRepository {}

Pose _buildPose({String id = 'p1', String name = 'Golden Hour'}) {
  return Pose(
    id: id,
    name: name,
    previewUrl: 'https://img.posely.app/$id.jpg',
    overlayUrl: 'https://img.posely.app/$id-overlay.png',
    tags: const <String>['standing'],
    aiScore: 8.7,
    downloads: 12400,
    categoryId: 'c1',
  );
}

Paginated<Pose> _buildPage(List<Pose> items, {bool hasMore = false}) {
  return Paginated<Pose>(
    items: items,
    page: 1,
    pageSize: AppConstants.defaultPageSize,
    totalItems: items.length,
    hasMore: hasMore,
  );
}

void main() {
  group('PoseLibraryScreen', () {
    late _MockPoseRepository repository;

    setUp(() {
      repository = _MockPoseRepository();
      PoseCard.debugForcePlaceholder = true;
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{});
      when(() => repository.getCategories()).thenAnswer(
        (_) async => const ApiSuccess<List<PoseCategory>>(<PoseCategory>[]),
      );
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

    void stubPoses(ApiResult<Paginated<Pose>> result) {
      when(
        () => repository.getPoses(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          categoryId: any(named: 'categoryId'),
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).thenAnswer((_) async => result);
    }

    Future<void> pumpScreen(WidgetTester tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            poseRepositoryProvider.overrideWithValue(repository),
            talkerProvider.overrideWithValue(Talker()),
          ],
          child: MaterialApp(
            theme: PoselyTheme.dark(),
            home: const PoseLibraryScreen(),
          ),
        ),
      );
    }

    testWidgets('shows the skeleton grid while the first page loads',
        (WidgetTester tester) async {
      final pending = Completer<ApiResult<Paginated<Pose>>>();
      when(
        () => repository.getPoses(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          categoryId: any(named: 'categoryId'),
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).thenAnswer((_) => pending.future);

      await pumpScreen(tester);
      await tester.pump();

      expect(find.text('Pose Library'), findsOneWidget);
      expect(find.byType(SkeletonGrid), findsOneWidget);
      expect(find.byType(PoseCard), findsNothing);
    });

    testWidgets('renders the loaded page as a grid of pose cards',
        (WidgetTester tester) async {
      stubPoses(
        ApiSuccess<Paginated<Pose>>(
          _buildPage(
            <Pose>[_buildPose(), _buildPose(id: 'p2', name: 'Lean Back')],
            hasMore: true,
          ),
        ),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(PoseCard), findsNWidgets(2));
      expect(find.text('Golden Hour'), findsOneWidget);
      expect(find.text('Lean Back'), findsOneWidget);
      expect(find.text('2 poses'), findsOneWidget);
    });

    testWidgets('shows the empty state when no poses match',
        (WidgetTester tester) async {
      stubPoses(ApiSuccess<Paginated<Pose>>(_buildPage(const <Pose>[])));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No poses found'), findsOneWidget);
      expect(find.text('Try a different category or filter.'), findsOneWidget);
    });

    testWidgets('category chips render and tapping one refetches filtered',
        (WidgetTester tester) async {
      when(() => repository.getCategories()).thenAnswer(
        (_) async => const ApiSuccess<List<PoseCategory>>(
          <PoseCategory>[
            PoseCategory(id: 'c1', name: 'Portrait', emoji: '📸'),
          ],
        ),
      );
      stubPoses(
        ApiSuccess<Paginated<Pose>>(_buildPage(<Pose>[_buildPose()])),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('📸 Portrait'), findsOneWidget);

      await tester.tap(find.text('📸 Portrait'));
      await tester.pump();
      await tester.pump();

      verify(
        () => repository.getPoses(
          page: 1,
          pageSize: any(named: 'pageSize'),
          categoryId: 'c1',
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).called(1);
    });

    testWidgets('shows the end-of-list caption when hasMore is false',
        (WidgetTester tester) async {
      stubPoses(
        ApiSuccess<Paginated<Pose>>(
          _buildPage(<Pose>[_buildPose(), _buildPose(id: 'p2')]),
        ),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('You have seen them all'), findsOneWidget);
    });
  });
}
