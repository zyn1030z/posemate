/// REST and WebSocket paths of the Posely AI backend contract.
///
/// All paths are relative to the flavor's base URL (which already contains
/// the `/v1` version segment) and start with a single leading slash, so they
/// can be passed directly to Dio configured with that base URL.
abstract final class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────

  /// Email/password sign-in.
  static const String login = '/auth/login';

  /// New account registration.
  static const String register = '/auth/register';

  /// Access-token refresh using a refresh token.
  static const String refresh = '/auth/refresh';

  /// Sign-out and server-side token revocation.
  static const String logout = '/auth/logout';

  /// Request a password-reset email.
  static const String forgotPassword = '/auth/forgot-password';

  /// Sign-in with a social identity provider (Google, Apple, Facebook).
  static const String socialLogin = '/auth/social-login';

  // ── Profile ───────────────────────────────────────────────────────

  /// The authenticated user's own profile.
  static const String me = '/profile/me';

  // ── Poses ─────────────────────────────────────────────────────────

  /// Pose library collection (list and create).
  static const String poses = '/poses';

  /// A single pose by its identifier.
  static String poseById(String id) => '/poses/$id';

  /// Pose category taxonomy.
  static const String categories = '/poses/categories';

  /// Poses currently trending across the community.
  static const String trending = '/poses/trending';

  /// Personalized pose recommendations for the current user.
  static const String recommended = '/poses/recommended';

  /// Full-text and filtered pose search.
  static const String search = '/poses/search';

  // ── AI ────────────────────────────────────────────────────────────

  /// Generate pose suggestions from a prompt or scene description.
  static const String generatePoses = '/ai/generate-poses';

  /// Extract a pose skeleton from an uploaded reference photo.
  static const String extractPose = '/ai/extract-pose';

  /// Realtime pose-scoring stream — a WebSocket path, resolved against the
  /// flavor's WebSocket base URL rather than the REST base URL.
  static const String poseScoreWs = '/ai/pose-score';

  // ── Collections ───────────────────────────────────────────────────

  /// The user's saved pose collections.
  static const String collections = '/collections';

  // ── Gallery ───────────────────────────────────────────────────────

  /// The user's captured photo gallery.
  static const String photos = '/gallery/photos';

  /// A single gallery photo by its identifier.
  static String photoById(String id) => '/gallery/photos/$id';

  // ── Community ─────────────────────────────────────────────────────

  /// The community activity feed.
  static const String feed = '/community/feed';

  /// Follow or unfollow another user.
  static String follow(String userId) => '/community/follow/$userId';

  /// Like or unlike a shared pose.
  static String like(String poseId) => '/community/poses/$poseId/like';

  /// Comments on a shared pose (list and create).
  static String comments(String poseId) => '/community/poses/$poseId/comments';

  // ── Premium ───────────────────────────────────────────────────────

  /// Available subscription products and pricing.
  static const String products = '/premium/products';

  /// Activate a subscription from a store purchase receipt.
  static const String subscribe = '/premium/subscribe';

  /// Restore previously purchased entitlements.
  static const String restore = '/premium/restore';
}
