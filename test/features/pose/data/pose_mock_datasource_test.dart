import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/pose/data/datasources/pose_mock_datasource.dart';

/// A tiny inline dataset so these tests exercise parsing, filtering, and
/// pagination without depending on the real bundled asset.
const String _fixture = '''
{
  "categories": [
    { "id": "beach", "name": "Beach", "emoji": "🏖️" },
    { "id": "cafe", "name": "Cafe", "emoji": "☕" }
  ],
  "poses": [
    { "id": "p1", "name": "Shoreline One", "preview_url": "https://example.com/p1.jpg", "overlay_url": "https://example.com/p1-ov.png", "tags": ["ocean"], "difficulty": "easy", "gender": "female", "ai_score": 4.1, "downloads": 500, "category_id": "beach" },
    { "id": "p2", "name": "Shoreline Two", "preview_url": "https://example.com/p2.jpg", "overlay_url": "https://example.com/p2-ov.png", "tags": ["ocean"], "difficulty": "medium", "gender": "female", "ai_score": 4.3, "downloads": 300, "category_id": "beach" },
    { "id": "p3", "name": "Latte One", "preview_url": "https://example.com/p3.jpg", "overlay_url": "https://example.com/p3-ov.png", "tags": ["coffee"], "difficulty": "easy", "gender": "any", "ai_score": 4.8, "downloads": 900, "category_id": "cafe" },
    { "id": "p4", "name": "Latte Two", "preview_url": "https://example.com/p4.jpg", "overlay_url": "https://example.com/p4-ov.png", "tags": ["coffee"], "difficulty": "hard", "gender": "male", "ai_score": 4.0, "downloads": 100, "category_id": "cafe" },
    { "id": "p5", "name": "Shoreline Three", "preview_url": "https://example.com/p5.jpg", "overlay_url": "https://example.com/p5-ov.png", "tags": ["ocean"], "difficulty": "easy", "gender": "couple", "ai_score": 4.5, "downloads": 700, "category_id": "beach" }
  ]
}
''';

void main() {
  late int loaderCalls;
  late PoseMockDatasource datasource;

  setUp(() {
    loaderCalls = 0;
    datasource = PoseMockDatasource(
      assetLoader: (_) async {
        loaderCalls++;
        return _fixture;
      },
      latency: () => Duration.zero,
    );
  });

  group('getCategories', () {
    test('parses every category from the dataset', () async {
      final categories = await datasource.getCategories();

      expect(categories, hasLength(2));
      expect(categories.first.id, 'beach');
      expect(categories.first.name, 'Beach');
      expect(categories.first.emoji, '🏖️');
    });

    test('loads and parses the asset only once across calls', () async {
      await datasource.getCategories();
      await datasource.getTrending();
      await datasource.getPoses(page: 1, pageSize: 2);

      expect(loaderCalls, 1);
    });
  });

  group('getPoses pagination', () {
    test('serves the first page with correct totals', () async {
      final page = await datasource.getPoses(page: 1, pageSize: 2);

      expect(page.items.map((pose) => pose.id), ['p1', 'p2']);
      expect(page.page, 1);
      expect(page.pageSize, 2);
      expect(page.totalItems, 5);
      expect(page.hasMore, isTrue);
    });

    test('serves a short final page with hasMore false', () async {
      final page = await datasource.getPoses(page: 3, pageSize: 2);

      expect(page.items.map((pose) => pose.id), ['p5']);
      expect(page.hasMore, isFalse);
    });

    test('serves a page beyond the end as empty with hasMore false', () async {
      final page = await datasource.getPoses(page: 4, pageSize: 2);

      expect(page.items, isEmpty);
      expect(page.totalItems, 5);
      expect(page.hasMore, isFalse);
    });
  });

  group('getPoses filters', () {
    test('filters by category', () async {
      final page = await datasource.getPoses(
        page: 1,
        pageSize: 10,
        categoryId: 'cafe',
      );

      expect(page.items.map((pose) => pose.id), ['p3', 'p4']);
      expect(page.totalItems, 2);
    });

    test('filters by difficulty', () async {
      final page = await datasource.getPoses(
        page: 1,
        pageSize: 10,
        difficulty: 'easy',
      );

      expect(page.items.map((pose) => pose.id), ['p1', 'p3', 'p5']);
    });

    test('combines category and difficulty filters', () async {
      final page = await datasource.getPoses(
        page: 1,
        pageSize: 10,
        categoryId: 'beach',
        difficulty: 'easy',
      );

      expect(page.items.map((pose) => pose.id), ['p1', 'p5']);
    });
  });

  group('getPoseById', () {
    test('returns the matching pose', () async {
      final pose = await datasource.getPoseById('p3');

      expect(pose.name, 'Latte One');
      expect(pose.categoryId, 'cafe');
    });

    test('throws NotFoundException for an unknown id', () {
      expect(
        () => datasource.getPoseById('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getTrending', () {
    test('returns poses sorted by downloads, highest first', () async {
      final trending = await datasource.getTrending();

      expect(
        trending.map((pose) => pose.id),
        ['p3', 'p5', 'p1', 'p2', 'p4'],
      );
    });
  });

  group('getRecommended', () {
    test('is deterministic across calls', () async {
      final first = await datasource.getRecommended();
      final second = await datasource.getRecommended();

      expect(
        first.map((pose) => pose.id),
        second.map((pose) => pose.id),
      );
      expect(first, hasLength(5));
    });
  });
}
