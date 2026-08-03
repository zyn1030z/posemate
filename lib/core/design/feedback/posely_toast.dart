import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_blur.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Semantic flavor of a Posely toast.
enum PoselyToastKind {
  /// Positive confirmation — success check icon, light haptic.
  success,

  /// Failure notice — danger icon, medium haptic.
  error,

  /// Neutral information — info-blue icon, no haptic.
  info,
}

/// Overlay-based passive notifications for Posely AI.
///
/// A toast is a floating glass capsule near the top of the screen that
/// slides down, holds for its duration, and slides away on its own. Use
/// a toast for passive notices; when the user can act on the message,
/// prefer the snackbar helper so an action button can be offered.
abstract final class PoselyToast {
  static OverlayEntry? _currentEntry;

  /// Shows a toast above the current overlay.
  ///
  /// Showing a new toast while one is visible removes the previous one
  /// immediately. Success fires a light haptic and error a medium one.
  static void show(
    BuildContext context, {
    required String message,
    PoselyToastKind kind = PoselyToastKind.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    _removeCurrentEntry();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) => _PoselyToastOverlay(
        message: message,
        kind: kind,
        duration: duration,
        onDismissed: () => _removeEntry(entry),
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
    switch (kind) {
      case PoselyToastKind.success:
        unawaited(HapticFeedback.lightImpact());
      case PoselyToastKind.error:
        unawaited(HapticFeedback.mediumImpact());
      case PoselyToastKind.info:
        break;
    }
  }

  static void _removeCurrentEntry() {
    final entry = _currentEntry;
    _currentEntry = null;
    if (entry != null && entry.mounted) {
      entry
        ..remove()
        ..dispose();
    }
  }

  static void _removeEntry(OverlayEntry entry) {
    if (identical(_currentEntry, entry)) {
      _currentEntry = null;
    }
    if (entry.mounted) {
      entry
        ..remove()
        ..dispose();
    }
  }
}

/// Animated toast capsule owned by a single overlay entry.
class _PoselyToastOverlay extends StatefulWidget {
  const _PoselyToastOverlay({
    required this.message,
    required this.kind,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final PoselyToastKind kind;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_PoselyToastOverlay> createState() => _PoselyToastOverlayState();
}

class _PoselyToastOverlayState extends State<_PoselyToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.base,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: AppDurations.easeOutExpo,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -0.4),
    end: Offset.zero,
  ).animate(_curve);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward());
    _timer = Timer(widget.duration, _startDismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startDismiss() {
    _timer?.cancel();
    _timer = null;
    if (!mounted) {
      return;
    }
    unawaited(
      _controller.reverse().whenComplete(() {
        if (mounted) {
          widget.onDismissed();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PoselyColors>()!;
    final topInset = MediaQuery.paddingOf(context).top;
    final (tint, iconData) = switch (widget.kind) {
      PoselyToastKind.success => (colors.success, Icons.check_rounded),
      PoselyToastKind.error => (colors.danger, Icons.error_outline_rounded),
      PoselyToastKind.info => (colors.info, Icons.info_outline_rounded),
    };

    return Positioned(
      top: topInset + AppSpacing.md,
      left: AppSpacing.xl,
      right: AppSpacing.xl,
      child: IgnorePointer(
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _curve,
            child: Center(
              child: Semantics(
                container: true,
                liveRegion: true,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: AppRadius.brPill,
                    boxShadow: AppShadows.medium,
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.brPill,
                    child: BackdropFilter(
                      filter: AppBlur.glassFilter(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.94),
                          borderRadius: AppRadius.brPill,
                          border: Border.all(color: colors.glassStroke),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: tint.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(iconData, size: 16, color: tint),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Flexible(
                                child: Text(
                                  widget.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
