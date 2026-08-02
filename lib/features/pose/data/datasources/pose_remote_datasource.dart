import 'package:dio/dio.dart';
import 'package:posely_ai/core/config/constants/api_endpoints.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/pose/data/models/pose_category_model.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';

/// Remote source of truth for the pose library.
///
/// Implementations throw `AppException` or `DioException` upward; error
/// mapping happens in the repository via `guardApi`.
abstract interface class PoseRemoteDatasource {
  /// Fetches the full category taxonomy.
  Future<List<PoseCategoryModel>> getCategories();

  /// Fetches one page of the pose library, optionally filtered.
  ///
  /// Filter values travel as wire strings; converting domain enums to their
  /// names is the repository's job.
  Future<Paginated<PoseModel>> getPoses({
    required int page,
    required int pageSize,
    String? categoryId,
    String? difficulty,
    String? gender,
    String? peopleCount,
    String? bodyDirection,
  });

  /// Fetches a single pose by its identifier.
  Future<PoseModel> getPoseById(String id);

  /// Fetches the poses currently trending across the community.
  Future<List<PoseModel>> getTrending();

  /// Fetches personalized pose recommendations for the current user.
  Future<List<PoseModel>> getRecommended();
}

/// Dio-backed implementation talking to the real backend.
///
/// Response bodies match docs/API_CONTRACTS.md: list endpoints return the
/// pagination envelope as the top-level JSON object, and the single-pose
/// endpoint returns the pose object itself.
class PoseApiDatasource implements PoseRemoteDatasource {
  /// Creates the datasource with the app-wide Dio client.
  const PoseApiDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<PoseCategoryModel>> getCategories() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.categories,
    );
    final Object? items = _requireBody(response)['items'];
    if (items is! List<dynamic>) {
      throw const UnknownException(
        message: 'Category response is missing the items list.',
      );
    }
    return items
        .map(
          (item) => PoseCategoryModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<Paginated<PoseModel>> getPoses({
    required int page,
    required int pageSize,
    String? categoryId,
    String? difficulty,
    String? gender,
    String? peopleCount,
    String? bodyDirection,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.poses,
      queryParameters: <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (categoryId != null) 'category_id': categoryId,
        if (difficulty != null) 'difficulty': difficulty,
        if (gender != null) 'gender': gender,
        if (peopleCount != null) 'people_count': peopleCount,
        if (bodyDirection != null) 'body_direction': bodyDirection,
      },
    );
    return Paginated<PoseModel>.fromJson(
      _requireBody(response),
      _poseFromJson,
    );
  }

  @override
  Future<PoseModel> getPoseById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.poseById(id),
    );
    return PoseModel.fromJson(_requireBody(response));
  }

  @override
  Future<List<PoseModel>> getTrending() =>
      _fetchPoseList(ApiEndpoints.trending);

  @override
  Future<List<PoseModel>> getRecommended() =>
      _fetchPoseList(ApiEndpoints.recommended);

  /// Fetches a paginated pose endpoint and unwraps just the items.
  Future<List<PoseModel>> _fetchPoseList(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    return Paginated<PoseModel>.fromJson(
      _requireBody(response),
      _poseFromJson,
    ).items;
  }

  /// Decodes one pose item inside a pagination envelope.
  static PoseModel _poseFromJson(Object? item) =>
      PoseModel.fromJson(item! as Map<String, dynamic>);

  /// Returns the response body, guarding against an empty one.
  static Map<String, dynamic> _requireBody(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data;
    if (data == null) {
      throw UnknownException(
        message: 'Empty pose response body from '
            '${response.requestOptions.path}.',
      );
    }
    return data;
  }
}
