import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ── Shared shape theme ────────────────────────────────────
  static const _shapeTheme = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get dark {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.cream100,
      onPrimary: AppColors.textOnCream,
      primaryContainer: AppColors.cream60,
      onPrimaryContainer: AppColors.cream100,
      secondary: AppColors.cream60,
      onSecondary: AppColors.textOnCream,
      secondaryContainer: AppColors.paperWarm,
      onSecondaryContainer: AppColors.cream100,
      error: AppColors.dislike,
      onError: AppColors.textOnCream,
      surface: AppColors.inkMid,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.inkWarm,
      outline: AppColors.textTertiary,
      outlineVariant: AppColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.inkBase,
      fontFamily: 'Inter',

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.brandName,
        iconTheme: const IconThemeData(color: AppColors.cream100),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperAsh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(
            color: AppColors.borderStrong,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.dislike, width: 1),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream100,
          foregroundColor: AppColors.textOnCream,
          minimumSize: const Size(double.infinity, 52),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.buttonLarge,
          elevation: 0,
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cream100,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: AppColors.paperSage,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.cream60;
          }
          return AppColors.inkWarm;
        }),
      ),

      // List tile
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.cream100, size: 26);
          }
          return const IconThemeData(
            color: AppColors.textTertiary,
            size: 24,
          );
        }),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.inkMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.inkMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.textMuted,
      ),

      // Snack bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inkMid,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryContainerLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDE0FF),
      onPrimaryContainer: Color(0xFF250059),
      secondary: AppColors.secondaryContainer,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFD9E2),
      onSecondaryContainer: Color(0xFF3F001C),
      error: AppColors.errorLight,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighLight,
      outline: Color(0xFF7A7289),
      outlineVariant: AppColors.outlineVariantLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Inter',

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.brandName,
        iconTheme: IconThemeData(
          color: AppColors.primaryContainerLight,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryContainerLight,
            width: 1,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceLight.withOpacity(0.3),
        ),
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onSurfaceVariantLight,
          letterSpacing: 1.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainerLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.buttonLarge,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurfaceLight,
          side: const BorderSide(color: AppColors.outlineVariantLight),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryContainerLight,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Card — fixed: CardThemeData (not CardTheme)
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: _shapeTheme,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.06),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariantLight,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF7A7289);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainerLight;
          }
          return AppColors.outlineVariantLight;
        }),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighLight,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}