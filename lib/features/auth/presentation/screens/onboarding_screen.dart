import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posely_ai/core/config/constants/storage_keys.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/services/haptics/haptic_service.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_durations.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Three-page first-run onboarding carousel.
///
/// Sells the three core promises — the pose library, the ghost camera
/// guide, and realtime AI coaching — with hand-built visuals, then
/// persists the onboarding-complete flag and moves on to login. Both
/// Skip and the final Get started button complete the flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      headline: 'Find your pose',
      body: 'Browse a curated library of professional poses for every '
          'scene, mood, and body type.',
      visual: _PoseGridVisual(),
    ),
    _OnboardingPage(
      headline: 'Shoot with a ghost guide',
      body: 'Line up the perfect shot with a translucent pose guide '
          'floating over your camera.',
      visual: _GhostGuideVisual(),
    ),
    _OnboardingPage(
      headline: 'Let AI coach you',
      body: 'Get realtime scores and gentle tips while you shoot, '
          'like a coach in your pocket.',
      visual: _CoachVisual(),
    ),
  ];

  final PageController _pageController = PageController();
  int _page = 0;
  bool _completing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    unawaited(ref.read(hapticServiceProvider).light());
    setState(() => _page = page);
  }

  void _handleNext() {
    if (_page >= _pages.length - 1) {
      unawaited(_complete());
      return;
    }
    unawaited(
      _pageController.nextPage(
        duration: AppDurations.slow,
        curve: AppDurations.easeOutExpo,
      ),
    );
  }

  Future<void> _complete() async {
    if (_completing) {
      return;
    }
    _completing = true;
    unawaited(ref.read(hapticServiceProvider).medium());
    await ref.read(localStorageProvider).put(
          StorageBox.settings,
          StorageKeys.onboardingComplete,
          true,
        );
    if (!mounted) {
      return;
    }
    context.go(RoutePaths.login);
  }

  Widget _buildDots() {
    return Semantics(
      container: true,
      label: 'Page ${_page + 1} of ${_pages.length}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < _pages.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: AppDurations.base,
              curve: AppDurations.easeOutExpo,
              width: i == _page ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == _page ? AppColors.primary : AppColors.surfaceHighest,
                borderRadius: AppRadius.brPill,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Subtle emerald aurora anchored to the top-left corner.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.8),
                radius: 1.2,
                colors: <Color>[
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      right: AppSpacing.lg,
                    ),
                    child: PoselyButton(
                      label: 'Skip',
                      variant: PoselyButtonVariant.ghost,
                      size: PoselyButtonSize.small,
                      onPressed: _complete,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: _handlePageChanged,
                    children: <Widget>[
                      for (final page in _pages) _OnboardingPageView(page: page),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDots(),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: PoselyButton(
                        label: isLast ? 'Get started' : 'Next',
                        expand: true,
                        onPressed: _handleNext,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Static copy and visual for one onboarding page.
class _OnboardingPage {
  const _OnboardingPage({
    required this.headline,
    required this.body,
    required this.visual,
  });

  /// Large display headline of the page.
  final String headline;

  /// One supporting sentence under the headline.
  final String body;

  /// Hero visual rendered above the headline.
  final Widget visual;
}

/// Lays out one onboarding page: visual, headline, and supporting copy,
/// each entering with a staggered fade-and-rise when the page mounts.
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: page.visual,
              ),
            )
                .animate()
                .fadeIn(duration: AppDurations.slow)
                .scale(
                  begin: const Offset(0.94, 0.94),
                  end: const Offset(1, 1),
                  duration: AppDurations.slow,
                  curve: AppDurations.easeOutExpo,
                ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text(
            page.headline,
            style: AppTypography.displayHero.copyWith(fontSize: 34),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: AppDurations.fast, duration: AppDurations.base)
              .slideY(
                begin: 0.25,
                end: 0,
                delay: AppDurations.fast,
                duration: AppDurations.slow,
                curve: AppDurations.easeOutExpo,
              ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              page.body,
              style: AppTypography.bodyMuted.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(delay: AppDurations.base, duration: AppDurations.slow),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// Page-one visual: a staggered mini-grid of four gradient pose tiles,
/// each watermarked with the aperture mark.
class _PoseGridVisual extends StatelessWidget {
  const _PoseGridVisual();

  static const LinearGradient _emeraldDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.emerald500, AppColors.blue800],
  );

  static const LinearGradient _slate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.surfaceHighest, AppColors.surfaceElevated],
  );

  static const LinearGradient _forest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.blue800, AppColors.surfaceElevated],
  );

  static const LinearGradient _mist = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.surfaceElevated, AppColors.blue900],
  );

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                _PoseTile(
                  height: 128,
                  gradient: _emeraldDeep,
                  delay: Duration.zero,
                ),
                SizedBox(height: AppSpacing.md),
                _PoseTile(
                  height: 92,
                  gradient: _slate,
                  delay: Duration(milliseconds: 90),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              children: <Widget>[
                SizedBox(height: AppSpacing.xxl),
                _PoseTile(
                  height: 92,
                  gradient: _forest,
                  delay: Duration(milliseconds: 180),
                ),
                SizedBox(height: AppSpacing.md),
                _PoseTile(
                  height: 128,
                  gradient: _mist,
                  delay: Duration(milliseconds: 270),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One rounded gradient tile with an aperture watermark and a delayed
/// fade-and-rise entrance.
class _PoseTile extends StatelessWidget {
  const _PoseTile({
    required this.height,
    required this.gradient,
    required this.delay,
  });

  final double height;
  final Gradient gradient;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: const Center(
        child: Opacity(opacity: 0.35, child: PoselyLogo(size: 36)),
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: AppDurations.slow)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: delay,
          duration: AppDurations.slow,
          curve: AppDurations.easeOutExpo,
        );
  }
}

/// Page-two visual: a phone-frame outline with rule-of-thirds grid
/// lines and a translucent emerald pose silhouette.
class _GhostGuideVisual extends StatelessWidget {
  const _GhostGuideVisual();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(200, 320),
      painter: _GhostGuidePainter(),
    );
  }
}

