import 'package:dio/dio.dart';
import 'package:posely_ai/core/config/constants/api_endpoints.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:posely_ai/features/auth/data/models/auth_response_model.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';

/// Remote source of truth for authentication calls.
///
/// Implementations throw `AppException` or `DioException` upward; error
/// mapping happens in the repository via `guardApi`.
abstract interface class AuthRemoteDatasource {
  /// Exchanges an email/password pair for a token payload.
  Future<AuthResponseModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates an account and returns the initial token payload.
  Future<AuthResponseModel> register({
    required String displayName,
    required String email,
    required String password,
  });

  /// Requests a password-reset email for the given address.
  Future<void> requestPasswordReset({required String email});

  /// Exchanges a provider-issued ID token for a Posely token payload.
  Future<AuthResponseModel> socialLogin({
    required SocialProvider provider,
    required String idToken,
  });
}

/// Dio-backed implementation talking to the real backend.
///
/// All auth endpoints are public, so every request carries the skip-auth
/// marker and never attaches an Authorization header. Response bodies match
/// docs/API_CONTRACTS.md: the token payload is the top-level JSON object.
class AuthApiDatasource implements AuthRemoteDatasource {
  /// Creates the datasource with the app-wide Dio client.
  const AuthApiDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<AuthResponseModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
      options: _publicEndpoint(),
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: <String, dynamic>{
        'display_name': displayName,
        'email': email,
        'password': password,
      },
      options: _publicEndpoint(),
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.forgotPassword,
      data: <String, dynamic>{'email': email},
      options: _publicEndpoint(),
    );
  }

  @override
  Future<AuthResponseModel> socialLogin({
    required SocialProvider provider,
    required String idToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.socialLogin,
      data: <String, dynamic>{
        'provider': provider.name,
        'id_token': idToken,
        'access_token': null,
      },
      options: _publicEndpoint(),
    );
    return _parseAuthResponse(response);
  }

  /// Marks a request as unauthenticated so no bearer token is attached.
  Options _publicEndpoint() =>
      Options(extra: <String, dynamic>{kSkipAuthKey: true});

  /// Decodes the token payload, guarding against an empty body.
  AuthResponseModel _parseAuthResponse(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data;
    if (data == null) {
      throw UnknownException(
        message: 'Empty auth response body from '
            '${response.requestOptions.path}.',
      );
    }
    return AuthResponseModel.fromJson(data);
  }
}
