import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/gallery/data/repositories/gallery_repository.dart';
import 'package:posely_ai/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:posely_ai/features/gallery/domain/entities/capture_record.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}

void main() {
  late MockGalleryRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockGalleryRepository();
    container = ProviderContainer(
      overrides: [
        galleryRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('GalleryController fetches local captures and triggers background sync on init', () async {
    final mockRecord = CaptureRecord(
      id: '1',
      localPath: '/test/path.jpg',
      timestamp: DateTime.now(),
    );

    when(() => mockRepo.getLocalCaptures()).thenReturn([mockRecord]);
    when(() => mockRepo.syncPendingCaptures()).thenAnswer((_) async {});

    final sub = container.listen(galleryControllerProvider, (_, __) {});
    
    // Initial state is loading, wait for build to complete
    final captures = await container.read(galleryControllerProvider.future);
    
    expect(captures, isNotEmpty);
    expect(captures.first.id, '1');
    
    verify(() => mockRepo.getLocalCaptures()).called(greaterThanOrEqualTo(1));
    verify(() => mockRepo.syncPendingCaptures()).called(1);
    
    sub.close();
  });
}
