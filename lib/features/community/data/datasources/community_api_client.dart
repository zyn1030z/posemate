import 'package:dio/dio.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/community/domain/entities/community_post.dart';
import 'package:retrofit/retrofit.dart';

part 'community_api_client.g.dart';

@RestApi()
abstract class CommunityApiClient {
  factory CommunityApiClient(Dio dio, {String baseUrl}) = _CommunityApiClient;

  /// Fetches the paginated community feed.
  @GET('/community/feed')
  Future<Paginated<CommunityPost>> getFeed({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  /// Toggles the like status of a post.
  @POST('/community/posts/{id}/like')
  Future<void> toggleLike(@Path('id') String id);

  /// Reports a post for moderation.
  @POST('/community/posts/{id}/report')
  Future<void> reportPost(@Path('id') String id, @Body() Map<String, dynamic> reason);

  /// Blocks a user, hiding their content.
  @POST('/community/users/{id}/block')
  Future<void> blockUser(@Path('id') String userId);
}
