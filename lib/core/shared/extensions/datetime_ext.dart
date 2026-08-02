/// Date and time helpers used across features.
extension DateTimeX on DateTime {
  /// A short, human-readable description of how long ago this moment was.
  ///
  /// Under a minute yields 'now', then compact units follow: '5m ago',
  /// '3h ago', '2d ago', '6w ago'. Future dates also yield 'now'.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  /// Whether this moment falls on the same calendar day as the other one.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
