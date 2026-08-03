import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// The Posely text input field.
///
/// A filled field on an elevated surface with no stroke at rest. Focus
/// animates in a 1.5 pixel blue stroke and a soft glow; an error
/// swaps the stroke to the danger color and reveals the error message
/// below. When obscuring text, a trailing eye toggle reveals and hides
/// the value, replacing any custom suffix.
class PoselyTextField extends StatefulWidget {
  /// Creates a Posely text field.
  const PoselyTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.maxLines = 1,
    this.autofillHints,
    this.enabled = true,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Optional caption label rendered above the field.
  final String? label;

  /// Placeholder text shown while the field is empty.
  final String? hint;

  /// Error message below the field. Non-null switches the field into
  /// its error state.
  final String? errorText;

  /// Whether the entered text is obscured, with an eye toggle suffix.
  final bool obscureText;

  /// Keyboard type requested when the field gains focus.
  final TextInputType? keyboardType;

  /// Optional widget rendered before the editable area.
  final Widget? prefix;

  /// Optional widget rendered after the editable area. Ignored while
  /// obscuring text, when the eye toggle takes its place.
  final Widget? suffix;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Action button shown on the software keyboard.
  final TextInputAction? textInputAction;

  /// External focus node. When null the field manages its own.
  final FocusNode? focusNode;

  /// Maximum number of lines; forced to one while obscuring text.
  final int maxLines;

  /// Autofill hints forwarded to the platform autofill service.
  final Iterable<String>? autofillHints;

  /// Whether the field accepts input. Disabled fields render dimmed.
  final bool enabled;

  @override
  State<PoselyTextField> createState() => _PoselyTextFieldState();
}

class _PoselyTextFieldState extends State<PoselyTextField> {
  FocusNode? _internalFocusNode;
  bool _focused = false;
  bool _revealed = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _focusNode.addListener(_handleFocusChange);
    _focused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(PoselyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)
          ?.removeListener(_handleFocusChange);
      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      } else {
        _internalFocusNode ??= FocusNode();
      }
      _focusNode.addListener(_handleFocusChange);
      _focused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) {
      return;
    }
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _toggleReveal() {
    HapticFeedback.selectionClick();
    setState(() => _revealed = !_revealed);
  }

  Widget _buildRevealToggle() {
    final toggleLabel = _revealed ? 'Hide password' : 'Show password';
    return Semantics(
      button: true,
      label: toggleLabel,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _toggleReveal,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                _revealed
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PoselyColors>()!;
    final hasError = widget.errorText != null;

    final borderColor = hasError
        ? colors.danger
        : _focused
            ? AppColors.primary
            : Colors.transparent;
    final glow = _focused && !hasError
        ? <BoxShadow>[
            BoxShadow(color: colors.glow, blurRadius: 18, spreadRadius: -4),
          ]
        : null;

    final field = AnimatedContainer(
      duration: AppDurations.base,
      curve: AppDurations.easeOutExpo,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: glow,
      ),
      child: Row(
        crossAxisAlignment: widget.maxLines > 1 && !widget.obscureText
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.prefix != null) ...<Widget>[
            widget.prefix!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.obscureText && !_revealed,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              autofillHints: widget.autofillHints,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: false,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          if (widget.obscureText) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            _buildRevealToggle(),
          ] else if (widget.suffix != null) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            widget.suffix!,
          ],
        ],
      ),
    );

    final error = AnimatedSwitcher(
      duration: AppDurations.fast,
      switchInCurve: AppDurations.easeOutExpo,
      child: hasError
          ? Padding(
              key: ValueKey<String>(widget.errorText!),
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                left: AppSpacing.xs,
              ),
              child: Text(
                widget.errorText!,
                style: AppTypography.caption.copyWith(color: colors.danger),
              ),
            )
          : const SizedBox.shrink(),
    );

    Widget result = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.sm,
              left: AppSpacing.xs,
            ),
            child: Text(
              widget.label!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        field,
        error,
      ],
    );

    if (!widget.enabled) {
      result = Opacity(opacity: 0.5, child: result);
    }
    return result;
  }
}
