import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Central theme entrypoint for the StarNyx Obsidian Lumina visual baseline.
abstract final class AppTheme {
  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: AppColors.onSecondary,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiary,
      onTertiaryContainer: AppColors.onTertiary,
      error: AppColors.error,
      onError: AppColors.black,
      errorContainer: AppColors.error,
      onErrorContainer: AppColors.errorOnDark,
      surface: AppColors.surfaceLevel1,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surfaceLevel1,
      surfaceContainer: AppColors.surfaceLevel2,
      surfaceContainerHigh: AppColors.surfaceLevel3,
      surfaceContainerHighest: AppColors.surfaceLevel3,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderFocus,
      outlineVariant: AppColors.borderSubtle,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.primary,
    );

    const headline = AppFonts.headline;
    const body = AppFonts.body;
    const mono = AppFonts.mono;

    const textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontFamily: headline,
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -0.56, // -0.02em
      ),
      headlineMedium: TextStyle(
        fontFamily: headline,
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 30 / 24,
        letterSpacing: -0.48, // -0.02em
      ),
      headlineSmall: TextStyle(
        fontFamily: headline,
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 26 / 20,
        letterSpacing: -0.2, // -0.01em
      ),
      titleLarge: TextStyle(
        fontFamily: body,
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
      ),
      titleMedium: TextStyle(
        fontFamily: body,
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
      ),
      bodyLarge: TextStyle(
        fontFamily: body,
        color: AppColors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: body,
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: body,
        color: AppColors.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: mono,
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.48, // 0.04em
        fontFeatures: AppFonts.tabularFigures,
      ),
      labelMedium: TextStyle(
        fontFamily: mono,
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.48, // 0.04em
        fontFeatures: AppFonts.tabularFigures,
      ),
      labelSmall: TextStyle(
        fontFamily: mono,
        color: AppColors.textTertiary,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 14 / 10,
        letterSpacing: 0.6, // 0.06em
        fontFeatures: AppFonts.tabularFigures,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      shadowColor: AppColors.black,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: headline,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLevel1,
        margin: EdgeInsets.zero,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        space: 1,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.sheet,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLevel2,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: AppSpacing.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: const BorderSide(
            color: AppColors.borderFocus,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sheet,
        modalBackgroundColor: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.borderFocus,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLevel1,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.surfaceLevel3,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: mono,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: selected ? AppColors.textPrimary : AppColors.textTertiary,
            fontFeatures: AppFonts.tabularFigures,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textTertiary,
            size: 22,
          );
        }),
      ),
    );
  }
}
