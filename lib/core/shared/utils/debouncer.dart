import 'dart:async';

import 'package:flutter/foundation.dart';

/// Collapses a burst of calls into a single trailing invocation.
///
/// Every call to run restarts the timer; the most recent action fires once
/// the delay elapses with no further calls. Typical use: search-as-you-type
/// fields that should hit the API only after the user pauses.
class Debouncer {
  /// Creates a debouncer with the given trailing delay.
  Debouncer({required this.delay});

  /// How long the debouncer waits after the last run call before firing.
  final Duration delay;

  Timer? _timer;

  /// Whether a call is currently scheduled and has not fired yet.
  bool get isPending => _timer?.isActive ?? false;

  /// Schedules the action, replacing any previously scheduled one.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels the pending action, if any, without firing it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Releases resources; call from the owner's dispose method.
  void dispose() => cancel();
}
