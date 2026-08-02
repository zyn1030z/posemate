/// Application-wide constants that do not vary per flavor.
abstract final class AppConstants {
  /// Default number of items requested per page from list endpoints.
  static const int defaultPageSize = 20;

  /// Timeout for establishing an HTTP connection.
  static const Duration apiConnectTimeout = Duration(seconds: 15);

  /// Timeout for receiving an HTTP response body.
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  /// Maximum accepted size for user-uploaded images (10 MiB).
  static const int maxUploadImageBytes = 10 * 1024 * 1024;

  /// Support contact email shown in help and error screens.
  static const String supportEmail = 'support@posely.app';

  /// Public privacy policy page.
  static const String privacyPolicyUrl = 'https://posely.app/privacy';

  /// Public terms of service page.
  static const String termsUrl = 'https://posely.app/terms';

  /// App Store listing link used by share and update prompts.
  static const String appStoreUrl = 'https://posely.app/ios';

  /// Play Store listing link used by share and update prompts.
  static const String playStoreUrl = 'https://posely.app/android';

  /// Minimum time the splash screen stays visible, so branding never flashes.
  static const Duration minSplashDuration = Duration(milliseconds: 1600);
}
