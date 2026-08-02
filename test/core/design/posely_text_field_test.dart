import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/design/inputs/posely_text_field.dart';
import 'package:posely_ai/core/theme/app_theme.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    theme: PoselyTheme.dark(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 360, child: child),
      ),
    ),
  );
}

void main() {
  group('PoselyTextField', () {
    testWidgets('typing updates the controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _harness(PoselyTextField(controller: controller, hint: 'Email')),
      );

      await tester.enterText(find.byType(TextField), 'pose@posely.ai');

      expect(controller.text, 'pose@posely.ai');
    });

    testWidgets('shows errorText below the field', (tester) async {
      await tester.pumpWidget(
        _harness(
          const PoselyTextField(
            label: 'Email',
            errorText: 'This field is required',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('obscure toggle switches obscureText', (tester) async {
      await tester.pumpWidget(
        _harness(const PoselyTextField(obscureText: true)),
      );

      EditableText editable() =>
          tester.widget<EditableText>(find.byType(EditableText));

      expect(editable().obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(editable().obscureText, isFalse);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(editable().obscureText, isTrue);
    });
  });
}
