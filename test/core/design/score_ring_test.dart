import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/design/score/score_ring.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: PoselyTheme.dark(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('ScoreRing', () {
    testWidgets('renders the rounded percentage for the score',
        (tester) async {
      await tester.pumpWidget(
        wrap(const ScoreRing(score: 0.87, animate: false)),
      );

      expect(find.text('87'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('announces the score as a percentage', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          const ScoreRing(score: 0.87, label: 'Pose score', animate: false),
        ),
      );

      final node = tester.getSemantics(find.byType(ScoreRing));
      expect(node.label, contains('percent'));
      expect(node.label, contains('Pose score'));
      handle.dispose();
    });

    testWidgets('shows the label caption under the digits', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ScoreRing(score: 0.42, label: 'Pose score', animate: false),
        ),
      );

      expect(find.text('Pose score'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    test('asserts when the score is out of range', () {
      const outOfRange = <double>[1.2, -0.1];
      for (final score in outOfRange) {
        expect(() => ScoreRing(score: score), throwsAssertionError);
      }
    });
  });
}
