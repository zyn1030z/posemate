import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/design/sheets/posely_bottom_sheet.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

void main() {
  Widget buildHost({required void Function(BuildContext context) onOpen}) {
    return MaterialApp(
      theme: PoselyTheme.dark(),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (BuildContext context) {
              return FilledButton(
                onPressed: () => onOpen(context),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('showPoselyBottomSheet', () {
    testWidgets('shows title, content, and drag handle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildHost(
          onOpen: (BuildContext context) {
            showPoselyBottomSheet<void>(
              context: context,
              title: 'Pose filters',
              builder: (BuildContext sheetContext) =>
                  const Text('Sheet content'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Pose filters'), findsOneWidget);
      expect(find.text('Sheet content'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('posely_bottom_sheet_drag_handle')),
        findsOneWidget,
      );
    });

    testWidgets('close button pops with null', (WidgetTester tester) async {
      Object? result = 'unset';
      await tester.pumpWidget(
        buildHost(
          onOpen: (BuildContext context) async {
            result = await showPoselyBottomSheet<Object>(
              context: context,
              title: 'Pose filters',
              builder: (BuildContext sheetContext) =>
                  const Text('Sheet content'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Pose filters'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Pose filters'), findsNothing);
      expect(find.text('Sheet content'), findsNothing);
      expect(result, isNull);
    });
  });
}
