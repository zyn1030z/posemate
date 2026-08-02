import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/storage/local_storage.dart';

void main() {
  late InMemoryLocalStorage storage;

  setUp(() {
    storage = InMemoryLocalStorage();
  });

  group('StorageBox', () {
    test('box names are prefixed and unique', () {
      final names = StorageBox.values.map((box) => box.boxName).toSet();
      expect(names, hasLength(StorageBox.values.length));
      for (final name in names) {
        expect(name, startsWith('posely_'));
      }
    });
  });

  group('InMemoryLocalStorage', () {
    test('get returns null for an absent key', () {
      expect(storage.get<String>(StorageBox.settings, 'missing'), isNull);
    });

    test('get returns the default for an absent key', () {
      final value = storage.get<int>(
        StorageBox.settings,
        'missing',
        defaultValue: 99,
      );
      expect(value, 99);
    });

    test('put then get round-trips a value', () async {
      await storage.put(StorageBox.settings, 'theme', 'dark');
      expect(storage.get<String>(StorageBox.settings, 'theme'), 'dark');
    });

    test('put overwrites an existing value', () async {
      await storage.put(StorageBox.settings, 'count', 1);
      await storage.put(StorageBox.settings, 'count', 2);
      expect(storage.get<int>(StorageBox.settings, 'count'), 2);
    });

    test('get falls back to the default on a type mismatch', () async {
      await storage.put(StorageBox.settings, 'flag', 'not-a-bool');
      final value = storage.get<bool>(
        StorageBox.settings,
        'flag',
        defaultValue: false,
      );
      expect(value, isFalse);
    });

    test('get returns null on a type mismatch without a default', () async {
      await storage.put(StorageBox.settings, 'flag', 123);
      expect(storage.get<String>(StorageBox.settings, 'flag'), isNull);
    });

    test('boxes are isolated from each other', () async {
      await storage.put(StorageBox.settings, 'key', 'settings-value');
      await storage.put(StorageBox.cache, 'key', 'cache-value');

      expect(
        storage.get<String>(StorageBox.settings, 'key'),
        'settings-value',
      );
      expect(storage.get<String>(StorageBox.cache, 'key'), 'cache-value');
      expect(storage.get<String>(StorageBox.poses, 'key'), isNull);
    });

    test('contains reflects presence of a key', () async {
      expect(storage.contains(StorageBox.poses, 'fav'), isFalse);
      await storage.put(StorageBox.poses, 'fav', <String>['pose-1']);
      expect(storage.contains(StorageBox.poses, 'fav'), isTrue);
    });

    test('delete removes only the targeted key', () async {
      await storage.put(StorageBox.cache, 'a', 1);
      await storage.put(StorageBox.cache, 'b', 2);

      await storage.delete(StorageBox.cache, 'a');

      expect(storage.contains(StorageBox.cache, 'a'), isFalse);
      expect(storage.get<int>(StorageBox.cache, 'b'), 2);
    });

    test('delete on an absent key is a no-op', () async {
      await expectLater(
        storage.delete(StorageBox.cache, 'missing'),
        completes,
      );
    });

    test('clear empties one box and leaves the others intact', () async {
      await storage.put(StorageBox.cache, 'a', 1);
      await storage.put(StorageBox.cache, 'b', 2);
      await storage.put(StorageBox.settings, 'keep', true);

      await storage.clear(StorageBox.cache);

      expect(storage.contains(StorageBox.cache, 'a'), isFalse);
      expect(storage.contains(StorageBox.cache, 'b'), isFalse);
      expect(storage.get<bool>(StorageBox.settings, 'keep'), isTrue);
    });

    test('stores collection values without flattening', () async {
      final ids = <String>['pose-1', 'pose-2'];
      await storage.put(StorageBox.poses, 'recent', ids);
      expect(
        storage.get<List<String>>(StorageBox.poses, 'recent'),
        ['pose-1', 'pose-2'],
      );
    });
  });
}
