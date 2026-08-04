import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/camera/domain/entities/pose_score.dart';

/// A mocked isolate-like service that provides a real-time stream of PoseScores.
/// In production, this would spawn a dart Isolate to run ML Kit calculations.
class PoseMatcherIsolate {
  final _scoreController = StreamController<PoseScore>.broadcast();
  Timer? _timer;
  final _random = Random();
  double _currentMatch = 0.5; // Start at 50% match

  Stream<PoseScore> get scoreStream => _scoreController.stream;

  /// Starts the mocked pose matching engine.
  void start() {
    _timer?.cancel();
    _currentMatch = 0.5;
    
    // Emit a new score every 100ms (10fps simulation)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      // Drift towards 1.0 slowly with some random noise
      _currentMatch += (_random.nextDouble() * 0.05) - 0.01;
      _currentMatch = _currentMatch.clamp(0.0, 1.0);
      
      final score = PoseScore(
        matchPercentage: _currentMatch,
        bodyBalance: 0.8 + (_random.nextDouble() * 0.2),
        feedback: _generateFeedback(_currentMatch),
      );
      
      _scoreController.add(score);
    });
  }

  /// Stops the matching engine.
  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    stop();
    _scoreController.close();
  }

  List<String> _generateFeedback(double match) {
    if (match > 0.95) return ['Hold it!', 'Perfect!'];
    if (match > 0.8) return ['Almost there', 'Keep steady'];
    return ['Adjust your arms', 'Move closer to the outline'];
  }
}

/// Provider for the PoseMatcherIsolate.
final poseMatcherProvider = Provider<PoseMatcherIsolate>((ref) {
  final matcher = PoseMatcherIsolate();
  ref.onDispose(matcher.dispose);
  return matcher;
});
