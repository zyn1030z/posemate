/// Bundled asset locations.
///
/// Only assets actually referenced by code are listed here; the class grows
/// phase by phase as new screens land. Roots mirror the folders declared
/// under the `assets` section of `pubspec.yaml`.
abstract final class AssetPaths {
  /// Root folder for raster images.
  static const String imagesRoot = 'assets/images';

  /// Root folder for SVG and raster icons.
  static const String iconsRoot = 'assets/icons';

  /// Root folder for Lottie animation files.
  static const String lottieRoot = 'assets/lottie';

  /// Root folder for bundled mock JSON payloads (dev flavor only).
  static const String mockRoot = 'assets/mock';

  /// Generic loading animation shown while content is being fetched.
  static const String lottieLoading = 'assets/lottie/loading.json';

  /// Mock pose library served when `AppConfig.useMockData` is enabled.
  static const String mockPoses = 'assets/mock/poses.json';
}
