import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Provides the app-wide Talker logger.
///
/// Deliberately unimplemented here: the real instance is created with
/// `TalkerFlutter.init()` inside `bootstrap()` and injected by overriding
/// this provider on the root `ProviderScope`.
///
/// Override-at-root instead of construct-in-provider because the single
/// Talker instance must exist before the provider container does: it is
/// handed to `ProviderScope.observers` (Riverpod logging), to the router and
/// zone error handlers, and to crash reporting — all of which are wired
/// during bootstrap, outside any `ref`. Creating a second instance inside a
/// provider would split the log stream in two.
final talkerProvider = Provider<Talker>(
  (ref) => throw UnimplementedError(
    'talkerProvider must be overridden in bootstrap()',
  ),
);
