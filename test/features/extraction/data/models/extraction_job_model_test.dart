import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/features/extraction/data/models/extraction_job_model.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_job.dart';
import 'package:posely_ai/features/extraction/domain/entities/extraction_status.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';

void main() {
  group('ExtractionJobModel', () {
    const samplePoseModel = PoseModel(
      id: 'pose_123',
      name: 'Warrior II',
      previewUrl: 'https://example.com/preview.jpg',
      overlayUrl: 'https://example.com/overlay.png',
      categoryId: 'yoga',
    );

    test('deserializes JSON with completed status and result field', () {
      final json = <String, dynamic>{
        'id': 'job_001',
        'status': 'completed',
        'progress': 1.0,
        'error_message': null,
        'created_at': '2026-08-02T10:00:00.000Z',
        'updated_at': '2026-08-02T10:01:00.000Z',
        'result': {
          'id': 'pose_123',
          'name': 'Warrior II',
          'preview_url': 'https://example.com/preview.jpg',
          'overlay_url': 'https://example.com/overlay.png',
          'category_id': 'yoga',
        },
      };

      final model = ExtractionJobModel.fromJson(json);

      expect(model.id, equals('job_001'));
      expect(model.status, equals(ExtractionStatus.completed));
      expect(model.progress, equals(1.0));
      expect(model.result, equals(samplePoseModel));
      expect(model.errorMessage, isNull);
      expect(model.createdAt, equals(DateTime.parse('2026-08-02T10:00:00.000Z')));
    });

    test('deserializes JSON with pose field instead of result field', () {
      final json = <String, dynamic>{
        'id': 'job_002',
        'status': 'completed',
        'progress': 1.0,
        'pose': {
          'id': 'pose_123',
          'name': 'Warrior II',
          'preview_url': 'https://example.com/preview.jpg',
          'overlay_url': 'https://example.com/overlay.png',
          'category_id': 'yoga',
        },
      };

      final model = ExtractionJobModel.fromJson(json);

      expect(model.id, equals('job_002'));
      expect(model.status, equals(ExtractionStatus.completed));
      expect(model.result, equals(samplePoseModel));
    });

    test('deserializes JSON with failed status and errorMessage', () {
      final json = <String, dynamic>{
        'id': 'job_003',
        'status': 'failed',
        'progress': 0.5,
        'error_message': 'No person detected in the photo',
      };

      final model = ExtractionJobModel.fromJson(json);

      expect(model.id, equals('job_003'));
      expect(model.status, equals(ExtractionStatus.failed));
      expect(model.errorMessage, equals('No person detected in the photo'));
      expect(model.result, isNull);
    });

    test('serializes to JSON correctly', () {
      const model = ExtractionJobModel(
        id: 'job_004',
        status: ExtractionStatus.processing,
        progress: 0.4,
      );

      final json = model.toJson();

      expect(json['id'], equals('job_004'));
      expect(json['status'], equals('processing'));
      expect(json['progress'], equals(0.4));
    });

    test('toEntity converts model to ExtractionJob domain entity', () {
      const model = ExtractionJobModel(
        id: 'job_005',
        status: ExtractionStatus.completed,
        progress: 1.0,
        result: samplePoseModel,
      );

      final entity = model.toEntity();

      expect(entity, isA<ExtractionJob>());
      expect(entity.id, equals('job_005'));
      expect(entity.status, equals(ExtractionStatus.completed));
      expect(entity.result, equals(samplePoseModel.toEntity()));
    });
  });
}
