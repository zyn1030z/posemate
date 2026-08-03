import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posely_ai/core/shared/extensions/build_context_ext.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/auth/presentation/controllers/auth_controller.dart';

/// Greeting row at the top of the Home screen.
///
/// A time-aware greeting caption over the user's name, with the small
/// aperture logo floating in a glass disc on the trailing edge. Guests
/// and signed-out sessions are addressed as 'Creator'.
class HomeHeader extends ConsumerWidget {
  /// Creates the home greeting header.
  const HomeHeader({super.key});

  /// Resolves the greeting for the given moment: before 12 it is
  /// 'Good morning', before 17 'Good afternoon', otherwise
  /// 'Good evening'.
  static String greetingFor(DateTime now) {
    if (now.hour < 12) {
      return 'Good morning';
    }
    if (now.hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final name =
        user == null || user.isGuest ? 'Creator' : user.displayName;
    final colors = context.posely;
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.w700);

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${greetingFor(DateTime.now())} 👋',
                style: AppTypography.bodyMuted.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.glassSurface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.glassStroke),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: PoselyLogo(size: 36),
          ),
        ),
      ],
    );
  }
}
