import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Central theme entrypoint for the StarNyx Obsidian Lumina visual baseline.
abstract final class AppTheme {
  /// Cupertino pickers (time, date, wheel): mono digits with tabular figures
  /// so values don't jitter while scrolling.
  static const CupertinoThemeData cupertino = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: AppFonts.body,
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: AppFonts.mono,
        color: AppColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w500,
        fontFeatures: AppFonts.tabularFigures,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: AppFonts.mono,
        color: AppColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w500,
        fontFeatures: AppFonts.tabularFigures,
      ),
    ),
  );

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
      onErrorContainer: AppColors.black,
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

    // Every slot the app reads must be listed here: an unlisted slot falls
    // back to Material's default (platform) font instead of the bundled ones.
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        fontFamily: headline,
        color: AppColors.textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.72, // -0.02em
      ),
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
      titleSmall: TextStyle(
        fontFamily: body,
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
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

    // `labelLarge` stays mono for overlines; Material buttons read it for
    // their labels, so the button themes below swap in the body font.
    const buttonLabel = TextStyle(
      fontFamily: body,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 20 / 15,
    );
    const pill = StadiumBorder();
    const hairline = BorderSide(color: AppColors.borderSubtle);
    final sheetShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sheet),
      side: hairline,
    );

    return ThemeData(
      useMaterial3: true,
      cupertinoOverrideTheme: cupertino,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          textStyle: buttonLabel,
          shape: pill,
          minimumSize: const Size(AppSize.iconButton, AppSize.iconButton),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceLevel3,
          disabledForegroundColor: AppColors.textTertiary,
          textStyle: buttonLabel.copyWith(fontWeight: FontWeight.w700),
          shape: pill,
          minimumSize: const Size(AppSize.iconButton, AppSize.iconButton),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceLevel1,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textTertiary,
          textStyle: buttonLabel,
          shape: pill,
          side: hairline,
          minimumSize: const Size(AppSize.iconButton, AppSize.iconButton),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        barrierColor: AppColors.black.withValues(alpha: 0.78),
        shape: sheetShape,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: hairline,
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLevel2,
        selectedColor: AppColors.surfaceLevel3,
        disabledColor: AppColors.surfaceLevel1,
        side: hairline,
        shape: pill,
        showCheckmark: false,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 6,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceLevel3,
        ),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLevel3,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.sheet,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.fromBorderSide(hairline),
        ),
        textStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
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
      // Fields that keep the theme border are single-line (search, tags,
      // passphrases), so they are pills like the rest of the controls.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLevel2,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: hairline,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: hairline,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: BorderSide(color: AppColors.borderFocus, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          borderSide: BorderSide(color: AppColors.error, width: 1.4),
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
          side: BorderSide(color: AppColors.borderSubtle),
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
