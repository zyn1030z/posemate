/// URL paths for every screen Posely AI will ever navigate to.
///
/// All planned screens have a path reserved from Phase 1 so deep-link
/// contracts stay stable as features land; only splash and home are wired
/// into the router today.
abstract final class RoutePaths {
  /// Splash screen shown while the app boots.
  static const String splash = '/splash';

  /// First-run onboarding carousel.
  static const String onboarding = '/onboarding';

  /// Email / social login screen.
  static const String login = '/login';

  /// Account registration screen.
  static const String register = '/register';

  /// Password recovery screen.
  static const String forgotPassword = '/forgot-password';

  /// Main landing shell after startup.
  static const String home = '/home';

  /// Global search across poses, collections and creators.
  static const String search = '/search';

  /// Browsable pose library.
  static const String poseLibrary = '/poses';

  /// Pose detail pattern with a `poseId` parameter; use the
  /// poseDetailFor helper to build a concrete location.
  static const String poseDetail = '/poses/:poseId';

  /// AI pose generator.
  static const String poseGenerator = '/generate';

  /// Upload a custom reference pose.
  static const String uploadPose = '/upload';

  /// Realtime AI coaching camera.
  static const String camera = '/camera';

  /// Captured photos gallery.
  static const String gallery = '/gallery';

  /// Gallery photo detail pattern with a `photoId` parameter; use the
  /// galleryPhotoFor helper to build a concrete location.
  static const String galleryPhoto = '/gallery/:photoId';

  /// User-curated pose collections.
  static const String collections = '/collections';

  /// Community feed of shared shots and poses.
  static const String community = '/community';

  /// Current user's profile.
  static const String profile = '/profile';

  /// App settings.
  static const String settings = '/settings';

  /// Premium subscription paywall.
  static const String premium = '/premium';

  /// Notification center.
  static const String notifications = '/notifications';

  /// About the app: version, licenses, credits.
  static const String about = '/about';

  /// Feedback and support form.
  static const String feedback = '/feedback';

  /// Privacy policy.
  static const String privacy = '/privacy';

  /// Terms of service.
  static const String terms = '/terms';

  /// Dev-only design-system showcase; not linked in production UI.
  static const String designGallery = '/dev/design-gallery';

  /// Builds the concrete pose detail location for the given pose id.
  static String poseDetailFor(String poseId) => '/poses/$poseId';

  /// Helper to build a concrete gallery photo location.
  static String galleryPhotoFor(String id) => '/gallery/$id';

  /// Helper to build a concrete camera location with a target pose queue.
  static String cameraFor(List<String> poseIds) => '/camera?poseIds=${poseIds.join(',')}';
}

/// Named-route identifiers mirroring the paths in RoutePaths.
///
/// Prefer navigating by name (`context.goNamed`) once parameterized routes
/// land, so path shapes can evolve without touching call sites.
abstract final class RouteNames {
  /// Name of the splash route.
  static const String splash = 'splash';

  /// Name of the onboarding route.
  static const String onboarding = 'onboarding';

  /// Name of the login route.
  static const String login = 'login';

  /// Name of the registration route.
  static const String register = 'register';

  /// Name of the password recovery route.
  static const String forgotPassword = 'forgotPassword';

  /// Name of the home route.
  static const String home = 'home';

  /// Name of the search route.
  static const String search = 'search';

  /// Name of the pose library route.
  static const String poseLibrary = 'poseLibrary';

  /// Name of the pose detail route.
  static const String poseDetail = 'poseDetail';

  /// Name of the AI pose generator route.
  static const String poseGenerator = 'poseGenerator';

  /// Name of the custom pose upload route.
  static const String uploadPose = 'uploadPose';

  /// Name of the AI camera route.
  static const String camera = 'camera';

  /// Name of the gallery route.
  static const String gallery = 'gallery';

  /// Name of the gallery photo detail route.
  static const String galleryPhoto = 'galleryPhoto';

  /// Name of the collections route.
  static const String collections = 'collections';

  /// Name of the community route.
  static const String community = 'community';

  /// Name of the profile route.
  static const String profile = 'profile';

  /// Name of the settings route.
  static const String settings = 'settings';

  /// Name of the premium paywall route.
  static const String premium = 'premium';

  /// Name of the notifications route.
  static const String notifications = 'notifications';

  /// Name of the about route.
  static const String about = 'about';

  /// Name of the feedback route.
  static const String feedback = 'feedback';

  /// Name of the privacy policy route.
  static const String privacy = 'privacy';

  /// Name of the terms of service route.
  static const String terms = 'terms';

  /// Dev-only design-system showcase; not linked in production UI.
  static const String designGallery = 'designGallery';
}
