import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/paginated.dart';
import 'package:posely_ai/features/community/data/repositories/community_repository.dart';
import 'package:posely_ai/features/community/domain/entities/community_post.dart';
import 'package:posely_ai/features/community/presentation/controllers/feed_controller.dart';

class MockCommunityRepository extends Mock implements CommunityRepository {}

void main() {
  late MockCommunityRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockCommunityRepository();
    container = ProviderContainer(
      overrides: [
        communityRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('FeedController loads first page on init', () async {
    final mockPost = CommunityPost(
      id: '1',
      authorId: 'user1',
      authorName: 'Test',
      authorAvatarUrl: '',
      imageUrl: '',
      createdAt: DateTime.now(),
    );

    when(() => mockRepo.getFeed(page: 1)).thenAnswer(
      (_) async => Paginated(
        items: [mockPost],
        page: 1,
        pageSize: 20,
        totalItems: 1,
        hasMore: false,
      ),
    );

    final sub = container.listen(feedControllerProvider, (_, __) {});
    final state = await container.read(feedControllerProvider.future);

    expect(state.length, 1);
    expect(state.first.id, '1');
    verify(() => mockRepo.getFeed(page: 1)).called(1);
    
    sub.close();
  });

  test('toggleLike updates optimistically', () async {
    final mockPost = CommunityPost(
      id: '1',
      authorId: 'user1',
      authorName: 'Test',
      authorAvatarUrl: '',
      imageUrl: '',
      createdAt: DateTime.now(),
      likesCount: 10,
      isLiked: false,
    );

    when(() => mockRepo.getFeed(page: 1)).thenAnswer(
      (_) async => Paginated(
        items: [mockPost],
        page: 1,
        pageSize: 20,
        totalItems: 1,
        hasMore: false,
      ),
    );

    when(() => mockRepo.toggleLike('1')).thenAnswer((_) async {});

    // Init
    await container.read(feedControllerProvider.future);

    // Toggle like
    await container.read(feedControllerProvider.notifier).toggleLike('1');

    final state = container.read(feedControllerProvider).value!;
    expect(state.first.isLiked, true);
    expect(state.first.likesCount, 11);

    verify(() => mockRepo.toggleLike('1')).called(1);
  });
}
