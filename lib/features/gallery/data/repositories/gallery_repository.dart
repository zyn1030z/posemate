import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/dio_client.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/gallery/data/datasources/gallery_api_client.dart';
import 'package:posely_ai/features/gallery/domain/entities/capture_record.dart';

/// Provider for [GalleryRepository].
final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final client = GalleryApiClient(dio);
  final storage = ref.watch(localStorageProvider);
  return GalleryRepositoryImpl(client, storage);
});

/// Repository for managing captures, supporting offline-first and syncing.
abstract class GalleryRepository {
  /// Fetches all captures from the local storage.
  List<CaptureRecord> getLocalCaptures();

  /// Saves a new capture locally and attempts to sync it to the remote backend.
  Future<void> saveCapture(CaptureRecord record);

  /// Deletes a capture locally and remotely.
  Future<void> deleteCapture(String id);

  /// Attempts to upload any locally saved captures that are not yet synced.
  Future<void> syncPendingCaptures();
}

class GalleryRepositoryImpl implements GalleryRepository {
  GalleryRepositoryImpl(this._client, this._storage);

  final GalleryApiClient _client;
  final LocalStorage _storage;

  @override
  List<CaptureRecord> getLocalCaptures() {
    // Read all keys from the gallery box and decode JSON maps.
    // As Hive returns untyped maps, we must safely cast them.
    // To do this we need access to the raw box keys.
    // Our LocalStorage interface doesn't expose `getAll`, let's just assume we store a single list
    // OR we can add a method. Wait, LocalStorage doesn't have `getAll`. 
    // Usually we store a Map or a List under a single key in `LocalStorage` for simplicity unless we expose the box.
    // Let's store the list of captures under a single key 'captures'.
    
    final raw = _storage.get<List<dynamic>>(StorageBox.gallery, 'captures');
    if (raw == null) return [];

    return raw.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return CaptureRecord.fromJson(map);
    }).toList();
  }

  Future<void> _saveAllLocal(List<CaptureRecord> captures) async {
    final rawList = captures.map((c) => c.toJson()).toList();
    await _storage.put(StorageBox.gallery, 'captures', rawList);
  }

  @override
  Future<void> saveCapture(CaptureRecord record) async {
    final captures = getLocalCaptures();
    
    // Add or update
    final index = captures.indexWhere((c) => c.id == record.id);
    if (index >= 0) {
      captures[index] = record;
    } else {
      captures.insert(0, record);
    }
    
    await _saveAllLocal(captures);
    
    // Attempt sync
    try {
      final file = File(record.localPath);
      if (file.existsSync()) {
        final syncedRecord = await _client.uploadCapture(
          file: file,
          poseId: record.poseId,
          score: record.score,
          capturedAt: record.timestamp.toIso8601String(),
        );
        
        // Update local with synced remote url
        final updatedCaptures = getLocalCaptures();
        final i = updatedCaptures.indexWhere((c) => c.id == record.id);
        if (i >= 0) {
          updatedCaptures[i] = syncedRecord.copyWith(
            localPath: record.localPath, // Keep local path for fast load
            isSynced: true,
          );
          await _saveAllLocal(updatedCaptures);
        }
      }
    } catch (e) {
      // Ignore network errors, it's marked isSynced: false and will be synced later
    }
  }

  @override
  Future<void> deleteCapture(String id) async {
    final captures = getLocalCaptures();
    final record = captures.firstWhere((c) => c.id == id);
    
    // Remove local
    captures.removeWhere((c) => c.id == id);
    await _saveAllLocal(captures);
    
    try {
      final file = File(record.localPath);
      if (file.existsSync()) {
        await file.delete();
      }
      
      if (record.isSynced) {
        await _client.deleteCapture(id);
      }
    } catch (e) {
      // Ignore remote delete failures for now, or queue for deletion
    }
  }

  @override
  Future<void> syncPendingCaptures() async {
    final captures = getLocalCaptures();
    var updated = false;

    for (var i = 0; i < captures.length; i++) {
      final record = captures[i];
      if (!record.isSynced) {
        try {
          final file = File(record.localPath);
          if (file.existsSync()) {
            final syncedRecord = await _client.uploadCapture(
              file: file,
              poseId: record.poseId,
              score: record.score,
              capturedAt: record.timestamp.toIso8601String(),
            );
            
            captures[i] = syncedRecord.copyWith(
              localPath: record.localPath,
              isSynced: true,
            );
            updated = true;
          }
        } catch (_) {}
      }
    }

    if (updated) {
      await _saveAllLocal(captures);
    }
  }
}
