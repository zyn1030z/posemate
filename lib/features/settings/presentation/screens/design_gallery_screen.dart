import 'package:flutter/material.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/shared/widgets/app_loading_view.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_gradients.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Dev-only showcase of the Posely AI design system.
///
/// Renders every token and component in one scrollable screen so the
/// team can review the visual language on a real device: brand
/// identity, palette, typography, buttons, chips, inputs, glass
/// surfaces, feedback overlays, state views, skeletons, and scores.
///
/// Reached only via the /dev/design-gallery route and never linked
/// from production UI. See docs/DESIGN_SYSTEM.md for the reference.
class DesignGalleryScreen extends StatelessWidget {
  /// Creates the design gallery screen.
  const DesignGalleryScreen({super.key});

  static const SizedBox _sectionGap = SizedBox(height: AppSpacing.sectionGap);
  static const SizedBox _gap = SizedBox(height: AppSpacing.lg);
  static const SizedBox _smallGap = SizedBox(height: AppSpacing.md);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Design gallery'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _sectionGap,
          _buildIdentity(),
          _sectionGap,
          _buildTypography(),
          _sectionGap,
          _buildButtons(context),
          _sectionGap,
          _buildChips(),
          _sectionGap,
          _buildInputs(),
          _sectionGap,
          _buildGlass(context),
          _sectionGap,
          _buildFeedback(context),
          _sectionGap,
          _buildStates(context),
          _sectionGap,
          _buildSkeletons(),
          _sectionGap,
          _buildScores(),
          SizedBox(height: bottomInset + AppSpacing.massive),
        ],
      ),
    );
  }

  // --- Identity -------------------------------------------------------------

  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Identity'),
        _gap,
        const Center(child: PoselyLogo(size: 72, showWordmark: true)),
        _sectionGap,
        Text('Emerald scale', style: AppTypography.cardTitle),
        _smallGap,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in _emeraldScale.entries) ...[
                _ColorSwatch(name: entry.key, color: entry.value),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
        _gap,
        Text('Gradients', style: AppTypography.cardTitle),
        _smallGap,
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _GradientSwatch(
                name: 'emeraldHero',
                gradient: AppGradients.emeraldHero,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _GradientSwatch(
                name: 'backgroundAurora',
                gradient: AppGradients.backgroundAurora,
              ),
            ),
          ],
        ),
        _gap,
        const Center(
          child: ScoreRing(score: 0.92, size: 104, label: 'scoreRing'),
        ),
      ],
    );
  }

  static const Map<String, Color> _emeraldScale = <String, Color>{
    '50': AppColors.emerald50,
    '100': AppColors.emerald100,
    '200': AppColors.emerald200,
    '300': AppColors.emerald300,
    '400': AppColors.emerald400,
    '500': AppColors.emerald500,
    '600': AppColors.emerald600,
    '700': AppColors.emerald700,
    '800': AppColors.emerald800,
    '900': AppColors.emerald900,
  };

  // --- Typography -----------------------------------------------------------

  Widget _buildTypography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Typography'),
        _gap,
        _TypeSample(token: 'displayHero', style: AppTypography.displayHero),
        _gap,
        _TypeSample(token: 'screenTitle', style: AppTypography.screenTitle),
        _gap,
        _TypeSample(token: 'sectionTitle', style: AppTypography.sectionTitle),
        _gap,
        _TypeSample(token: 'cardTitle', style: AppTypography.cardTitle),
        _gap,
        _TypeSample(token: 'body', style: AppTypography.body),
        _gap,
        _TypeSample(token: 'bodyMuted', style: AppTypography.bodyMuted),
        _gap,
        _TypeSample(token: 'caption', style: AppTypography.caption),
        _gap,
        _TypeSample(
          token: 'overline',
          style: AppTypography.overline,
          sample: 'STRIKE A POSE',
        ),
      ],
    );
  }

  // --- Buttons --------------------------------------------------------------

  Widget _buildButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Buttons',
          actionLabel: 'Docs',
          onAction: () => PoselyToast.show(
            context,
            message: 'See docs/DESIGN_SYSTEM.md',
          ),
        ),
        _gap,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final variant in PoselyButtonVariant.values)
              for (final size in PoselyButtonSize.values)
                PoselyButton(
                  label: '${variant.name} ${size.name}',
                  onPressed: () {},
                  variant: variant,
                  size: size,
                ),
          ],
        ),
        _gap,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PoselyButton(
              label: 'Loading',
              onPressed: () {},
              loading: true,
            ),
            const PoselyButton(label: 'Disabled'),
            PoselyButton(
              label: 'Generate',
              onPressed: () {},
              icon: Icons.auto_awesome_rounded,
            ),
          ],
        ),
        _gap,
        PoselyButton(
          label: 'Continue',
          onPressed: () {},
          expand: true,
        ),
        _gap,
        Row(
          children: [
            PoselyIconButton(
              icon: Icons.favorite_border_rounded,
              onPressed: () {},
              semanticLabel: 'Like',
            ),
            const SizedBox(width: AppSpacing.md),
            PoselyIconButton(
              icon: Icons.favorite_rounded,
              onPressed: () {},
              active: true,
              semanticLabel: 'Liked',
            ),
            const SizedBox(width: AppSpacing.md),
            const PoselyIconButton(
              icon: Icons.share_rounded,
              semanticLabel: 'Share (disabled)',
            ),
          ],
        ),
      ],
    );
  }

  // --- Chips ----------------------------------------------------------------

  Widget _buildChips() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Chips'),
        _gap,
        _ChipShowcase(),
      ],
    );
  }

  // --- Inputs ---------------------------------------------------------------

  Widget _buildInputs() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Inputs'),
        _gap,
        PoselyTextField(hint: 'Search poses'),
        _gap,
        PoselyTextField(
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        _gap,
        PoselyTextField(
          label: 'Username',
          hint: 'poselyfan',
          errorText: 'This username is already taken',
        ),
        _gap,
        PoselyTextField(
          label: 'Password',
          hint: 'Enter your password',
          obscureText: true,
        ),
      ],
    );
  }

  // --- Cards & glass --------------------------------------------------------

  Widget _buildGlass(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Cards & glass'),
        _gap,
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            borderRadius: AppRadius.brXl,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.emerald400,
                AppColors.info,
                AppColors.warning,
              ],
            ),
          ),
          child: GlassCard(
            onTap: () => PoselyToast.show(context, message: 'Glass card tap'),
            child: Row(
              children: [
                const Icon(
                  Icons.blur_on_rounded,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Glass card', style: AppTypography.cardTitle),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Frosted blur over whatever sits behind it.',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _gap,
        GlassPanel(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              const Icon(
                Icons.layers_rounded,
                color: AppColors.emerald400,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Glass panel — the non-tappable base surface for bars, '
                  'HUDs, and overlays.',
                  style: AppTypography.body,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Feedback -------------------------------------------------------------

  Widget _buildFeedback(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Feedback'),
        _gap,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            PoselyButton(
              label: 'Bottom sheet',
              onPressed: () => _showSampleSheet(context),
              variant: PoselyButtonVariant.glass,
              size: PoselyButtonSize.small,
            ),
            PoselyButton(
              label: 'Dialog',
              onPressed: () => _showSampleDialog(context),
              variant: PoselyButtonVariant.glass,
              size: PoselyButtonSize.small,
            ),
            PoselyButton(
              label: 'Confirm dialog',
              onPressed: () => _showSampleConfirm(context),
              variant: PoselyButtonVariant.glass,
              size: PoselyButtonSize.small,
            ),
            PoselyButton(
              label: 'Toast success',
              onPressed: () => PoselyToast.show(
                context,
                message: 'Pose saved to collection',
                kind: PoselyToastKind.success,
              ),
              variant: PoselyButtonVariant.ghost,
              size: PoselyButtonSize.small,
            ),
            PoselyButton(
              label: 'Toast error',
              onPressed: () => PoselyToast.show(
                context,
                message: 'Upload failed — check your connection',
                kind: PoselyToastKind.error,
              ),
              variant: PoselyButtonVariant.ghost,
              size: PoselyButtonSize.small,
            ),
            PoselyButton(
              label: 'Toast info',
              onPressed: () => PoselyToast.show(
                context,
                message: 'AI coach is warming up',
              ),
              variant: PoselyButtonVariant.ghost,
              size: PoselyButtonSize.small,
            ),
            PoselyButton(
              label: 'Snackbar',
              onPressed: () => PoselySnackbar.show(
                context,
                message: 'Photo saved to gallery',
                actionLabel: 'Undo',
                onAction: () => PoselyToast.show(context, message: 'Undone'),
              ),
              variant: PoselyButtonVariant.ghost,
              size: PoselyButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showSampleSheet(BuildContext context) {
    return showPoselyBottomSheet<void>(
      context: context,
      title: 'Choose a pose set',
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final label in const <String>[
            'Portrait',
            'Full body',
            'Couple',
            'Group',
          ])
            ListTile(
              leading: const Icon(
                Icons.accessibility_new_rounded,
                color: AppColors.emerald400,
              ),
              title: Text(label, style: AppTypography.body),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
        ],
      ),
    );
  }

  Future<void> _showSampleDialog(BuildContext context) {
    return showPoselyDialog<void>(
      context: context,
      title: 'Delete photo?',
      message: 'This removes the capture from your gallery. '
          'You cannot undo this.',
      icon: Icons.delete_outline_rounded,
      actions: [
        const PoselyDialogAction(label: 'Cancel'),
        PoselyDialogAction(
          label: 'Delete',
          isPrimary: true,
          isDestructive: true,
          onDialogTap: (_) => PoselyToast.show(
            context,
            message: 'Photo deleted',
            kind: PoselyToastKind.error,
          ),
        ),
      ],
    );
  }

  Future<void> _showSampleConfirm(BuildContext context) async {
    final confirmed = await showPoselyConfirmDialog(
      context: context,
      title: 'Discard changes?',
      message: 'Your edits to this pose will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      destructive: true,
    );
    if (!context.mounted) {
      return;
    }
    PoselyToast.show(
      context,
      message: confirmed ? 'Changes discarded' : 'Kept editing',
      kind: confirmed ? PoselyToastKind.success : PoselyToastKind.info,
    );
  }

  // --- States ---------------------------------------------------------------

  Widget _buildStates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'States'),
        _gap,
        EmptyState(
          title: 'No poses yet',
          message: 'Browse the library or generate a pose to get started.',
          icon: Icons.photo_library_outlined,
          action: PoselyButton(
            label: 'Browse poses',
            onPressed: () {},
            variant: PoselyButtonVariant.glass,
            size: PoselyButtonSize.small,
          ),
        ),
        _gap,
        SuccessState(
          title: 'Pose saved',
          message: 'Find it any time in your collections.',
          action: PoselyButton(
            label: 'View collections',
            onPressed: () {},
            variant: PoselyButtonVariant.ghost,
            size: PoselyButtonSize.small,
          ),
        ),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 320,
                child: AppErrorView(
                  message: 'Could not load poses.',
                  onRetry: () => PoselyToast.show(
                    context,
                    message: 'Retrying…',
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: SizedBox(
                height: 320,
                child: AppLoadingView(message: 'Scoring pose…'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Skeletons ------------------------------------------------------------

  Widget _buildSkeletons() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Skeletons'),
        _gap,
        SkeletonGrid(itemCount: 4),
        _gap,
        Row(
          children: [
            ShimmerBox(
              width: 56,
              height: 56,
              borderRadius: AppRadius.brPill,
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 180, height: 14),
                SizedBox(height: AppSpacing.sm),
                ShimmerBox(width: 120, height: 14),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- Scores ---------------------------------------------------------------

  Widget _buildScores() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Scores'),
        _gap,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ScoreRing(score: 0.35, size: 88, label: 'Low'),
            ScoreRing(score: 0.72, size: 88, label: 'Mid'),
            ScoreRing(score: 0.95, size: 88, label: 'High'),
          ],
        ),
        _gap,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            ScorePill(label: 'Pose', score: 0.92),
            ScorePill(label: 'Lighting', score: 0.64),
            ScorePill(label: 'Composition', score: 0.41),
          ],
        ),
      ],
    );
  }
}

/// A single palette swatch: a rounded color block with the scale step
/// and hex value captioned beneath it.
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final argb = color.toARGB32().toRadixString(16).toUpperCase();
    final hex = '#${argb.substring(2)}';
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: AppColors.outline),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(name, style: AppTypography.caption),
        Text(hex, style: AppTypography.overline),
      ],
    );
  }
}

