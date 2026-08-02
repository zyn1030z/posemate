/// Social identity providers supported for federated sign-in.
enum SocialProvider {
  /// Google Sign-In.
  google,

  /// Sign in with Apple.
  apple,

  /// Facebook Login.
  facebook;

  /// Human-readable provider name for buttons and error messages.
  String get label => switch (this) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
    SocialProvider.facebook => 'Facebook',
  };
}
