/// Form field validators shared across auth and profile features.
///
/// Every validator returns null when the value is valid and a short,
/// user-facing message when it is not — the contract `TextFormField`
/// expects from its validator callback.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _letterPattern = RegExp('[A-Za-z]');
  static final RegExp _digitPattern = RegExp('[0-9]');

  /// Validates an email address.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  /// Validates a password: at least 8 characters containing at least one
  /// letter and one digit.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!_letterPattern.hasMatch(v)) return 'Password must contain a letter';
    if (!_digitPattern.hasMatch(v)) return 'Password must contain a digit';
    return null;
  }

  /// Validates that a value is present and not just whitespace.
  ///
  /// The field name is used in the error message, e.g. 'Name is required'.
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  /// Validates that a password confirmation matches the original entry.
  static String? confirmPassword(String? value, String original) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }
}
