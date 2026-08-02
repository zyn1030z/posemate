import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/design/skeleton/pose_card_skeleton.dart';
import 'package:posely_ai/core/design/skeleton/shimmer_box.dart';
import 'package:posely_ai/core/design/skeleton/skeleton_grid.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: PoselyTheme.dark(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('SkeletonGrid', () {
    testWidgets('renders itemCount pose card skeletons', (tester) async {
      await tester.pumpWidget(wrap(const SkeletonGrid(itemCount: 4)));
      // Bounded pumps only: the shimmer sweep repeats forever, so
      // pumpAndSettle would never return.
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PoseCardSkeleton), findsNWidgets(4));
    });

    testWidgets('defaults to six skeletons and never scrolls itself',
        (tester) async {
      await tester.pumpWidget(wrap(const SkeletonGrid()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PoseCardSkeleton), findsNWidgets(6));

      final grid = tester.widget<GridView>(find.byType(GridView));
      expect(grid.physics, isA<NeverScrollableScrollPhysics>());
      expect(grid.shrinkWrap, isTrue);
    });
  });

  group('ShimmerBox', () {
    testWidgets('honors an explicit size', (tester) async {
      // Centered so the box gets loose constraints instead of the
      // scroll view's tight cross-axis width.
      await tester.pumpWidget(
        wrap(const Center(child: ShimmerBox(width: 120, height: 16))),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final size = tester.getSize(find.byType(ShimmerBox));
      expect(size.width, 120);
      expect(size.height, 16);
    });
  });
}
