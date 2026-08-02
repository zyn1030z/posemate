/// Per-flavor backend endpoints for Posely AI.
///
/// These values are compile-time constants; the active pair is selected by
/// `AppConfig.forFlavor` based on the running flavor. Endpoints are versioned
/// under `/v1` — bump here (and only here) when the API contract revs.
abstract final class Env {
  // ── Dev ───────────────────────────────────────────────────────────

  /// REST base URL for the development backend.
  static const String devApiBaseUrl = 'https://api.dev.posely.app/v1';

  /// WebSocket base URL for the development realtime service.
  static const String devWsBaseUrl = 'wss://realtime.dev.posely.app/v1';

  // ── UAT ───────────────────────────────────────────────────────────

  /// REST base URL for the user-acceptance testing backend.
  static const String uatApiBaseUrl = 'https://api.uat.posely.app/v1';

  /// WebSocket base URL for the user-acceptance testing realtime service.
  static const String uatWsBaseUrl = 'wss://realtime.uat.posely.app/v1';

  // ── Production ────────────────────────────────────────────────────

  /// REST base URL for the production backend.
  static const String prodApiBaseUrl = 'https://api.posely.app/v1';

  /// WebSocket base URL for the production realtime service.
  static const String prodWsBaseUrl = 'wss://realtime.posely.app/v1';
}