/// A gradient token preview: a rounded block filled with the gradient
/// and its token name captioned beneath it.
class _GradientSwatch extends StatelessWidget {
  const _GradientSwatch({required this.name, required this.gradient});

  final String name;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: AppColors.outline),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(name, style: AppTypography.caption),
      ],
    );
  }
}

/// A typography specimen: sample text in the given style with the token
/// name captioned beneath it.
class _TypeSample extends StatelessWidget {
  const _TypeSample({
    required this.token,
    required this.style,
    this.sample = 'Strike a pose',
  });

  final String token;
  final TextStyle style;
  final String sample;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sample, style: style),
        const SizedBox(height: AppSpacing.xxs),
        Text('AppTypography.$token', style: AppTypography.overline),
      ],
    );
  }
}

/// Interactive chip wrap with local multi-select state, so the gallery
/// can demonstrate selected and unselected chips side by side.
class _ChipShowcase extends StatefulWidget {
  const _ChipShowcase();

  @override
  State<_ChipShowcase> createState() => _ChipShowcaseState();
}

class _ChipShowcaseState extends State<_ChipShowcase> {
  static const Map<String, IconData> _filters = <String, IconData>{
    'Portrait': Icons.person_rounded,
    'Full body': Icons.accessibility_new_rounded,
    'Couple': Icons.people_rounded,
    'Outdoor': Icons.landscape_rounded,
    'Studio': Icons.light_rounded,
  };

  final Set<String> _selected = <String>{'Portrait'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in _filters.entries)
          PoselyChip(
            label: entry.key,
            icon: entry.value,
            selected: _selected.contains(entry.key),
            onTap: () => setState(() {
              if (!_selected.add(entry.key)) {
                _selected.remove(entry.key);
              }
            }),
          ),
      ],
    );
  }
}
