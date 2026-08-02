import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

/// Wire model for the user object returned by the auth endpoints.
///
/// Keys arrive in snake_case and are renamed automatically by the global
/// json_serializable configuration, so no per-field annotations are needed.
@freezed
abstract class AuthUserModel with _$AuthUserModel {
  /// Creates the wire model.
  const factory AuthUserModel({
    /// Opaque server-issued user identifier.
    required String id,

    /// Primary email address of the account.
    required String email,

    /// Name shown across the app.
    required String displayName,

    /// URL of the profile picture, when one is set.
    String? avatarUrl,

    /// Whether the user holds an active premium subscription.
    @Default(false) bool isPremium,

    /// When the account was created, when the server includes it.
    DateTime? createdAt,
  }) = _AuthUserModel;

  const AuthUserModel._();

  /// Decodes the model from a decoded JSON map.
  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  /// Maps this wire model onto the domain entity.
  ///
  /// Server-backed accounts are never guests, so `isGuest` stays false.
  AuthUser toEntity() => AuthUser(
    id: id,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
    isPremium: isPremium,
    createdAt: createdAt,
  );
}
