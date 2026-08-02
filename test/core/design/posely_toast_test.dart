import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/design/feedback/posely_toast.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

void main() {
  Widget buildHost() {
    return MaterialApp(
      theme: PoselyTheme.dark(),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () => PoselyToast.show(
                      context,
                      message: 'First toast',
                    ),
                    child: const Text('Show first'),
                  ),
                  TextButton(
                    onPressed: () => PoselyToast.show(
                      context,
                      message: 'Second toast',
                      kind: PoselyToastKind.success,
                    ),
                    child: const Text('Show second'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Pumps through a full toast lifecycle: entrance, hold, exit, and
  /// the removal frame. Uses explicit pumps because the toast drives
  /// its own animation controller.
  Future<void> drainToast(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  group('PoselyToast', () {
    testWidgets('show displays the message', (WidgetTester tester) async {
      await tester.pumpWidget(buildHost());

      await tester.tap(find.text('Show first'));
      await tester.pump();

      expect(find.text('First toast'), findsOneWidget);

      await drainToast(tester);
    });

    testWidgets('auto-dismisses after its duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildHost());

      await tester.tap(find.text('Show first'));
      await tester.pump();
      expect(find.text('First toast'), findsOneWidget);

      // Entrance completes, the toast holds for its duration, then the
      // exit animation runs and the entry is removed.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('First toast'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('First toast'), findsNothing);
    });

    testWidgets('a second show replaces the first toast',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildHost());

      await tester.tap(find.text('Show first'));
      await tester.pump();
      expect(find.text('First toast'), findsOneWidget);

      await tester.tap(find.text('Show second'));
      await tester.pump();

      expect(find.text('First toast'), findsNothing);
      expect(find.text('Second toast'), findsOneWidget);

      await drainToast(tester);
      expect(find.text('Second toast'), findsNothing);
    });
  });
}
