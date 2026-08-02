import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Logical storage compartments, each backed by its own Hive box.
///
/// Separate boxes let unrelated data be cleared independently — wiping the
/// response cache must never touch user settings or pose history.
enum StorageBox {
  /// User preferences: theme, onboarding flags, feature toggles.
  settings('posely_settings'),

  /// Short-lived cached API responses; safe to clear at any time.
  cache('posely_cache'),

  /// Pose usage data: favorites and recently used pose ids.
  poses('posely_poses');

  const StorageBox(this.boxName);

  /// The on-disk Hive box name backing this compartment.
  final String boxName;
}

/// Key-value persistence for small, non-sensitive app data.
///
/// Reads are synchronous so widgets and providers can hydrate initial state
/// without a loading frame; writes are asynchronous. Secrets never belong
/// here — use `SecureTokenStorage` for anything sensitive.
abstract interface class LocalStorage {
  /// Reads the value for the key, or the default when the key is absent or
  /// the stored value does not have the requested type.
  T? get<T>(StorageBox box, String key, {T? defaultValue});

  /// Writes the value for the key, overwriting any previous value.
  Future<void> put(StorageBox box, String key, Object? value);

  /// Removes the key, doing nothing when it is absent.
  Future<void> delete(StorageBox box, String key);

  /// Removes every entry in the box.
  Future<void> clear(StorageBox box);

  /// Whether the box currently holds a value for the key.
  bool contains(StorageBox box, String key);
}

/// Hive-backed implementation used on devices.
class HiveLocalStorage implements LocalStorage {
  HiveLocalStorage._(this._boxes);

  final Map<StorageBox, Box<dynamic>> _boxes;

  /// Initializes Hive in the app documents directory and opens every box.
  ///
  /// Call once during bootstrap, before the provider container is created,
  /// then inject the instance by overriding `localStorageProvider`.
  static Future<HiveLocalStorage> init() async {
    await Hive.initFlutter();
    final boxes = <StorageBox, Box<dynamic>>{};
    for (final box in StorageBox.values) {
      boxes[box] = await Hive.openBox<dynamic>(box.boxName);
    }
    return HiveLocalStorage._(boxes);
  }

  Box<dynamic> _boxFor(StorageBox box) {
    final opened = _boxes[box];
    if (opened == null) {
      throw StateError(
        'Box "${box.boxName}" is not open — was HiveLocalStorage.init() '
        'awaited during bootstrap?',
      );
    }
    return opened;
  }

  @override
  T? get<T>(StorageBox box, String key, {T? defaultValue}) {
    final Object? value = _boxFor(box).get(key);
    if (value is T) {
      return value;
    }
    // Absent key or stored type drifted (e.g. after a schema change):
    // fail soft with the default instead of throwing a cast error.
    return defaultValue;
  }

  @override
  Future<void> put(StorageBox box, String key, Object? value) =>
      _boxFor(box).put(key, value);

  @override
  Future<void> delete(StorageBox box, String key) => _boxFor(box).delete(key);

  @override
  Future<void> clear(StorageBox box) async {
    await _boxFor(box).clear();
  }

  @override
  bool contains(StorageBox box, String key) =>
      _boxFor(box).containsKey(key);
}

/// Map-backed implementation for widget tests and tooling.
///
/// Behaves like the Hive implementation — including the type-mismatch
/// fallback in reads — without touching the file system.
class InMemoryLocalStorage implements LocalStorage {
  /// Creates an empty in-memory store.
  InMemoryLocalStorage();

  final Map<StorageBox, Map<String, Object?>> _data = {
    for (final box in StorageBox.values) box: <String, Object?>{},
  };

  @override
  T? get<T>(StorageBox box, String key, {T? defaultValue}) {
    final value = _data[box]![key];
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  @override
  Future<void> put(StorageBox box, String key, Object? value) async {
    _data[box]![key] = value;
  }

  @override
  Future<void> delete(StorageBox box, String key) async {
    _data[box]!.remove(key);
  }

  @override
  Future<void> clear(StorageBox box) async {
    _data[box]!.clear();
  }

  @override
  bool contains(StorageBox box, String key) => _data[box]!.containsKey(key);
}

/// Provides the app-wide local storage.
///
/// Must be overridden during bootstrap with the awaited result of
/// `HiveLocalStorage.init()`; tests can override with `InMemoryLocalStorage`.
final localStorageProvider = Provider<LocalStorage>(
  (ref) => throw UnimplementedError(
    'localStorageProvider must be overridden in bootstrap()',
  ),
);
