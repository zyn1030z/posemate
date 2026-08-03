// CupertinoPageTransitionsBuilder moved to the cupertino library in 3.44.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:posely_ai/core/theme/theme_extensions.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';

/// Material 3 theme factory for Posely AI.
///
/// The light theme is the flagship experience — off-white surfaces,
/// vibrant blue accents, and soft elevation shadows. The dark theme is a
/// fully specified counterpart for system-driven brightness switching.
abstract final class PoselyTheme {
  static const RoundedRectangleBorder _pillShape = RoundedRectangleBorder(
    borderRadius: AppRadius.brPill,
  );

  static const Size _buttonMinSize = Size(64, 52);

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  /// Builds the flagship light theme.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.blue100,
      onPrimaryContainer: AppColors.blue900,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnPrimary,
      tertiary: AppColors.info,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.surfaceElevated,
      surfaceContainerHigh: AppColors.surfaceElevated,
      surfaceContainerHighest: AppColors.surfaceHighest,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
      outlineVariant: AppColors.surfaceHighest,
      error: AppColors.error,
      onError: AppColors.surface,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitions,
      textTheme: AppTypography.textTheme(
        AppColors.textPrimary,
        AppColors.textSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sectionTitle.copyWith(
          color: scheme.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.surfaceHighest,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: _buttonMinSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.surfaceHighest,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: _buttonMinSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textTertiary,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: _buttonMinSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.primary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: AppRadius.cardShape,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassWhite,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        side: const BorderSide(color: AppColors.outline),
        shape: const StadiumBorder(),
        labelStyle: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        showCheckmark: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.surfaceHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        titleTextStyle: AppTypography.sectionTitle.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMuted.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        contentTextStyle: AppTypography.body.copyWith(
          color: scheme.onSurface,
        ),
        actionTextColor: AppColors.primary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            final selected = states.contains(WidgetState.selected);
            return AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.primary : AppColors.textSecondary,
            );
          },
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
        labelStyle: AppTypography.button.copyWith(fontSize: 15),
        unselectedLabelStyle: AppTypography.button.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceHighest,
        circularTrackColor: AppColors.surfaceHighest,
        refreshBackgroundColor: AppColors.surface,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceHighest,
        thumbColor: AppColors.surface,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? AppColors.surface
                : AppColors.textTertiary;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.surfaceHighest;
          },
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll<double>(3),
        radius: Radius.circular(3),
        thumbColor: WidgetStatePropertyAll<Color>(Color(0x1A000000)),
        crossAxisMargin: AppSpacing.xxs,
      ),
      extensions: const <ThemeExtension<dynamic>>[PoselyColors.light()],
    );
  }

  /// Builds the dark theme counterpart.
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.blue900,
      onPrimaryContainer: AppColors.blue100,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnPrimary,
      tertiary: AppColors.info,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerLowest: AppColors.backgroundDark,
      surfaceContainerLow: AppColors.surfaceDark,
      surfaceContainer: AppColors.surfaceElevatedDark,
      surfaceContainerHigh: AppColors.surfaceElevatedDark,
      surfaceContainerHighest: AppColors.surfaceHighestDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.surfaceHighestDark,
      error: AppColors.error,
      onError: AppColors.textPrimaryDark,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      canvasColor: AppColors.backgroundDark,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitions,
      textTheme: AppTypography.textTheme(
        AppColors.textPrimaryDark,
        AppColors.textSecondaryDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sectionTitle.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.surfaceHighestDark,
          disabledForegroundColor: AppColors.textTertiaryDark,
          minimumSize: _buttonMinSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.surfaceHighestDark,
          disabledForegroundColor: AppColors.textTertiaryDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: _buttonMinSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          disabledForegroundColor: AppColors.textTertiaryDark,
          side: const BorderSide(color: AppColors.glassDarkStroke),
          minimumSize: _buttonMinSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiaryDark,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: _pillShape,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedDark,
        hintStyle: AppTypography.body.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: AppRadius.cardShape,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outlineDark.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassDark,
        selectedColor: AppColors.primary.withValues(alpha: 0.24),
        side: const BorderSide(color: AppColors.glassDarkStroke),
        shape: const StadiumBorder(),
        labelStyle: AppTypography.caption.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        showCheckmark: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.surfaceHighestDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevatedDark,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        titleTextStyle: AppTypography.sectionTitle.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMuted.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevatedDark,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        contentTextStyle: AppTypography.body.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        actionTextColor: AppColors.blue400,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            final selected = states.contains(WidgetState.selected);
            return AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? AppColors.textPrimaryDark
                  : AppColors.textTertiaryDark,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.blue400 : AppColors.textSecondaryDark,
            );
          },
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.textPrimaryDark,
        unselectedLabelColor: AppColors.textTertiaryDark,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
        labelStyle: AppTypography.button.copyWith(fontSize: 15),
        unselectedLabelStyle: AppTypography.button.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceHighestDark,
        circularTrackColor: AppColors.surfaceHighestDark,
        refreshBackgroundColor: AppColors.surfaceElevatedDark,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceHighestDark,
        thumbColor: AppColors.textPrimaryDark,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? AppColors.textPrimaryDark
                : AppColors.textSecondaryDark;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.surfaceHighestDark;
          },
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll<double>(3),
        radius: Radius.circular(3),
        thumbColor: WidgetStatePropertyAll<Color>(Color(0x2EFFFFFF)),
        crossAxisMargin: AppSpacing.xxs,
      ),
      extensions: const <ThemeExtension<dynamic>>[PoselyColors.dark()],
    );
  }
}
