import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/features/auth/data/models/auth_user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Wire model for the token payload returned by login, register, social
/// login, and refresh.
///
/// Matches the auth section of docs/API_CONTRACTS.md: the payload is the
/// top-level response body (no wrapper object).
@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  /// Creates the wire model.
  const factory AuthResponseModel({
    /// The authenticated user's profile.
    required AuthUserModel user,

    /// Bearer token for subsequent API calls.
    required String accessToken,

    /// Rotating token used to obtain fresh access tokens, when issued.
    String? refreshToken,

    /// Absolute expiry of the access token, when the server includes it.
    DateTime? expiresAt,
  }) = _AuthResponseModel;

  /// Decodes the model from a decoded JSON map.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
