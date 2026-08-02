// ignore_for_file: avoid_redundant_argument_values
// Explicit argument values inside mocktail verify blocks are assertions
// about the call, not redundant defaults — keep them spelled out.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';
import 'package:posely_ai/features/pose/presentation/controllers/pose_library_controller.dart';
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

Paginated<Pose> _buildPage(
  List<Pose> items, {
  int page = 1,
  bool hasMore = false,
}) {
  return Paginated<Pose>(
    items: items,
    page: page,
    pageSize: AppConstants.defaultPageSize,
    totalItems: 40,
    hasMore: hasMore,
  );
}

void main() {
  group('PoseLibraryController', () {
    late _MockPoseRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _MockPoseRepository();
      container = ProviderContainer(
        overrides: [
          poseRepositoryProvider.overrideWithValue(repository),
          talkerProvider.overrideWithValue(Talker()),
        ],
      );
      addTearDown(container.dispose);
    });

    /// Routes every getPoses call through the given responder, keyed by
    /// the requested page and categoryId.
    void stubGetPoses(
      Future<ApiResult<Paginated<Pose>>> Function(int page, String? categoryId)
          responder,
    ) {
      when(
        () => repository.getPoses(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          categoryId: any(named: 'categoryId'),
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).thenAnswer((invocation) {
        final page = invocation.namedArguments[#page]! as int;
        final categoryId =
            invocation.namedArguments[#categoryId] as String?;
        return responder(page, categoryId);
      });
    }

    test('build loads the first page with default filters', () async {
      final poses = <Pose>[_buildPose(), _buildPose(id: 'p2', name: 'Lean')];
      stubGetPoses(
        (page, categoryId) async =>
            ApiSuccess<Paginated<Pose>>(_buildPage(poses, hasMore: true)),
      );

      final state = await container.read(poseLibraryControllerProvider.future);

      expect(state.poses, hasLength(2));
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreError, isNull);
      expect(state.filters, const PoseLibraryFilters());
      verify(
        () => repository.getPoses(
          page: 1,
          pageSize: AppConstants.defaultPageSize,
          categoryId: null,
          difficulty: null,
          gender: null,
        ),
      ).called(1);
    });

    test('build surfaces a first-page failure as error state', () async {
      stubGetPoses(
        (page, categoryId) async =>
            const ApiFailure<Paginated<Pose>>(ServerException()),
      );

      await expectLater(
        container.read(poseLibraryControllerProvider.future),
        throwsA(isA<ServerException>()),
      );
      expect(container.read(poseLibraryControllerProvider).hasError, isTrue);
    });

    test('loadMore appends the next page and respects hasMore', () async {
      stubGetPoses((page, categoryId) async {
        if (page == 1) {
          return ApiSuccess<Paginated<Pose>>(
            _buildPage(
              <Pose>[_buildPose(), _buildPose(id: 'p2')],
              hasMore: true,
            ),
          );
        }
        return ApiSuccess<Paginated<Pose>>(
          _buildPage(
            <Pose>[_buildPose(id: 'p3'), _buildPose(id: 'p4')],
            page: 2,
          ),
        );
      });
      await container.read(poseLibraryControllerProvider.future);
      final notifier = container.read(poseLibraryControllerProvider.notifier);

      await notifier.loadMore();

      final state = container.read(poseLibraryControllerProvider).value!;
      expect(
        state.poses.map((pose) => pose.id),
        <String>['p1', 'p2', 'p3', 'p4'],
      );
      expect(state.page, 2);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);

      // hasMore is exhausted, so another call never hits the repository.
      await notifier.loadMore();
      verify(
        () => repository.getPoses(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          categoryId: any(named: 'categoryId'),
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).called(2);
    });

    test('loadMore is a no-op while a page is already in flight', () async {
      final secondPage = Completer<ApiResult<Paginated<Pose>>>();
      stubGetPoses((page, categoryId) {
        if (page == 1) {
          return Future<ApiResult<Paginated<Pose>>>.value(
            ApiSuccess<Paginated<Pose>>(
              _buildPage(<Pose>[_buildPose()], hasMore: true),
            ),
          );
        }
        return secondPage.future;
      });
      await container.read(poseLibraryControllerProvider.future);
      final notifier = container.read(poseLibraryControllerProvider.notifier);

      final first = notifier.loadMore();
      final second = notifier.loadMore();
      secondPage.complete(
        ApiSuccess<Paginated<Pose>>(
          _buildPage(<Pose>[_buildPose(id: 'p2')], page: 2),
        ),
      );
      await first;
      await second;

      final state = container.read(poseLibraryControllerProvider).value!;
      expect(state.poses, hasLength(2));
      verify(
        () => repository.getPoses(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          categoryId: any(named: 'categoryId'),
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).called(2);
    });

    test('setFilters reloads from page 1 and drops a stale response',
        () async {
      final slowResponse = Completer<ApiResult<Paginated<Pose>>>();
      stubGetPoses((page, categoryId) {
        if (categoryId == 'slow') {
          return slowResponse.future;
        }
        if (categoryId == 'fast') {
          return Future<ApiResult<Paginated<Pose>>>.value(
            ApiSuccess<Paginated<Pose>>(
              _buildPage(<Pose>[_buildPose(id: 'fast-1', name: 'Fast')]),
            ),
          );
        }
        return Future<ApiResult<Paginated<Pose>>>.value(
          ApiSuccess<Paginated<Pose>>(_buildPage(<Pose>[_buildPose()])),
        );
      });
      await container.read(poseLibraryControllerProvider.future);
      final notifier = container.read(poseLibraryControllerProvider.notifier);

      final slowCall =
          notifier.setFilters(const PoseLibraryFilters(categoryId: 'slow'));
      final fastCall =
          notifier.setFilters(const PoseLibraryFilters(categoryId: 'fast'));
      await fastCall;

      // The delayed old-filter payload arrives after the new one.
      slowResponse.complete(
        ApiSuccess<Paginated<Pose>>(
          _buildPage(<Pose>[_buildPose(id: 'slow-1', name: 'Slow')]),
        ),
      );
      await slowCall;

      final state = container.read(poseLibraryControllerProvider).value!;
      expect(state.filters.categoryId, 'fast');
      expect(state.poses.single.id, 'fast-1');
      verify(
        () => repository.getPoses(
          page: 1,
          pageSize: any(named: 'pageSize'),
          categoryId: 'fast',
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).called(1);
    });

    test('loadMore failure keeps items and surfaces loadMoreError',
        () async {
      stubGetPoses((page, categoryId) async {
        if (page == 1) {
          return ApiSuccess<Paginated<Pose>>(
            _buildPage(
              <Pose>[_buildPose(), _buildPose(id: 'p2')],
              hasMore: true,
            ),
          );
        }
        return const ApiFailure<Paginated<Pose>>(ServerException());
      });
      await container.read(poseLibraryControllerProvider.future);
      final notifier = container.read(poseLibraryControllerProvider.notifier);

      await notifier.loadMore();

      final state = container.read(poseLibraryControllerProvider).value!;
      expect(state.poses, hasLength(2));
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.loadMoreError, isA<ServerException>());

      notifier.clearLoadMoreError();
      expect(
        container
            .read(poseLibraryControllerProvider)
            .value!
            .loadMoreError,
        isNull,
      );
    });

    test('refresh reloads the first page with current filters', () async {
      var calls = 0;
      stubGetPoses((page, categoryId) async {
        calls++;
        if (calls == 1) {
          return ApiSuccess<Paginated<Pose>>(_buildPage(<Pose>[_buildPose()]));
        }
        return ApiSuccess<Paginated<Pose>>(
          _buildPage(<Pose>[_buildPose(id: 'r1'), _buildPose(id: 'r2')]),
        );
      });
      await container.read(poseLibraryControllerProvider.future);
      final notifier = container.read(poseLibraryControllerProvider.notifier);

      await notifier.refresh();

      final state = container.read(poseLibraryControllerProvider).value!;
      expect(state.poses, hasLength(2));
      expect(state.page, 1);
      verify(
        () => repository.getPoses(
          page: 1,
          pageSize: any(named: 'pageSize'),
          categoryId: any(named: 'categoryId'),
          difficulty: any(named: 'difficulty'),
          gender: any(named: 'gender'),
        ),
      ).called(2);
    });
  });
}
