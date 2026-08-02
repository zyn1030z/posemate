import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/extraction/data/repositories/extraction_repository_impl.dart';
import 'package:posely_ai/features/extraction/presentation/controllers/extraction_controller.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';

class MockExtractionRepository extends Mock implements ExtractionRepository {}

class FakeFile extends Fake implements File {}

void main() {
  late MockExtractionRepository repository;
  late ProviderContainer container;
  late File fakeImage;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    repository = MockExtractionRepository();
    fakeImage = File('fake.png');
    container = ProviderContainer(
      overrides: [
        extractionRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const dummyPose = Pose(
    id: 'pose_1',
    name: 'Test Pose',
    previewUrl: 'preview',
    overlayUrl: 'overlay',
    categoryId: '1',
  );

  test('extractPose sets state to data on success', () async {
    when(() => repository.extractPose(any())).thenAnswer((_) async => dummyPose);

    final controller = container.read(extractionControllerProvider.notifier);
    
    // Initial state
    expect(container.read(extractionControllerProvider).value, isNull);

    final future = controller.extractPose(fakeImage);
    
    // Loading state
    expect(container.read(extractionControllerProvider).isLoading, isTrue);

    await future;

    // Data state
    expect(container.read(extractionControllerProvider).value, equals(dummyPose));
    verify(() => repository.extractPose(fakeImage)).called(1);
  });

  test('extractPose sets state to error on failure', () async {
    final exception = const NoPoseDetectedException();
    when(() => repository.extractPose(any())).thenThrow(exception);

    final controller = container.read(extractionControllerProvider.notifier);
    await controller.extractPose(fakeImage);

    final state = container.read(extractionControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, equals(exception));
    verify(() => repository.extractPose(fakeImage)).called(1);
  });
}
