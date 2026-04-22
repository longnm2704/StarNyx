import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Central theme entrypoint for the StarNyx cosmic visual baseline.
abstract final class AppTheme {
  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accentViolet,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.accentBlue,
          secondary: AppColors.accentPink,
          tertiary: AppColors.accentOrange,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceElevated,
          outline: AppColors.outline,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    final textTheme = baseTheme.textTheme.copyWith(
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 52,
        fontWeight: FontWeight.w800,
        height: 0.96,
        letterSpacing: -1.4,
      ),
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 29,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 17,
        height: 1.5,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.48,
      ),
      bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
        color: AppColors.textMuted,
        fontSize: 13,
        height: 1.36,
      ),
      labelSmall: baseTheme.textTheme.labelSmall?.copyWith(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      shadowColor: AppColors.black.withValues(alpha: 0.28),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outline.withValues(alpha: 0.4),
        space: 1,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceGlass,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: AppSpacing.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.4),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    );
  }
}
