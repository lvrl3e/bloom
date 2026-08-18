import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// BLOOM's ThemeData. Dark is the primary, production-facing theme;
/// light is provided for accessibility / user preference.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.bloomPink,
      onPrimary: AppColors.deepBlack,
      secondary: AppColors.softPink,
      onSecondary: AppColors.deepBlack,
      surface: AppColors.darkCharcoal,
      onSurface: AppColors.offWhite,
      error: AppColors.expenseRed,
      onError: AppColors.offWhite,
      outline: AppColors.borderDark,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.deepBlack,
      cardColor: AppColors.surfaceElevatedDark,
      dividerColor: AppColors.borderDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepBlack,
        foregroundColor: AppColors.offWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCharcoal,
        indicatorColor: AppColors.bloomPink.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.caption.copyWith(
            color: selected ? AppColors.bloomPink : AppColors.mutedGray,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.bloomPink : AppColors.mutedGray,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevatedDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.bloomPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.expenseRed),
        ),
        labelStyle: const TextStyle(color: AppColors.mutedGray),
        hintStyle: const TextStyle(color: AppColors.mutedGray),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevatedDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkCharcoal,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevatedDark,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.offWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.bloomPink,
      onPrimary: Colors.white,
      secondary: AppColors.softPink,
      onSecondary: AppColors.deepBlack,
      surface: Colors.white,
      onSurface: AppColors.deepBlack,
      error: AppColors.expenseRed,
      onError: Colors.white,
      outline: AppColors.borderLight,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.offWhite,
      cardColor: Colors.white,
      dividerColor: AppColors.borderLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.deepBlack,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.bloomPink.withValues(alpha: 0.14),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.caption.copyWith(
            color: selected ? AppColors.bloomPink : AppColors.mutedGray,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.bloomPink : AppColors.mutedGray,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.bloomPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.expenseRed),
        ),
        labelStyle: const TextStyle(color: AppColors.mutedGray),
        hintStyle: const TextStyle(color: AppColors.mutedGray),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepBlack,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bloomPink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.mutedGray.withValues(alpha: 0.3),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.bodyStrong,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.bodyStrong,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.bloomPink,
          textStyle: AppTextStyles.bodyStrong,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: AppColors.bloomPink.withValues(alpha: 0.16),
        labelStyle: AppTextStyles.caption.copyWith(color: scheme.onSurface),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.bloomPink,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: scheme.onSurface),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: scheme.onSurface),
        headlineMedium: AppTextStyles.headline.copyWith(color: scheme.onSurface),
        titleLarge: AppTextStyles.title.copyWith(color: scheme.onSurface),
        titleMedium: AppTextStyles.subtitle.copyWith(color: scheme.onSurface),
        bodyMedium: AppTextStyles.body.copyWith(color: scheme.onSurface),
        bodyLarge: AppTextStyles.bodyStrong.copyWith(color: scheme.onSurface),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
      ),
    );
  }
}
