import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/features/camera/data/services/pose_matcher_isolate.dart';
import 'package:posely_ai/features/camera/domain/entities/pose_score.dart';

void main() {
  group('PoseMatcherIsolate', () {
    late PoseMatcherIsolate matcher;

    setUp(() {
      matcher = PoseMatcherIsolate();
    });

    tearDown(() {
      matcher.dispose();
    });

    test('emits PoseScores when started', () async {
      matcher.start();
      
      final firstScore = await matcher.scoreStream.first;
      
      expect(firstScore, isA<PoseScore>());
      expect(firstScore.matchPercentage, greaterThanOrEqualTo(0.0));
      expect(firstScore.matchPercentage, lessThanOrEqualTo(1.0));
      
      matcher.stop();
    });
  });
}
