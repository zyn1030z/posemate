import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/design/dialogs/posely_dialog.dart';
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

  group('showPoselyDialog', () {
    testWidgets('renders title, message, icon, and actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildHost(
          onOpen: (BuildContext context) {
            showPoselyDialog<void>(
              context: context,
              title: 'Delete photo',
              message: 'This action cannot be undone.',
              icon: Icons.delete_outline_rounded,
              actions: const <PoselyDialogAction>[
                PoselyDialogAction(
                  label: 'Delete',
                  isPrimary: true,
                  isDestructive: true,
                ),
                PoselyDialogAction(label: 'Keep'),
              ],
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete photo'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
    });

    testWidgets('primary and default actions pop the dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildHost(
          onOpen: (BuildContext context) {
            showPoselyDialog<void>(
              context: context,
              title: 'Delete photo',
              actions: const <PoselyDialogAction>[
                PoselyDialogAction(label: 'Delete', isPrimary: true),
                PoselyDialogAction(label: 'Keep'),
              ],
            );
          },
        ),
      );

      // The primary action has no handler, so tapping it pops.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete photo'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete photo'), findsNothing);

      // A ghost action without a handler pops as well.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete photo'), findsOneWidget);

      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      expect(find.text('Delete photo'), findsNothing);
    });
  });

  group('showPoselyConfirmDialog', () {
    testWidgets('resolves true on confirm, false on cancel and barrier',
        (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(
        buildHost(
          onOpen: (BuildContext context) async {
            result = await showPoselyConfirmDialog(
              context: context,
              title: 'Sign out?',
              message: 'You can sign back in anytime.',
            );
          },
        ),
      );

      // Confirm resolves true.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      // Cancel resolves false.
      result = null;
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      // Barrier dismiss resolves false, never null.
      result = null;
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsNothing);
      expect(result, isFalse);
    });
  });
}
