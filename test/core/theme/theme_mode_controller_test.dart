import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/theme/theme_mode_controller.dart';

void main() {
  group('ThemeModeController', () {
    late InMemoryLocalStorage storage;
    late ProviderContainer container;

    setUp(() {
      storage = InMemoryLocalStorage();
      container = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);
    });

    test('given no stored value, defaults to dark', () {
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('given a stored value, restores it on build', () async {
      await storage.put(StorageBox.settings, StorageKeys.themeMode, 'light');
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('given an unknown stored value, falls back to dark', () async {
      await storage.put(StorageBox.settings, StorageKeys.themeMode, 'neon');
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('setMode updates state and persists the choice', () async {
      await container
          .read(themeModeProvider.notifier)
          .setMode(ThemeMode.system);

      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(
        storage.get<String>(StorageBox.settings, StorageKeys.themeMode),
        'system',
      );
    });
  });
}
