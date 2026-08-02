import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/router/app_router.dart';
import 'package:posely_ai/core/theme/app_theme.dart';
import 'package:posely_ai/core/theme/theme_mode_controller.dart';

/// Root widget of Posely AI.
///
/// Hosts the router-driven `MaterialApp` and applies the Posely theme.
/// Expects to be mounted inside the `ProviderScope` assembled by
/// `bootstrap`, where `appConfigProvider` is overridden.
class PoselyApp extends ConsumerWidget {
  /// Creates the root app widget.
  const PoselyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: PoselyTheme.light(),
      darkTheme: PoselyTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        if (!config.showDebugBanner || child == null) {
          return child ?? const SizedBox.shrink();
        }
        // Non-production builds carry a corner ribbon with the flavor name
        // so screenshots and bug reports are always attributable.
        return Banner(
          message: config.flavor.label.toUpperCase(),
          location: BannerLocation.topEnd,
          color: const Color(0xCC10B981),
          child: child,
        );
      },
    );
  }
}
