import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/core/network/dio_client.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/pose/data/datasources/pose_mock_datasource.dart';
import 'package:posely_ai/features/pose/data/datasources/pose_remote_datasource.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';

/// Concrete pose repository wiring the remote datasource and local storage
/// together.
///
/// Library reads come from the datasource and are wrapped in `guardApi` so
/// every failure surfaces as a typed `ApiFailure`. Favorites and the
/// recently-used list are device-local, stored in the poses box, and read
/// defensively: Hive returns untyped lists and maps, and a corrupt entry is
/// skipped rather than crashing the feature.
class PoseRepositoryImpl implements PoseRepository {
  /// Creates the repository with its collaborators.
  PoseRepositoryImpl({
    required PoseRemoteDatasource remoteDatasource,
    required LocalStorage localStorage,
  })  : _remoteDatasource = remoteDatasource,
        _localStorage = localStorage {
    _migrateOldKeys();
  }

  /// Legacy keys used before unification. Kept only for migration.
  static const String _legacyFavoritesKey = 'favorites.ids';
  static const String _legacyRecentKey = 'recent.poses';

  /// Maximum number of recently used poses kept on the device.
  static const int _recentLimit = 12;

  final PoseRemoteDatasource _remoteDatasource;
  final LocalStorage _localStorage;

  @override
  Future<ApiResult<List<PoseCategory>>> getCategories() =>
      guardApi(() async {
        final models = await _remoteDatasource.getCategories();
        return models.map((model) => model.toEntity()).toList();
      });

  @override
  Future<ApiResult<Paginated<Pose>>> getPoses({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? categoryId,
    PoseDifficulty? difficulty,
    PoseGender? gender,
    PeopleCount? peopleCount,
    BodyDirection? bodyDirection,
  }) => guardApi(() async {
    final result = await _remoteDatasource.getPoses(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
      difficulty: difficulty?.name,
      gender: gender?.name,
      peopleCount: peopleCount?.name,
      bodyDirection: bodyDirection == BodyDirection.threeQuarter
          ? 'three-quarter'
          : bodyDirection?.name,
    );
    return Paginated<Pose>(
      items: result.items.map((model) => model.toEntity()).toList(),
      page: result.page,
      pageSize: result.pageSize,
      totalItems: result.totalItems,
      hasMore: result.hasMore,
    );
  });

  @override
  Future<ApiResult<Pose>> getPoseById(String id) => guardApi(() async {
    final model = await _remoteDatasource.getPoseById(id);
    return model.toEntity();
  });

  @override
  Future<ApiResult<List<Pose>>> getTrending() => guardApi(() async {
    final models = await _remoteDatasource.getTrending();
    return models.map((model) => model.toEntity()).toList();
  });

  @override
  Future<ApiResult<List<Pose>>> getRecommended() => guardApi(() async {
    final models = await _remoteDatasource.getRecommended();
    return models.map((model) => model.toEntity()).toList();
  });

  @override
  Future<List<Pose>> getRecentlyUsed() async {
    final poses = <Pose>[];
    for (final entry in _readRecentRaw()) {
      if (entry is! Map<dynamic, dynamic>) {
        continue;
      }
      try {
        poses.add(
          PoseModel.fromJson(Map<String, dynamic>.from(entry)).toEntity(),
        );
      } catch (_) {
        // Corrupt entry (schema drift, partial write): skip it rather than
        // losing the whole recent list.
        continue;
      }
    }
    return poses;
  }

  @override
  Future<void> markUsed(Pose pose) async {
    final entries = <Map<String, dynamic>>[_poseToMap(pose)];
    for (final entry in _readRecentRaw()) {
      if (entries.length >= _recentLimit) {
        break;
      }
      if (entry is! Map<dynamic, dynamic>) {
        continue;
      }
      final map = Map<String, dynamic>.from(entry);
      if (map['id'] == pose.id) {
        // Dedupe: the pose moves to the front instead of appearing twice.
        continue;
      }
      entries.add(map);
    }
    await _localStorage.put(StorageBox.poses, StorageKeys.lastUsedPoseIds, entries);
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    final raw = _localStorage.get<List<dynamic>>(
      StorageBox.poses,
      StorageKeys.favoritePoseIds,
    );
    // Hive returns List<dynamic>; keep only well-typed entries.
    return (raw ?? const <dynamic>[]).whereType<String>().toSet();
  }

  @override
  Future<bool> toggleFavorite(String poseId) async {
    final ids = await getFavoriteIds();
    final isFavorite = !ids.contains(poseId);
    if (isFavorite) {
      ids.add(poseId);
    } else {
      ids.remove(poseId);
    }
    await _localStorage.put(StorageBox.poses, StorageKeys.favoritePoseIds, ids.toList());
    return isFavorite;
  }

  /// Reads the raw recently-used list, tolerating any stored shape.
  List<dynamic> _readRecentRaw() =>
      _localStorage.get<List<dynamic>>(StorageBox.poses, StorageKeys.lastUsedPoseIds) ??
      const <dynamic>[];

  /// One-time migration from pre-unification storage keys.
  ///
  /// If data exists under the old keys, it is copied to the canonical
  /// `StorageKeys` constants and the old entries are removed. This runs
  /// synchronously in the constructor since Hive reads are sync; the
  /// delete calls are fire-and-forget.
  void _migrateOldKeys() {
    if (_localStorage.contains(StorageBox.poses, _legacyFavoritesKey)) {
      final old = _localStorage.get<List<dynamic>>(
        StorageBox.poses,
        _legacyFavoritesKey,
      );
      if (old != null) {
        _localStorage.put(
          StorageBox.poses,
          StorageKeys.favoritePoseIds,
          old,
        );
      }
      _localStorage.delete(StorageBox.poses, _legacyFavoritesKey);
    }
    if (_localStorage.contains(StorageBox.poses, _legacyRecentKey)) {
      final old = _localStorage.get<List<dynamic>>(
        StorageBox.poses,
        _legacyRecentKey,
      );
      if (old != null) {
        _localStorage.put(
          StorageBox.poses,
          StorageKeys.lastUsedPoseIds,
          old,
        );
      }
      _localStorage.delete(StorageBox.poses, _legacyRecentKey);
    }
  }

  /// Serializes a pose entity to a wire-shaped map so the stored value can
  /// be parsed back through the pose wire model.
  Map<String, dynamic> _poseToMap(Pose pose) => <String, dynamic>{
    'id': pose.id,
    'name': pose.name,
    'preview_url': pose.previewUrl,
    'overlay_url': pose.overlayUrl,
    'tags': pose.tags,
    'difficulty': pose.difficulty.name,
    'gender': pose.gender.name,
    'body_direction': pose.bodyDirection,
    'camera_angle': pose.cameraAngle,
    'ai_score': pose.aiScore,
    'downloads': pose.downloads,
    'is_premium': pose.isPremium,
    'category_id': pose.categoryId,
  };
}

/// Provides the pose remote datasource, honoring the flavor's mock flag.
final poseRemoteDatasourceProvider = Provider<PoseRemoteDatasource>((ref) {
  if (ref.watch(appConfigProvider).useMockData) {
    return PoseMockDatasource();
  }
  return PoseApiDatasource(dio: ref.watch(dioProvider));
});

/// Provides the app-wide pose repository.
final poseRepositoryProvider = Provider<PoseRepository>(
  (ref) => PoseRepositoryImpl(
    remoteDatasource: ref.watch(poseRemoteDatasourceProvider),
    localStorage: ref.watch(localStorageProvider),
  ),
);
