import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One type system.
/// Display / brand / titles: bundled Comico.
/// Body / labels / fields: Be Vietnam Pro.
/// Every style falls back to system color-emoji so stickers render.
class AppTextStyles {
  AppTextStyles._();

  static const String displayFamily = 'Comico';

  static const List<String> emojiFallback = [
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Segoe UI Emoji',
  ];

  static TextStyle emojiOnly({double size = 22}) => const TextStyle(
        fontFamily: 'Apple Color Emoji',
        fontFamilyFallback: [
          'Noto Color Emoji',
          'Segoe UI Emoji',
        ],
      ).copyWith(fontSize: size, height: 1.1);

  static TextStyle _display({
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    FontStyle? fontStyle,
  }) =>
      TextStyle(
        fontFamily: displayFamily,
        fontFamilyFallback: emojiFallback,
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  static TextStyle _body({
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.beVietnamPro(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
      ).copyWith(fontFamilyFallback: [
        ...emojiFallback,
        ...?GoogleFonts.beVietnamPro().fontFamilyFallback,
      ]);

  static final TextStyle displayXl = _display(
    size: 40,
    weight: FontWeight.w400,
    height: 46,
    letterSpacing: -0.6,
  );

  static final TextStyle displayLg = _display(
    size: 28,
    weight: FontWeight.w400,
    height: 34,
    letterSpacing: -0.4,
  );

  static final TextStyle displayMd = _display(
    size: 22,
    weight: FontWeight.w400,
    height: 28,
  );

  static final TextStyle title1 = _display(
    size: 24,
    weight: FontWeight.w400,
    height: 30,
    letterSpacing: -0.3,
  );

  static final TextStyle title2 = _display(
    size: 22,
    weight: FontWeight.w400,
    height: 28,
  );

  static final TextStyle subtitle = _body(
    size: 16,
    weight: FontWeight.w500,
    height: 24,
  );

  static final TextStyle bodyLarge = _body(
    size: 16,
    weight: FontWeight.w500,
    height: 24,
  );

  static final TextStyle bodyMedium = _body(
    size: 14,
    weight: FontWeight.w400,
    height: 20,
  );

  static final TextStyle bodySmall = _body(
    size: 13,
    weight: FontWeight.w400,
    height: 18,
  );

  static final TextStyle labelLarge = _body(
    size: 14,
    weight: FontWeight.w600,
    height: 20,
  );

  static final TextStyle labelMedium = _body(
    size: 13,
    weight: FontWeight.w600,
    height: 18,
  );

  static final TextStyle labelSmall = _body(
    size: 12,
    weight: FontWeight.w600,
    height: 16,
    letterSpacing: 0.4,
  );

  static final TextStyle timestamp = _body(
    size: 12,
    weight: FontWeight.w500,
    height: 16,
    letterSpacing: 0.2,
  );

  static final TextStyle doodleAccent = _display(
    size: 14,
    weight: FontWeight.w400,
    height: 18,
  );

  static final TextStyle brandName = _display(
    size: 26,
    weight: FontWeight.w400,
    height: 30,
    letterSpacing: -0.3,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle quote = _display(
    size: 22,
    weight: FontWeight.w400,
    height: 28,
    letterSpacing: -0.2,
  );

  static final TextStyle heroTitle = displayXl;
  static final TextStyle pageTitle = displayLg;
  static final TextStyle sectionTitle = title1;
  static final TextStyle username = _body(
    size: 16,
    weight: FontWeight.w600,
    height: 22,
  );
  static final TextStyle statNumber = _display(
    size: 28,
    weight: FontWeight.w400,
    height: 32,
  );
  static final TextStyle statLabel = _body(
    size: 12,
    weight: FontWeight.w600,
    height: 16,
    letterSpacing: 0.2,
  );
  static final TextStyle buttonLarge = _body(
    size: 13,
    weight: FontWeight.w600,
    height: 16,
    letterSpacing: 0.4,
  );
  static final TextStyle buttonMedium = buttonLarge;

  static TextStyle sectionLabel({Color? color}) => _body(
        size: 12,
        weight: FontWeight.w600,
        height: 16,
        letterSpacing: 0.4,
      ).copyWith(color: color);

  static TextTheme materialTextTheme([TextTheme? base]) {
    final seed = base ?? const TextTheme();
    return seed.copyWith(
      displayLarge: displayXl,
      displayMedium: displayLg,
      displaySmall: title1,
      headlineLarge: displayLg,
      headlineMedium: displayMd,
      headlineSmall: title2,
      titleLarge: title1,
      titleMedium: username,
      titleSmall: labelLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
