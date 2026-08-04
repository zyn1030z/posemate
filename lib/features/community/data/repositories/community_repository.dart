import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/dio_client.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/community/data/datasources/community_api_client.dart';
import 'package:posely_ai/features/community/domain/entities/community_post.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CommunityRepositoryImpl(CommunityApiClient(dio));
});

abstract class CommunityRepository {
  Future<Paginated<CommunityPost>> getFeed({int page = 1, int limit = 20});
  Future<void> toggleLike(String postId);
  Future<void> reportPost(String postId, String reason);
  Future<void> blockUser(String userId);
}

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this._client);

  final CommunityApiClient _client;

  @override
  Future<Paginated<CommunityPost>> getFeed({int page = 1, int limit = 20}) async {
    // If backend is not ready, we can return dummy data here or throw an exception.
    // For now, we attempt the real API call. The controller can handle errors if any.
    return _client.getFeed(page: page, limit: limit);
  }

  @override
  Future<void> toggleLike(String postId) async {
    return _client.toggleLike(postId);
  }

  @override
  Future<void> reportPost(String postId, String reason) async {
    return _client.reportPost(postId, {'reason': reason});
  }

  @override
  Future<void> blockUser(String userId) async {
    return _client.blockUser(userId);
  }
}
