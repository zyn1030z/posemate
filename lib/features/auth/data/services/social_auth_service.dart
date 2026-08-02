import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Isolates the native social sign-in SDKs behind one narrow seam.
///
/// The rest of the data layer only ever needs a provider-issued token to
/// exchange with the backend, so this is the sole surface where SDK types
/// may appear. Implementations throw `CancelledException` when the user
/// abandons the flow and `UnknownException` for configuration failures.
abstract interface class SocialAuthService {
  /// Runs the native flow for the provider and returns its credential token:
  /// an OIDC ID token for Google and Apple, an access token for Facebook.
  Future<String> fetchIdToken(SocialProvider provider);
}

/// Production implementation backed by the platform SDKs.
///
/// google_sign_in 7.x flow: the `GoogleSignIn.instance` singleton is
/// initialized once, then `authenticate` runs the interactive flow and the
/// ID token is read from the account's `authentication` tokens.
class SdkSocialAuthService implements SocialAuthService {
  /// Creates the SDK-backed service.
  SdkSocialAuthService();

  /// Whether `GoogleSignIn.instance.initialize` has completed; the SDK
  /// requires exactly one initialize call before any other method.
  bool _googleInitialized = false;

  @override
  Future<String> fetchIdToken(SocialProvider provider) => switch (provider) {
    SocialProvider.google => _fetchGoogleIdToken(),
    SocialProvider.apple => _fetchAppleIdToken(),
    SocialProvider.facebook => _fetchFacebookAccessToken(),
  };

  Future<String> _fetchGoogleIdToken() async {
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await signIn.initialize();
        _googleInitialized = true;
      }
      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const UnknownException(
          message: 'Google Sign-In returned no ID token. Google console '
              'setup is required — see docs/FIREBASE_SETUP.md.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (error, stackTrace) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw CancelledException(
          message: 'Google sign-in was cancelled.',
          cause: error,
          stackTrace: stackTrace,
        );
      }
      throw UnknownException(
        message: 'Google Sign-In failed (${error.code.name}). Google console '
            'setup is required — see docs/FIREBASE_SETUP.md.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (error, stackTrace) {
      throw UnknownException(
        message: 'Google Sign-In is not configured for this platform. '
            'Google console setup is required — see docs/FIREBASE_SETUP.md.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String> _fetchAppleIdToken() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const UnknownException(
          message: 'Sign in with Apple returned no identity token. Apple '
              'console setup is required — see docs/FIREBASE_SETUP.md.',
        );
      }
      return identityToken;
    } on SignInWithAppleAuthorizationException catch (error, stackTrace) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw CancelledException(
          message: 'Apple sign-in was cancelled.',
          cause: error,
          stackTrace: stackTrace,
        );
      }
      throw UnknownException(
        message: 'Sign in with Apple failed (${error.code.name}). Apple '
            'console setup is required — see docs/FIREBASE_SETUP.md.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on SignInWithAppleException catch (error, stackTrace) {
      throw UnknownException(
        message: 'Sign in with Apple is unavailable on this device. Apple '
            'console setup is required — see docs/FIREBASE_SETUP.md.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (error, stackTrace) {
      throw UnknownException(
        message: 'Sign in with Apple is not configured for this platform. '
            'Apple console setup is required — see docs/FIREBASE_SETUP.md.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String> _fetchFacebookAccessToken() async {
    final LoginResult result;
    try {
      result = await FacebookAuth.instance.login();
    } on PlatformException catch (error, stackTrace) {
      throw UnknownException(
        message: 'Facebook Login is not configured for this platform. '
            'Facebook console setup is required — see docs/FIREBASE_SETUP.md.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken?.tokenString;
        if (token == null || token.isEmpty) {
          throw const UnknownException(
            message: 'Facebook Login returned no access token. Facebook '
                'console setup is required — see docs/FIREBASE_SETUP.md.',
          );
        }
        return token;
      case LoginStatus.cancelled:
        throw const CancelledException(
          message: 'Facebook sign-in was cancelled.',
        );
      case LoginStatus.operationInProgress:
      case LoginStatus.failed:
        throw UnknownException(
          message: 'Facebook Login failed'
              '${result.message == null ? '' : ' (${result.message})'}. '
              'Facebook console setup is required — '
              'see docs/FIREBASE_SETUP.md.',
        );
    }
  }
}

/// Provides the app-wide social auth service.
final socialAuthServiceProvider = Provider<SocialAuthService>(
  (ref) => SdkSocialAuthService(),
);
