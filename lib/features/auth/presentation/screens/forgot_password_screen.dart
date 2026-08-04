import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/shared/utils/validators.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_shadows.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/widgets/auth_scaffold.dart';

/// Number of seconds the resend affordance stays locked after a send.
const int _resendCooldownSeconds = 30;

/// Password recovery screen — requests a reset link for an email.
///
/// The body swaps between two phases: the request form and a generic
/// "check your inbox" success state with a resend cooldown. Success
/// stays on this screen; only the back affordances navigate away.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Creates the password recovery screen.
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  String? _emailError;
  bool _submitting = false;
  bool _sent = false;
  String _sentEmail = '';
  int _resendSeconds = _resendCooldownSeconds;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _backToSignIn() {
    context.pop();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final emailError = Validators.email(_emailController.text);
    setState(() => _emailError = emailError);
    if (emailError != null) return;

    setState(() => _submitting = true);
    final email = _emailController.text.trim();
    final failure = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email: email);
    if (!mounted) return;
    setState(() => _submitting = false);
    // Security: a NotFoundException still shows the generic success phase.
    // The copy only ever says "if an account exists", so this screen never
    // reveals whether an email address is registered — an enumeration
    // attempt learns nothing either way.
    if (failure == null || failure is NotFoundException) {
      unawaited(HapticFeedback.lightImpact());
      setState(() {
        _sent = true;
        _sentEmail = email;
      });
      _startResendCountdown();
      return;
    }
    PoselyToast.show(
      context,
      message: failure.userMessage,
      kind: PoselyToastKind.error,
    );
  }

  Future<void> _resend() async {
    _startResendCountdown();
    final failure = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email: _sentEmail);
    if (!mounted) return;
    // Security: swallow NotFoundException here too — see the note in the
    // submit handler above.
    if (failure != null && failure is! NotFoundException) {
      PoselyToast.show(
        context,
        message: failure.userMessage,
        kind: PoselyToastKind.error,
      );
    }
  }

  Widget _buildGlyph() {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassStroke),
        boxShadow: AppShadows.emeraldGlow,
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        size: 32,
        color: AppColors.blue300,
      ),
    );
  }

  Widget _buildFormPhase() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: _buildGlyph()),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Reset your password',
              style: AppTypography.screenTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter your account email and we will send a reset link.',
              style: AppTypography.bodyMuted.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            PoselyTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              errorText: _emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.email],
              onSubmitted: (_) => unawaited(_submit()),
            ),
            const SizedBox(height: AppSpacing.xl),
            PoselyButton(
              label: 'Send reset link',
              expand: true,
              loading: _submitting,
              onPressed: () => unawaited(_submit()),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: AppDurations.slow, curve: AppDurations.easeOutExpo)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: AppDurations.slow,
          curve: AppDurations.easeOutExpo,
        );
  }

  Widget _buildResendAffordance() {
    if (_resendSeconds > 0) {
      return Text(
        'Resend in ${_resendSeconds}s',
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => unawaited(_resend()),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(
            'Resend email',
            style: AppTypography.caption.copyWith(
              color: AppColors.emerald400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSentPhase() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SuccessState(
          title: 'Check your inbox',
          message:
              'If an account exists for $_sentEmail, '
              'a reset link is on its way.',
          action: PoselyButton(
            label: 'Back to sign in',
            variant: PoselyButtonVariant.ghost,
            onPressed: _backToSignIn,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(child: _buildResendAffordance()),
      ],
    );
  }

  static Widget _fadeSlideTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final position = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: position, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AnimatedSwitcher(
        duration: AppDurations.base,
        switchInCurve: AppDurations.easeOutExpo,
        switchOutCurve: AppDurations.easeOutExpo,
        transitionBuilder: _fadeSlideTransition,
        child: _sent
            ? KeyedSubtree(
                key: const ValueKey<String>('sent'),
                child: _buildSentPhase(),
              )
            : KeyedSubtree(
                key: const ValueKey<String>('form'),
                child: _buildFormPhase(),
              ),
      ),
    );
  }
}
