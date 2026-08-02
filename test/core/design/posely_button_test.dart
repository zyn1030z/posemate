import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/design/buttons/posely_button.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    theme: PoselyTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PoselyButton', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _harness(PoselyButton(label: 'Continue', onPressed: () {})),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _harness(PoselyButton(label: 'Tap me', onPressed: () => presses++)),
      );

      await tester.tap(find.byType(PoselyButton));
      await tester.pumpAndSettle();

      expect(presses, 1);
    });

    testWidgets('blocks taps and dims when disabled', (tester) async {
      await tester.pumpWidget(
        _harness(const PoselyButton(label: 'Disabled')),
      );

      await tester.tap(find.byType(PoselyButton));
      await tester.pump();

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(PoselyButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.4);
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading shows spinner and blocks taps', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _harness(
          PoselyButton(
            label: 'Save',
            loading: true,
            onPressed: () => presses++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);

      await tester.tap(find.byType(PoselyButton));
      await tester.pump();

      expect(presses, 0);
    });

    testWidgets('renders every variant without exceptions', (tester) async {
      for (final variant in PoselyButtonVariant.values) {
        await tester.pumpWidget(
          _harness(
            PoselyButton(
              label: 'Variant',
              variant: variant,
              icon: Icons.camera_alt_outlined,
              onPressed: () {},
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Variant'), findsOneWidget);
      }
    });
  });
}
