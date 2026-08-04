import 'package:flutter/material.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_blur.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Fraction of the screen height a Posely sheet may occupy at most.
const double _maxHeightFraction = 0.85;

/// Visual diameter of the close-button glass disc.
const double _closeDiscSize = 32;

/// Minimum tap target for interactive elements.
const double _minTapTarget = 44;

/// Shows the Posely glass modal bottom sheet and returns the value the
/// sheet route is popped with.
///
/// The sheet is a frosted panel: the theme surface color at 96 percent
/// opacity laid over a backdrop blur of [AppBlur.glass], rounded on top
/// with [AppRadius.xxl]. A centered drag handle sits above an optional
/// [title] row whose trailing glass close button pops with null.
///
/// Content produced by [builder] is padded with
/// [AppSpacing.screenPadding], stays keyboard-safe by tracking the
/// bottom view insets, and is capped at 85 percent of the screen
/// height — taller content becomes scrollable.
///
/// Use a passive toast for notices and a dialog for decisions; sheets
/// are for browsing and editing tasks that keep screen context.
Future<T?> showPoselyBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool useSafeArea = true,
}) {
  final colors = Theme.of(context).extension<PoselyColors>()!;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent,
    barrierColor: colors.scrim,
    showDragHandle: false,
    builder: (BuildContext sheetContext) {
      return _PoselyBottomSheetContainer(title: title, builder: builder);
    },
  );
}

/// Frosted glass container that hosts the sheet chrome and content.
class _PoselyBottomSheetContainer extends StatelessWidget {
  const _PoselyBottomSheetContainer({
    required this.title,
    required this.builder,
  });

  final String? title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PoselyColors>()!;
    final title = this.title;
    final maxHeight = MediaQuery.sizeOf(context).height * _maxHeightFraction;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        child: BackdropFilter(
          filter: AppBlur.glassFilter(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.96),
              border: Border(top: BorderSide(color: colors.glassStroke)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Semantics(
                container: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _SheetDragHandle(),
                    if (title != null) _SheetHeaderRow(title: title),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          padding: AppSpacing.screenPadding.add(
                            EdgeInsets.only(
                              top: AppSpacing.sm,
                              bottom: AppSpacing.xxl + bottomSafe,
                            ),
                          ),
                          child: Builder(builder: builder),
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
    );
  }
}

/// Centered 36 by 4 pill indicating the sheet can be dragged.
class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Container(
        key: const ValueKey<String>('posely_bottom_sheet_drag_handle'),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: colors.glassStroke,
          borderRadius: AppRadius.brPill,
        ),
      ),
    );
  }
}

/// Title row with a trailing glass close button.
class _SheetHeaderRow extends StatelessWidget {
  const _SheetHeaderRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.md,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.cardTitle.copyWith(color: scheme.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _SheetCloseButton(),
        ],
      ),
    );
  }
}

/// 32 pixel glass disc close button inside a 44 pixel tap target.
class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PoselyColors>()!;
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: SizedBox(
          width: _minTapTarget,
          height: _minTapTarget,
          child: Center(
            child: Container(
              width: _closeDiscSize,
              height: _closeDiscSize,
              decoration: BoxDecoration(
                color: colors.glassSurface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.glassStroke),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
