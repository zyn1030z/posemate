/// Canonical keys for values persisted in local and secure storage.
///
/// Keys are namespaced with a dotted prefix (`auth.`, `app.`, `pose.`) so
/// unrelated features never collide and bulk cleanup by prefix stays possible.
abstract final class StorageKeys {
  /// Secure-storage key for the OAuth access token.
  static const String accessToken = 'auth.access_token';

  /// Secure-storage key for the OAuth refresh token.
  static const String refreshToken = 'auth.refresh_token';

  /// Local-storage key for the signed-in user's profile snapshot, stored as
  /// a JSON map so the session can be restored without a network call.
  static const String authUserProfile = 'auth.user_profile';

  /// Local-storage key flagging an active guest session (no tokens issued).
  static const String authIsGuest = 'auth.is_guest';

  /// Local-storage key for the user's biometric app-lock preference.
  static const String biometricLock = 'auth.biometric_lock';

  /// Whether the user has completed the onboarding flow.
  static const String onboardingComplete = 'app.onboarding_complete';

  /// The user's preferred theme mode (system, light, or dark).
  static const String themeMode = 'app.theme_mode';

  /// Recently used pose ids, most recent first.
  static const String lastUsedPoseIds = 'pose.last_used_ids';

  /// Pose ids the user has marked as favorites.
  static const String favoritePoseIds = 'pose.favorite_ids';
}
