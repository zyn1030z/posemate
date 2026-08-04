/// General-purpose string helpers used across features.
extension StringX on String {
  /// This string with its first character upper-cased.
  ///
  /// Returns the string unchanged when it is empty.
  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  /// Whether this string is empty or contains only whitespace.
  bool get isBlank => trim().isEmpty;

  /// Whether this string contains at least one non-whitespace character.
  bool get isNotBlank => !isBlank;

  /// Returns this string, or the given fallback when this string is blank.
  String orDefault(String fallback) => isBlank ? fallback : this;

  /// Upper-cased first letters of up to the first two words.
  ///
  /// 'Ada Lovelace' becomes 'AL', 'ada' becomes 'A', and a blank string
  /// yields an empty result. Useful for avatar placeholders.
  String get initials {
    final words = trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2);
    return words.map((w) => w[0].toUpperCase()).join();
  }
}
