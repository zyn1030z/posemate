import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/shared/utils/validators.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:posely_ai/features/auth/presentation/widgets/auth_scaffold.dart';

/// Registration screen — creates a Posely AI account with a display
/// name, email, and password.
///
/// All fields validate on submit. Server-side field errors carried by a
/// `ValidationException` land on the matching fields, while any other
/// failure surfaces as an error toast. Successful registration is picked
/// up by the router redirect through the auth state change, so this
/// screen never navigates on success.
class RegisterScreen extends ConsumerStatefulWidget {
  /// Creates the registration screen.
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static final RegExp _letterPattern = RegExp('[A-Za-z]');
  static final RegExp _digitPattern = RegExp('[0-9]');
  static final RegExp _symbolPattern = RegExp('[^A-Za-z0-9]');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _signInRecognizer;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  int _strength = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
    _signInRecognizer = TapGestureRecognizer()..onTap = _backToSignIn;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _signInRecognizer.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _openTerms() {
    unawaited(context.push<void>(RoutePaths.terms));
  }

  void _openPrivacy() {
    unawaited(context.push<void>(RoutePaths.privacy));
  }

  void _backToSignIn() {
    context.pop();
  }

  /// Counts satisfied strength criteria: length of at least eight, one
  /// letter, one digit, and one symbol.
  int _strengthFor(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (_letterPattern.hasMatch(value)) score++;
    if (_digitPattern.hasMatch(value)) score++;
    if (_symbolPattern.hasMatch(value)) score++;
    return score;
  }

  void _handlePasswordChanged(String value) {
    setState(() => _strength = _strengthFor(value));
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final nameError = Validators.required(_nameController.text, field: 'Name');
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);
    final confirmError = Validators.confirmPassword(
      _confirmController.text,
      _passwordController.text,
    );
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    final invalid = nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null;
    if (invalid) return;

    setState(() => _submitting = true);
    final failure = await ref.read(authControllerProvider.notifier).register(
          displayName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (failure == null) {
      // The router redirect navigates once the auth state changes; the
      // screen itself never navigates on success.
      return;
    }
    if (failure is ValidationException && _applyFieldErrors(failure)) {
      return;
    }
    PoselyToast.show(
      context,
      message: failure.userMessage,
      kind: PoselyToastKind.error,
    );
  }

  /// Maps server field errors onto the matching inline errors.
  ///
  /// Returns true when at least one message landed on a field, in which
  /// case no toast is needed.
  bool _applyFieldErrors(ValidationException failure) {
    final nameMessages = failure.fieldErrors['display_name'];
    final emailMessages = failure.fieldErrors['email'];
    final passwordMessages = failure.fieldErrors['password'];
    final hasAny = (nameMessages?.isNotEmpty ?? false) ||
        (emailMessages?.isNotEmpty ?? false) ||
        (passwordMessages?.isNotEmpty ?? false);
    if (!hasAny) return false;
    setState(() {
      if (nameMessages != null && nameMessages.isNotEmpty) {
        _nameError = nameMessages.first;
      }
      if (emailMessages != null && emailMessages.isNotEmpty) {
        _emailError = emailMessages.first;
      }
      if (passwordMessages != null && passwordMessages.isNotEmpty) {
        _passwordError = passwordMessages.first;
      }
    });
    return true;
  }

  /// Staggered entrance shared by every section of the form.
  Widget _staggered(int index, Widget child) {
    return child
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: AppDurations.slow, curve: AppDurations.easeOutExpo)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: AppDurations.slow,
          curve: AppDurations.easeOutExpo,
        );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Create your account', style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Join thousands of creators posing smarter.',
          style: AppTypography.bodyMuted,
        ),
      ],
    );
  }

  Widget _buildTermsLine() {
    final linkStyle = AppTypography.caption.copyWith(
      color: AppColors.emerald400,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        style: AppTypography.caption,
        children: <InlineSpan>[
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
            text: 'Terms',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFooter() {
    return Text.rich(
      TextSpan(
        style: AppTypography.bodyMuted,
        children: <InlineSpan>[
          const TextSpan(text: 'Already have an account?  '),
          TextSpan(
            text: 'Sign in',
            style: AppTypography.body.copyWith(
              color: AppColors.emerald400,
              fontWeight: FontWeight.w600,
            ),
            recognizer: _signInRecognizer,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      footer: _buildFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _staggered(0, _buildHeader()),
          const SizedBox(height: AppSpacing.sectionGap),
          _staggered(
            1,
            PoselyTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Your name',
              errorText: _nameError,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.name],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _staggered(
            2,
            PoselyTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              errorText: _emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.email],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _staggered(
            3,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PoselyTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 8 characters',
                  errorText: _passwordError,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  onChanged: _handlePasswordChanged,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PasswordStrengthMeter(strength: _strength),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _staggered(
            4,
            PoselyTextField(
              controller: _confirmController,
              label: 'Confirm password',
              hint: 'Repeat your password',
              errorText: _confirmError,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => unawaited(_submit()),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _staggered(5, _buildTermsLine()),
          const SizedBox(height: AppSpacing.lg),
          _staggered(
            6,
            PoselyButton(
              label: 'Create account',
              expand: true,
              loading: _submitting,
              onPressed: () => unawaited(_submit()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Four-segment live password strength meter.
///
/// Each segment maps to one satisfied criterion — length of at least
/// eight, a letter, a digit, and a symbol — filling emerald as criteria
/// are met, with a Weak / Good / Strong caption below. The caption is
/// hidden while the password is empty.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.strength});

  /// Number of satisfied strength criteria, from 0 to 4.
  final int strength;

  String get _label {
    if (strength >= 4) return 'Strong';
    if (strength >= 2) return 'Good';
    return 'Weak';
  }

  Color get _labelColor {
    if (strength >= 4) return AppColors.primary;
    if (strength >= 2) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (var i = 0; i < 4; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  curve: AppDurations.easeOutExpo,
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < strength
                        ? AppColors.primary
                        : AppColors.surfaceHighest,
                    borderRadius: AppRadius.brPill,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (strength > 0) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _label,
            style: AppTypography.caption.copyWith(
              color: _labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
