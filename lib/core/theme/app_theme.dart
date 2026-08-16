import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'entangl_colors.dart';

class AppTheme {
  AppTheme._();

  static const _subThemes = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    defaultRadius: 16,
    thickBorderWidth: 1.5,
    thinBorderWidth: 1.5,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorFocusedHasBorder: true,
    inputDecoratorUnfocusedHasBorder: true,
    inputDecoratorRadius: 16,
    elevatedButtonRadius: 16,
    outlinedButtonRadius: 16,
    filledButtonRadius: 16,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  );

  static ThemeData get light => _build(Brightness.light, EntanglColors.light);

  static ThemeData get dark => _build(Brightness.dark, EntanglColors.dark);

  static ThemeData _build(Brightness brightness, EntanglColors palette) {
    final isDark = brightness == Brightness.dark;
    final scheme = FlexSchemeColor(
      primary: palette.primary,
      primaryContainer: palette.primaryContainer,
      secondary: palette.onSurfaceVariant,
      secondaryContainer: palette.surfaceHigh,
      tertiary: palette.onSurfaceVariant,
      tertiaryContainer: palette.surfaceHigh,
      appBarColor: palette.surface,
      error: palette.error,
      errorContainer: palette.surfaceHigh,
    );

    final base = isDark
        ? FlexThemeData.dark(
            colors: scheme,
            scaffoldBackground: palette.surface,
            surface: palette.surface,
            useMaterial3: true,
            fontFamily: GoogleFonts.beVietnamPro().fontFamily,
            subThemesData: _subThemes,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          )
        : FlexThemeData.light(
            colors: scheme,
            scaffoldBackground: palette.surface,
            surface: palette.surface,
            useMaterial3: true,
            fontFamily: GoogleFonts.beVietnamPro().fontFamily,
            subThemesData: _subThemes,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          );

    final textTheme = AppTextStyles.materialTextTheme(base.textTheme).apply(
      bodyColor: palette.onSurface,
      displayColor: palette.onSurface,
    );

    return base.copyWith(
      extensions: [palette],
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: palette.surface,
      colorScheme: base.colorScheme.copyWith(
        surface: palette.surface,
        onSurface: palette.onSurface,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        error: palette.error,
        outline: palette.outline,
        outlineVariant: palette.outlineVariant,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: AppTextStyles.brandName.copyWith(color: palette.primary),
        iconTheme: IconThemeData(color: palette.onSurfaceVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.onSurface, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: palette.onSurfaceVariant,
        ),
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: palette.onSurfaceVariant,
        ),
        floatingLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: palette.onSurface,
        ),
        prefixIconColor: palette.onSurfaceVariant,
        suffixIconColor: palette.onSurfaceVariant,
        errorStyle: AppTextStyles.bodySmall.copyWith(color: palette.error),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primary,
        selectionColor: palette.primary.withValues(alpha: 0.28),
        selectionHandleColor: palette.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.onSurface, width: 1.5),
          ),
          textStyle: AppTextStyles.buttonLarge,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.onSurface,
          side: BorderSide(color: palette.onSurface, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.outline, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: palette.outlineVariant,
        thickness: 1.5,
        space: 1.5,
      ),
      iconTheme: IconThemeData(color: palette.onSurface),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.onPrimary;
          return palette.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.surfaceHigh;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.outline, width: 1.5),
        ),
        titleTextStyle: AppTextStyles.title2.copyWith(color: palette.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: palette.outline,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? palette.surfaceHigh : AppColors.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: palette.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
