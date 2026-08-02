import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/design/chips/posely_chip.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    theme: PoselyTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PoselyChip', () {
    testWidgets('renders in the unselected state', (tester) async {
      await tester.pumpWidget(
        _harness(const PoselyChip(label: 'Portrait')),
      );

      expect(find.text('Portrait'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in the selected state', (tester) async {
      await tester.pumpWidget(
        _harness(
          const PoselyChip(
            label: 'Portrait',
            selected: true,
            icon: Icons.person_outline,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Portrait'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _harness(PoselyChip(label: 'Full body', onTap: () => taps++)),
      );

      await tester.tap(find.byType(PoselyChip));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });
}
