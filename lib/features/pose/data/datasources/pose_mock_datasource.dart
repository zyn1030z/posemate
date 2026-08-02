import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:posely_ai/core/config/constants/asset_paths.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/pose/data/datasources/pose_remote_datasource.dart';
import 'package:posely_ai/features/pose/data/models/pose_category_model.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';

/// Asset-backed pose backend used by the dev flavor.
///
/// The bundled dataset at assets/mock/poses.json is loaded and parsed once,
/// then served from memory. Behavior mirrors the real contract: list calls
/// paginate and filter server-side, an unknown pose id throws
/// `NotFoundException`, and every call resolves after a simulated latency.
class PoseMockDatasource implements PoseRemoteDatasource {
  /// Creates the mock backend.
  ///
  /// A custom `assetLoader` can be injected for tests (for example returning
  /// an inline JSON fixture); by default the dataset is read from the asset
  /// bundle. A custom `latency` source can also be injected (for example
  /// returning `Duration.zero`); by default each call waits a random
  /// 250–600 ms to imitate a network round trip.
  PoseMockDatasource({
    Future<String> Function(String key)? assetLoader,
    Duration Function()? latency,
  }) : _assetLoader = assetLoader ?? rootBundle.loadString,
       _latency = latency ?? _randomLatency;

  /// How many poses the trending and recommended rails serve.
  static const int _railSize = 10;

  /// Fixed shuffle seed so recommendations are stable across calls.
  static const int _recommendationSeed = 42;

  static final Random _random = Random();

  final Future<String> Function(String key) _assetLoader;
  final Duration Function() _latency;

  /// Parsed dataset, cached after the first load; a shared future so
  /// concurrent first calls trigger only one asset read.
  Future<_MockPoseLibrary>? _library;

  @override
  Future<List<PoseCategoryModel>> getCategories() async {
    await _delay();
    final library = await _load();
    return List<PoseCategoryModel>.unmodifiable(library.categories);
  }

  @override
  Future<Paginated<PoseModel>> getPoses({
    required int page,
    required int pageSize,
    String? categoryId,
    String? difficulty,
    String? gender,
  }) async {
    await _delay();
    final library = await _load();
    final filtered = library.poses
        .where(
          (pose) =>
              (categoryId == null || pose.categoryId == categoryId) &&
              (difficulty == null || pose.difficulty == difficulty) &&
              (gender == null || pose.gender == gender),
        )
        .toList();
    final start = (page - 1) * pageSize;
    final items = start >= filtered.length
        ? const <PoseModel>[]
        : filtered.sublist(start, min(start + pageSize, filtered.length));
    return Paginated<PoseModel>(
      items: items,
      page: page,
      pageSize: pageSize,
      totalItems: filtered.length,
      hasMore: start + items.length < filtered.length,
    );
  }

  @override
  Future<PoseModel> getPoseById(String id) async {
    await _delay();
    final library = await _load();
    for (final pose in library.poses) {
      if (pose.id == id) {
        return pose;
      }
    }
    throw const NotFoundException();
  }

  @override
  Future<List<PoseModel>> getTrending() async {
    await _delay();
    final library = await _load();
    final sorted = [...library.poses]
      ..sort((a, b) => b.downloads.compareTo(a.downloads));
    return sorted.take(_railSize).toList();
  }

  @override
  Future<List<PoseModel>> getRecommended() async {
    await _delay();
    final library = await _load();
    final sorted = [...library.poses]
      ..sort((a, b) => b.aiScore.compareTo(a.aiScore));
    // Fixed seed: the "personalized" order looks organic yet stays
    // deterministic across calls and test runs.
    return sorted.take(_railSize).toList()
      ..shuffle(Random(_recommendationSeed));
  }

  Future<_MockPoseLibrary> _load() => _library ??= _parseAsset();

  Future<_MockPoseLibrary> _parseAsset() async {
    final raw = await _assetLoader(AssetPaths.mockPoses);
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const UnknownException(
        message: 'Mock pose dataset is not a JSON object.',
      );
    }
    final Object? categories = decoded['categories'];
    final Object? poses = decoded['poses'];
    if (categories is! List<dynamic> || poses is! List<dynamic>) {
      throw const UnknownException(
        message: 'Mock pose dataset is missing categories or poses.',
      );
    }
    return _MockPoseLibrary(
      categories: categories
          .map(
            (item) => PoseCategoryModel.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      poses: poses
          .map((item) => PoseModel.fromJson(item! as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> _delay() => Future<void>.delayed(_latency());

  static Duration _randomLatency() =>
      Duration(milliseconds: 250 + _random.nextInt(351));
}

/// The parsed mock dataset held in memory.
class _MockPoseLibrary {
  const _MockPoseLibrary({required this.categories, required this.poses});

  final List<PoseCategoryModel> categories;
  final List<PoseModel> poses;
}
