import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/shared/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('a burst of runs collapses to a single trailing call', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 60));
      var calls = 0;

      debouncer.run(() => calls++);
      debouncer.run(() => calls++);
      debouncer.run(() => calls++);

      // Nothing fires before the delay has elapsed.
      expect(calls, 0);
      expect(debouncer.isPending, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(calls, 1);
      expect(debouncer.isPending, isFalse);

      debouncer.dispose();
    });

    test('runs again after a previous call has fired', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 40));
      var calls = 0;

      debouncer.run(() => calls++);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      debouncer.run(() => calls++);
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(calls, 2);
      debouncer.dispose();
    });

    test('cancel prevents the pending call', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 40));
      var calls = 0;

      debouncer.run(() => calls++);
      debouncer.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(calls, 0);
      expect(debouncer.isPending, isFalse);

      debouncer.dispose();
    });

    test('dispose prevents the pending call', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 40));
      var calls = 0;

      debouncer.run(() => calls++);
      debouncer.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(calls, 0);
    });
  });
}
