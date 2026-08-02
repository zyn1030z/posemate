import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/storage/local_storage.dart';

/// Controls the app-wide theme mode and persists the choice.
///
/// Dark is the flagship Posely AI experience and the default for first
/// launches; the user's explicit choice is stored in the settings box and
/// restored on startup.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref
        .watch(localStorageProvider)
        .get<String>(StorageBox.settings, StorageKeys.themeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  /// Applies and persists the given theme mode.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(localStorageProvider)
        .put(StorageBox.settings, StorageKeys.themeMode, mode.name);
  }
}

/// App-wide theme mode, persisted across launches.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
