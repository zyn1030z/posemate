import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';

/// Domain contract for authentication and session management.
///
/// Credential-backed flows return `ApiResult` because they cross the network;
/// purely local flows (guest mode, sign-out, session restore) return plain
/// futures and never throw.
abstract interface class AuthRepository {
  /// Signs in with an email/password pair and persists the session.
  Future<ApiResult<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account and signs the user in.
  Future<ApiResult<AuthUser>> register({
    required String displayName,
    required String email,
    required String password,
  });

  /// Requests a password-reset email for the given address.
  Future<ApiResult<void>> requestPasswordReset({required String email});

  /// Runs the native SDK flow for the provider, then exchanges the provider
  /// credential for a Posely session.
  ///
  /// A user-cancelled SDK flow surfaces as an `ApiFailure` carrying a
  /// `CancelledException`; screens should treat that failure silently.
  Future<ApiResult<AuthUser>> signInWithSocial(SocialProvider provider);

  /// Starts a local guest session without contacting the backend.
  Future<AuthUser> signInAsGuest();

  /// Clears the stored session; best-effort and never throws.
  Future<void> signOut();

  /// Restores the persisted session, or returns null when signed out.
  Future<AuthUser?> restoreSession();
}
