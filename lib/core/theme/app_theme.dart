import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const _shapeTheme = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  /// Primary theme — light cream paper doodle (Stitch).
  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.cream100,
      onPrimary: AppColors.textOnCream,
      primaryContainer: AppColors.cream60,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.pastelBlue,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.paperWarm,
      onSecondaryContainer: AppColors.textPrimary,
      error: AppColors.dislike,
      onError: AppColors.white,
      surface: AppColors.inkMid,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.paperAsh,
      outline: AppColors.textTertiary,
      outlineVariant: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.inkBase,
      fontFamily: 'Nunito',

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.brandName,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperAsh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDefault, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDefault, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.borderStrong,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dislike, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream100,
          foregroundColor: AppColors.textOnCream,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderStrong, width: 2),
          ),
          textStyle: AppTextStyles.buttonLarge,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.paperSage,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderCard, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.white;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cream100;
          return AppColors.inkWarm;
        }),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.textPrimary, size: 26);
          }
          return const IconThemeData(
            color: AppColors.textTertiary,
            size: 24,
          );
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.inkMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderCard, width: 2),
        ),
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.inkMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.textMuted,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dark immersive theme (story viewer / rare full-bleed moments).
  static ThemeData get dark {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.cream100,
      onPrimary: AppColors.textOnCream,
      primaryContainer: AppColors.cream60,
      onPrimaryContainer: AppColors.inkDeep,
      secondary: AppColors.pastelBlue,
      onSecondary: AppColors.inkDeep,
      secondaryContainer: Color(0xFF2C2920),
      onSecondaryContainer: AppColors.textOnDark,
      error: AppColors.dislike,
      onError: AppColors.white,
      surface: Color(0xFF1C1A17),
      onSurface: AppColors.textOnDark,
      surfaceContainerHighest: Color(0xFF2C2920),
      outline: Color(0xFF9A8B78),
      outlineVariant: Color(0xFF6B5F50),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.inkDeep,
      fontFamily: 'Nunito',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.brandName.copyWith(
          color: AppColors.textOnDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.cream100),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2E3328),
        elevation: 0,
        shape: _shapeTheme,
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1C1A17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