/// Paints the ghost-guide mock: a rounded phone frame, faint thirds
/// grid, and a soft-glowing emerald silhouette (head plus torso blob).
class _GhostGuidePainter extends CustomPainter {
  const _GhostGuidePainter();

  static const Color _frameColor = Color(0x3DFFFFFF);
  static const Color _gridColor = Color(0x14FFFFFF);
  static const Color _silhouetteColor = Color(0x4710B981);
  static const Color _glowColor = Color(0x3310B981);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Phone frame.
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(32),
    );
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _frameColor;
    canvas.drawRRect(frame, framePaint);

    // Rule-of-thirds grid inside the frame.
    const inset = 14.0;
    final gridPaint = Paint()
      ..strokeWidth = 1
      ..color = _gridColor;
    for (var i = 1; i <= 2; i++) {
      final x = inset + (w - inset * 2) * i / 3;
      canvas.drawLine(Offset(x, inset), Offset(x, h - inset), gridPaint);
      final y = inset + (h - inset * 2) * i / 3;
      canvas.drawLine(Offset(inset, y), Offset(w - inset, y), gridPaint);
    }

    // Ghost silhouette: head circle plus shoulders-to-hip blob.
    final silhouette = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(w * 0.5, h * 0.33),
          radius: w * 0.11,
        ),
      )
      ..moveTo(w * 0.32, h * 0.80)
      ..quadraticBezierTo(w * 0.33, h * 0.55, w * 0.40, h * 0.49)
      ..quadraticBezierTo(w * 0.45, h * 0.45, w * 0.50, h * 0.45)
      ..quadraticBezierTo(w * 0.55, h * 0.45, w * 0.60, h * 0.49)
      ..quadraticBezierTo(w * 0.67, h * 0.55, w * 0.68, h * 0.80)
      ..quadraticBezierTo(w * 0.50, h * 0.86, w * 0.32, h * 0.80)
      ..close();

    final glowPaint = Paint()
      ..color = _glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(silhouette, glowPaint);
    canvas.drawPath(silhouette, Paint()..color = _silhouetteColor);
  }

  @override
  bool shouldRepaint(_GhostGuidePainter oldDelegate) => false;
}

/// Page-three visual: an animated score ring over two sub-score pills.
class _CoachVisual extends StatelessWidget {
  const _CoachVisual();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ScoreRing(score: 0.92, size: 150, label: 'Pose match'),
        SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ScorePill(label: 'Framing', score: 0.88),
            SizedBox(width: AppSpacing.md),
            ScorePill(label: 'Posture', score: 0.94),
          ],
        ),
      ],
    );
  }
}
