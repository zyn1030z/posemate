import 'package:flutter/material.dart';

/// Snackbar helper for Posely AI.
///
/// Prefer the toast helper for passive notices; reach for the snackbar
/// when the message offers the user something to do, such as undoing a
/// deletion or retrying an upload. Styling comes from the app theme's
/// snackbar theme: floating behavior, elevated surface, large radius,
/// and an emerald action color.
abstract final class PoselySnackbar {
  /// Shows a themed floating snackbar via the nearest scaffold
  /// messenger, replacing any snackbar currently visible.
  ///
  /// When both an action label and handler make sense, pass
  /// [actionLabel] to render an emerald action button that invokes
  /// [onAction] on tap.
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? _noop),
      ),
    );
  }

  static void _noop() {}
}
