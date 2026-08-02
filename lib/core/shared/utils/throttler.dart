import 'dart:async';

import 'package:flutter/foundation.dart';

/// Leading-edge throttle: the first call fires immediately, then further
/// calls are ignored until the interval has elapsed.
///
/// Typical use: rate-limiting realtime pose-coaching feedback or scroll
/// handlers where the first event matters and repeats add nothing.
class Throttler {
  /// Creates a throttler with the given minimum interval between calls.
  Throttler({required this.interval});

  /// Minimum time between two accepted run calls.
  final Duration interval;

  Timer? _cooldown;

  /// Whether the throttler is cooling down and currently ignoring calls.
  bool get isThrottled => _cooldown?.isActive ?? false;

  /// Invokes the action immediately unless the throttler is cooling down.
  void run(VoidCallback action) {
    if (isThrottled) return;
    action();
    _cooldown = Timer(interval, _clear);
  }

  void _clear() {
    _cooldown = null;
  }

  /// Releases resources; call from the owner's dispose method.
  void dispose() {
    _cooldown?.cancel();
    _cooldown = null;
  }
}
