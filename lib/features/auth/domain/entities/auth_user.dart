import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// The signed-in (or guest) user as seen by the domain layer.
///
/// A pure entity: no wire-format concerns live here — mapping from the API
/// payload happens in the data layer via `AuthUserModel.toEntity`.
@freezed
abstract class AuthUser with _$AuthUser {
  /// Creates a user identity.
  const factory AuthUser({
    /// Opaque server-issued user identifier.
    required String id,

    /// Primary email address; empty for guest sessions.
    required String email,

    /// Name shown across the app.
    required String displayName,

    /// URL of the profile picture, when one is set.
    String? avatarUrl,

    /// Whether this identity is a local guest session without an account.
    @Default(false) bool isGuest,

    /// Whether the user holds an active premium subscription.
    @Default(false) bool isPremium,

    /// When the account was created, when known.
    DateTime? createdAt,
  }) = _AuthUser;

  /// The stable local identity used while browsing without an account.
  static AuthUser guest() => const AuthUser(
    id: 'guest',
    email: '',
    displayName: 'Guest',
    isGuest: true,
  );
}
