import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reports whether the device has any network transport available.
///
/// Wraps connectivity_plus 7.x, whose APIs report a list of simultaneously
/// active transports (for example wifi and vpn together). The device counts
/// as online when at least one reported transport is not
/// `ConnectivityResult.none`. Note this checks transport availability, not
/// actual internet reachability — a captive portal still counts as online.
class ConnectivityService {
  /// Creates the service.
  ///
  /// A custom `Connectivity` can be injected for tests; production code uses
  /// the platform singleton.
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  /// Emits true or false as the device gains or loses connectivity.
  ///
  /// Consecutive duplicate values are suppressed, so listeners only react to
  /// actual online/offline transitions.
  Stream<bool> get isOnlineStream =>
      _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  /// Checks current connectivity once.
  Future<bool> get isOnline async =>
      _hasConnection(await _connectivity.checkConnectivity());
}

/// Provides the app-wide connectivity service.
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

/// Streams the device's online state as it changes.
///
/// Watch this from UI to show offline banners, or read it before firing
/// requests that should fail fast when offline.
final isOnlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).isOnlineStream,
);
