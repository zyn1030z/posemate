import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';
import 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockPoseRepository extends Mock implements PoseRepository {}

Pose _buildPose({
  String id = 'p1',
  String name = 'Golden Hour',
  bool isPremium = false,
  double aiScore = 8.7,
}) {
  return Pose(
    id: id,
    name: name,
    previewUrl: 'https://img.posely.app/$id.jpg',
    overlayUrl: 'https://img.posely.app/$id-overlay.png',
    tags: const <String>['standing'],
    aiScore: aiScore,
    downloads: 12400,
    isPremium: isPremium,
    categoryId: 'c1',
  );
}

void main() {
  group('PoseCard', () {
    late _MockPoseRepository repository;

    setUp(() {
      repository = _MockPoseRepository();
      PoseCard.debugForcePlaceholder = true;
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{});
      when(() => repository.toggleFavorite(any()))
          .thenAnswer((_) async => true);
    });

    tearDown(() {
      PoseCard.debugForcePlaceholder = false;
    });

    Future<void> pumpCard(
      WidgetTester tester, {
      required Pose pose,
      VoidCallback? onTap,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            poseRepositoryProvider.overrideWithValue(repository),
            talkerProvider.overrideWithValue(Talker()),
          ],
          child: MaterialApp(
            theme: PoselyTheme.dark(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 260,
                  child: PoseCard(pose: pose, onTap: onTap),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders name, score, and difficulty',
        (WidgetTester tester) async {
      final pose = _buildPose();
      await pumpCard(tester, pose: pose);

      expect(find.text('Golden Hour'), findsOneWidget);
      expect(find.text('8.7'), findsOneWidget);
      expect(find.text(pose.difficulty.label), findsOneWidget);
    });

    testWidgets('shows the premium badge only for premium poses',
        (WidgetTester tester) async {
      await pumpCard(tester, pose: _buildPose(isPremium: true));
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);

      await pumpCard(tester, pose: _buildPose());
      expect(find.byIcon(Icons.workspace_premium_rounded), findsNothing);
    });

    testWidgets('heart renders filled when the pose is a favorite',
        (WidgetTester tester) async {
      when(() => repository.getFavoriteIds())
          .thenAnswer((_) async => <String>{'p1'});

      await pumpCard(tester, pose: _buildPose());

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    });

    testWidgets('heart tap toggles the favorite through the controller',
        (WidgetTester tester) async {
      await pumpCard(tester, pose: _buildPose());
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      verify(() => repository.toggleFavorite('p1')).called(1);
      // The optimistic flip already filled the heart.
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('card tap fires onTap but the heart tap does not',
        (WidgetTester tester) async {
      var tapped = 0;
      await pumpCard(tester, pose: _buildPose(), onTap: () => tapped++);

      await tester.tap(find.byType(PoseCard));
      await tester.pump();
      expect(tapped, 1);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(tapped, 1);
      verify(() => repository.toggleFavorite('p1')).called(1);
    });
  });
}
