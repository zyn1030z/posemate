import 'dart:convert';

import 'package:posely_ai/core/storage/local_storage.dart';

/// Simple cache-aside layer backed by the `posely_cache` Hive box.
///
/// Values are serialized as JSON with a timestamp; reads check TTL before
/// returning. The cache box can be cleared any time without data loss.
class CacheService {
  /// Creates the service with the given storage.
  const CacheService(this._storage);

  final LocalStorage _storage;

  /// Default time-to-live for cache entries.
  static const Duration defaultTtl = Duration(minutes: 15);

  /// Reads a cached value if it exists and has not expired.
  ///
  /// Returns null when the key is absent, corrupt, or stale.
  Map<String, dynamic>? get(String key) {
    final raw = _storage.get<String>(StorageBox.cache, key);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final ts = decoded['_ts'] as int?;
      if (ts == null) {
        return null;
      }
      final age = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(ts));
      if (age > defaultTtl) {
        // Stale — clean up lazily.
        _storage.delete(StorageBox.cache, key);
        return null;
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        return null;
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Writes a value to the cache with the current timestamp.
  Future<void> put(String key, Map<String, dynamic> value) {
    final envelope = <String, dynamic>{
      '_ts': DateTime.now().millisecondsSinceEpoch,
      'data': value,
    };
    return _storage.put(StorageBox.cache, key, jsonEncode(envelope));
  }

  /// Removes a single cache entry.
  Future<void> evict(String key) => _storage.delete(StorageBox.cache, key);

  /// Clears the entire cache.
  Future<void> clear() => _storage.clear(StorageBox.cache);
}
