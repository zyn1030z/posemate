import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/env.dart';
import 'package:posely_ai/core/config/flavor.dart';

/// Immutable runtime configuration for the app, derived from the build flavor.
///
/// A single instance is created in `bootstrap` and injected into the widget
/// tree by overriding `appConfigProvider` on the root `ProviderScope`.
class AppConfig {
  /// Creates a configuration with explicit values.
  ///
  /// Prefer `AppConfig.forFlavor` in application code; this constructor is
  /// public mainly so tests can build tailor-made configurations.
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.enableFirebase,
    required this.useMockData,
    required this.showDebugBanner,
  });

  /// Builds the canonical configuration for the given build flavor.
  factory AppConfig.forFlavor(Flavor flavor) => switch (flavor) {
    Flavor.dev => const AppConfig(
      flavor: Flavor.dev,
      appName: 'Posely AI Dev',
      apiBaseUrl: Env.devApiBaseUrl,
      wsBaseUrl: Env.devWsBaseUrl,
      enableFirebase: false,
      useMockData: true,
      showDebugBanner: true,
    ),
    Flavor.uat => const AppConfig(
      flavor: Flavor.uat,
      appName: 'Posely AI UAT',
      apiBaseUrl: Env.uatApiBaseUrl,
      wsBaseUrl: Env.uatWsBaseUrl,
      enableFirebase: false,
      useMockData: false,
      showDebugBanner: true,
    ),
    Flavor.prod => const AppConfig(
      flavor: Flavor.prod,
      appName: 'Posely AI',
      apiBaseUrl: Env.prodApiBaseUrl,
      wsBaseUrl: Env.prodWsBaseUrl,
      // PHASE-15: flip to true once firebase_options are generated per flavor.
      enableFirebase: false,
      useMockData: false,
      showDebugBanner: false,
    ),
  };

  /// The build flavor this configuration was created for.
  final Flavor flavor;

  /// Display name of the app for this flavor.
  final String appName;

  /// Base URL for REST API calls, including the version segment.
  final String apiBaseUrl;

  /// Base URL for WebSocket connections, including the version segment.
  final String wsBaseUrl;

  /// Whether Firebase services (Crashlytics, Analytics, …) are initialized.
  final bool enableFirebase;

  /// Whether repositories should serve bundled mock data instead of the API.
  final bool useMockData;

  /// Whether to show an on-screen flavor banner in non-production builds.
  final bool showDebugBanner;
}

/// Provides the active `AppConfig`.
///
/// Must be overridden with a concrete value on the root `ProviderScope`
/// during `bootstrap`; reading it without an override is a programming error.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(
    'appConfigProvider must be overridden in bootstrap()',
  ),
);
