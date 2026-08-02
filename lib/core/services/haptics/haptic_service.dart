import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Semantic wrapper around `HapticFeedback` so features trigger intent
/// (light, success, …) instead of raw platform calls.
///
/// Centralizing haptics keeps patterns consistent app-wide and gives one
/// seam for a future user setting that disables them.
class HapticService {
  /// Creates a haptic service.
  const HapticService();

  /// Gap between the two pulses of the success pattern.
  static const Duration _successGap = Duration(milliseconds: 40);

  /// Plays a light impact — taps, chip toggles, minor confirmations.
  Future<void> light() => HapticFeedback.lightImpact();

  /// Plays a medium impact — primary actions, capture triggers.
  Future<void> medium() => HapticFeedback.mediumImpact();

  /// Plays a heavy impact — destructive or high-emphasis moments.
  Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Plays a selection tick — pickers, sliders, segmented controls.
  Future<void> selection() => HapticFeedback.selectionClick();

  /// Plays the success pattern: a light pulse followed by a medium pulse
  /// after a short gap. Used for pose matches and completed captures.
  Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(_successGap);
    await HapticFeedback.mediumImpact();
  }
}

/// Provides the shared HapticService instance.
final hapticServiceProvider = Provider<HapticService>(
  (ref) => const HapticService(),
);
