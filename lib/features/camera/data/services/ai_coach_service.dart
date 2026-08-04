import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:posely_ai/features/camera/domain/entities/ai_coach.dart';

/// Wraps flutter_tts to provide AI coach voice feedback.
class AiCoachService {
  final FlutterTts _tts = FlutterTts();
  AiCoach? _currentCoach;
  bool _isSpeaking = false;
  DateTime _lastSpokeAt = DateTime.now().subtract(const Duration(seconds: 10));

  /// Initializes the service with an optional coach profile.
  Future<void> initialize(AiCoach coach) async {
    _currentCoach = coach;
    await _tts.setPitch(coach.voicePitch);
    await _tts.setSpeechRate(coach.voiceRate);
    
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  /// Speaks a given text if the coach is not currently speaking and cooldown has passed.
  /// 
  /// [force] overrides the cooldown (useful for critical alerts like "Perfect!").
  Future<void> speak(String text, {bool force = false}) async {
    if (_currentCoach == null) return;
    if (_isSpeaking && !force) return;

    final now = DateTime.now();
    // 3 second cooldown for normal chatter
    if (!force && now.difference(_lastSpokeAt).inSeconds < 3) {
      return;
    }

    if (force) {
      await _tts.stop(); // Interrupt current speech
    }

    _isSpeaking = true;
    _lastSpokeAt = now;
    await _tts.speak(text);
  }

  /// Stops any ongoing speech.
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}

/// Provider for the AI Coach TTS service.
final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  final service = AiCoachService();
  ref.onDispose(service.stop);
  return service;
});
