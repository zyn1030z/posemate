import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/design/states/empty_state.dart';
import 'package:posely_ai/core/design/states/success_state.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: PoselyTheme.dark(),
      home: Scaffold(body: child),
    );
  }

  /// Flushes the one-shot entrance animations with bounded pumps.
  Future<void> settleEntrance(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
  }

  group('EmptyState', () {
    testWidgets('shows title, message, and action', (tester) async {
      await tester.pumpWidget(
        wrap(
          EmptyState(
            title: 'No poses yet',
            message: 'Capture your first pose to get started.',
            action: TextButton(
              onPressed: () {},
              child: const Text('Browse poses'),
            ),
          ),
        ),
      );
      await settleEntrance(tester);

      expect(find.text('No poses yet'), findsOneWidget);
      expect(
        find.text('Capture your first pose to get started.'),
        findsOneWidget,
      );
      expect(find.text('Browse poses'), findsOneWidget);
    });
  });

  group('SuccessState', () {
    testWidgets('shows the title', (tester) async {
      await tester.pumpWidget(
        wrap(const SuccessState(title: 'Pose saved')),
      );
      await settleEntrance(tester);

      expect(find.text('Pose saved'), findsOneWidget);
    });
  });

  group('AppErrorView', () {
    testWidgets('retry button fires the callback', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(
          AppErrorView(
            message: 'Could not load poses.',
            onRetry: () => retried = true,
          ),
        ),
      );
      await settleEntrance(tester);

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Could not load poses.'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}
