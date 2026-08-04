import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/gallery/data/datasources/gallery_api_client.dart';
import 'package:posely_ai/features/gallery/data/repositories/gallery_repository.dart';
import 'package:posely_ai/features/gallery/domain/entities/capture_record.dart';

class MockGalleryApiClient extends Mock implements GalleryApiClient {}
class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late MockGalleryApiClient mockClient;
  late MockLocalStorage mockStorage;
  late GalleryRepositoryImpl repository;

  setUp(() {
    mockClient = MockGalleryApiClient();
    mockStorage = MockLocalStorage();
    repository = GalleryRepositoryImpl(mockClient, mockStorage);
    
    registerFallbackValue(StorageBox.gallery);
  });

  test('getLocalCaptures parses json list from storage safely', () {
    when(() => mockStorage.get<List<dynamic>>(StorageBox.gallery, 'captures'))
        .thenReturn([
      {
        'id': 'test-1',
        'local_path': '/path/1.jpg',
        'timestamp': '2026-08-04T12:00:00Z',
        'is_synced': false,
      }
    ]);

    final captures = repository.getLocalCaptures();
    expect(captures.length, 1);
    expect(captures.first.id, 'test-1');
    expect(captures.first.isSynced, false);
  });
}
