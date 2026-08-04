import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/community/data/repositories/community_repository.dart';
import 'package:posely_ai/features/community/domain/entities/community_post.dart';

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<CommunityPost>>(
  FeedController.new,
);

class FeedController extends AsyncNotifier<List<CommunityPost>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<CommunityPost>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    // TODO: When backend is ready, remove this mock fallback.
    try {
      final repo = ref.watch(communityRepositoryProvider);
      final paginated = await repo.getFeed(page: _currentPage);
      _hasMore = paginated.hasMore;
      return paginated.items;
    } catch (e) {
      // Mock data for UI development if backend is not ready
      return _generateMockData();
    }
  }

  List<CommunityPost> _generateMockData() {
    return List.generate(
      5,
      (i) => CommunityPost(
        id: 'mock_post_$i',
        authorId: 'user_$i',
        authorName: 'CreativePoser$i',
        authorAvatarUrl: 'https://i.pravatar.cc/150?u=user_$i',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800',
        createdAt: DateTime.now().subtract(Duration(hours: i * 2)),
        likesCount: 12 + (i * 7),
        commentsCount: 3 + i,
        isLiked: i % 2 == 0,
      ),
    );
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _isLoadingMore || state.value == null) return;
    
    _isLoadingMore = true;
    _currentPage++;
    
    try {
      final repo = ref.read(communityRepositoryProvider);
      final paginated = await repo.getFeed(page: _currentPage);
      
      _hasMore = paginated.hasMore;
      final currentList = state.value!;
      state = AsyncValue.data([...currentList, ...paginated.items]);
    } catch (e) {
      // For mock UI, just stop loading
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final previousState = state;
    
    // Optimistic UI Update
    if (state.value != null) {
      final updated = state.value!.map((post) {
        if (post.id == postId) {
          final newIsLiked = !post.isLiked;
          return post.copyWith(
            isLiked: newIsLiked,
            likesCount: post.likesCount + (newIsLiked ? 1 : -1),
          );
        }
        return post;
      }).toList();
      state = AsyncValue.data(updated);
    }

    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.toggleLike(postId);
    } catch (e, stack) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reportPost(String postId, String reason) async {
    final previousState = state;
    
    // Optimistically remove from feed locally
    if (state.value != null) {
      final updated = state.value!.where((post) => post.id != postId).toList();
      state = AsyncValue.data(updated);
    }

    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.reportPost(postId, reason);
    } catch (e, stack) {
      state = previousState;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> blockUser(String authorId) async {
    final previousState = state;
    
    // Optimistically remove all posts by this user from feed
    if (state.value != null) {
      final updated = state.value!.where((post) => post.authorId != authorId).toList();
      state = AsyncValue.data(updated);
    }

    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.blockUser(authorId);
    } catch (e, stack) {
      state = previousState;
      state = AsyncValue.error(e, stack);
    }
  }
}
