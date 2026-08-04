import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/features/camera/data/services/ai_coach_service.dart';
import 'package:posely_ai/features/camera/data/services/pose_matcher_isolate.dart';
import 'package:posely_ai/features/camera/domain/entities/pose_score.dart';
import 'package:posely_ai/features/camera/presentation/controllers/camera_session_controller.dart';

/// Overlay HUD displaying the realtime AI Coach feedback and score.
class AiCoachHud extends ConsumerStatefulWidget {
  final String coachId;
  const AiCoachHud({super.key, required this.coachId});

  @override
  ConsumerState<AiCoachHud> createState() => _AiCoachHudState();
}

class _AiCoachHudState extends ConsumerState<AiCoachHud> {
  StreamSubscription<PoseScore>? _scoreSub;
  double _currentScore = 0.0;
  DateTime? _highScoreStartTime;

  @override
  void initState() {
    super.initState();
    // Start matching and wire up AI coach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(poseMatcherProvider).start();
      _listenToScore();
    });
  }

  void _listenToScore() {
    _scoreSub = ref.read(poseMatcherProvider).scoreStream.listen((score) {
      if (!mounted) return;

      setState(() {
        _currentScore = score.matchPercentage;
      });

      // Pass feedback to TTS
      if (score.feedback.isNotEmpty) {
        final text = score.feedback.last;
        ref.read(aiCoachServiceProvider).speak(text, force: score.matchPercentage > 0.95);
      }

      // Auto-capture logic
      if (score.matchPercentage > 0.95) {
        _highScoreStartTime ??= DateTime.now();
        if (DateTime.now().difference(_highScoreStartTime!).inSeconds >= 2) {
          // Trigger capture
          ref.read(cameraSessionControllerProvider.notifier).takePicture();
          // Reset so we don't spam captures
          _highScoreStartTime = null; 
        }
      } else {
        _highScoreStartTime = null;
      }
    });
  }

  @override
  void dispose() {
    _scoreSub?.cancel();
    // The provider's onDispose will stop the isolate, but we can call stop here too.
    ref.read(poseMatcherProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140, // Above bottom controls
      left: 16,
      child: Row(
        children: [
          ScoreRing(
            score: _currentScore,
            size: 80,
            label: 'Match',
          ),
          const SizedBox(width: 16),
          // Additional stats could go here (e.g. ScorePill)
        ],
      ),
    );
  }
}
