import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/shared/utils/validators.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:posely_ai/features/auth/presentation/widgets/social_auth_button.dart';

/// Email and social sign-in screen.
///
/// Validates the form on submit only, delegates authentication to the
/// auth controller, and surfaces failures as error toasts. Successful
/// sign-in is handled by the router redirect listening to auth state,
/// so this screen never navigates on success.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  late final TapGestureRecognizer _registerRecognizer;

  String? _emailError;
  String? _passwordError;
  bool _submitting = false;
  bool _guestLoading = false;
  SocialProvider? _socialLoading;

  static const Duration _stagger = Duration(milliseconds: 80);

  @override
  void initState() {
    super.initState();
    _registerRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push(RoutePaths.register);
  }

  @override
  void dispose() {
    _registerRecognizer.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _busy => _submitting || _guestLoading || _socialLoading != null;

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    context.hideKeyboard();
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) {
      return;
    }
    setState(() => _submitting = true);
    final failure =
        await ref.read(authControllerProvider.notifier).signInWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    _showFailure(failure);
  }

  Future<void> _signInWithSocial(SocialProvider provider) async {
    if (_busy) {
      return;
    }
    setState(() => _socialLoading = provider);
    final failure =
        await ref.read(authControllerProvider.notifier).signInWithSocial(
              provider,
            );
    if (!mounted) {
      return;
    }
    setState(() => _socialLoading = null);
    _showFailure(failure);
  }

  Future<void> _continueAsGuest() async {
    if (_busy) {
      return;
    }
    setState(() => _guestLoading = true);
    final failure =
        await ref.read(authControllerProvider.notifier).continueAsGuest();
    if (!mounted) {
      return;
    }
    setState(() => _guestLoading = false);
    _showFailure(failure);
  }

  /// Shows an error toast for a failure; cancellations stay silent.
  void _showFailure(AppException? failure) {
    if (failure == null || failure is CancelledException) {
      return;
    }
    PoselyToast.show(
      context,
      message: failure.userMessage,
      kind: PoselyToastKind.error,
    );
  }

  Widget _buildLockup() {
    return Column(
      children: <Widget>[
        const PoselyLogo(size: 72),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Welcome back',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign in to continue creating.',
          style: AppTypography.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: AppDurations.base)
        .slideY(
          begin: 0.15,
          end: 0,
          duration: AppDurations.slow,
          curve: AppDurations.easeOutExpo,
        );
  }

  Widget _buildForm() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PoselyTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Email',
            hint: 'you@example.com',
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.email],
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.lg),
          PoselyTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'Password',
            hint: 'Your password',
            errorText: _passwordError,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.password],
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: PoselyButton(
              label: 'Forgot password?',
              variant: PoselyButtonVariant.ghost,
              size: PoselyButtonSize.small,
              onPressed: () => context.push(RoutePaths.forgotPassword),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PoselyButton(
            label: 'Sign in',
            expand: true,
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: _stagger, duration: AppDurations.base)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: _stagger,
          duration: AppDurations.slow,
          curve: AppDurations.easeOutExpo,
        );
  }

  Widget _buildDivider() {
    return Row(
      children: <Widget>[
        const Expanded(child: _HairlineGradient()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('OR CONTINUE WITH', style: AppTypography.overline),
        ),
        const Expanded(child: _HairlineGradient(reversed: true)),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: <Widget>[
        _buildDivider(),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (final provider in SocialProvider.values)
              SocialAuthButton(
                provider: provider,
                loading: _socialLoading == provider,
                onPressed: () => _signInWithSocial(provider),
              ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: _stagger * 2, duration: AppDurations.base)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: _stagger * 2,
          duration: AppDurations.slow,
          curve: AppDurations.easeOutExpo,
        );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(
            style: AppTypography.bodyMuted,
            children: <InlineSpan>[
              const TextSpan(text: 'New to Posely?  '),
              TextSpan(
                text: 'Create account',
                style: AppTypography.bodyMuted.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: _registerRecognizer,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        PoselyButton(
          label: 'Continue as guest',
          variant: PoselyButtonVariant.ghost,
          size: PoselyButtonSize.small,
          loading: _guestLoading,
          onPressed: _continueAsGuest,
        ),
      ],
    ).animate().fadeIn(delay: _stagger * 3, duration: AppDurations.slow);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: false,
      footer: _buildFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xxl),
          _buildLockup(),
          const SizedBox(height: AppSpacing.xxxl),
          _buildForm(),
          const SizedBox(height: AppSpacing.xxl),
          _buildSocialSection(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// One-pixel hairline that fades toward the screen edge, used on both
/// sides of the social sign-in divider label.
class _HairlineGradient extends StatelessWidget {
  const _HairlineGradient({this.reversed = false});

  /// Whether the hairline fades out to the right instead of the left.
  final bool reversed;

  static const Color _edge = Color(0x00000000);

  @override
  Widget build(BuildContext context) {
    final colors = reversed
        ? const <Color>[AppColors.glassStroke, _edge]
        : const <Color>[_edge, AppColors.glassStroke];
    return SizedBox(
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
        ),
      ),
    );
  }
}
