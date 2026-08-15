import 'package:flutter/material.dart';

/// Organic Tactile tokens from `ui_ux/stitch_home_feed`.
/// Legacy names are mapped so existing call sites flip with the rebrand.
class AppColors {
  AppColors._();

  // ── Organic Tactile (light canvas) ────────────────────────────────
  static const Color surface = Color(0xFFF4F2EE);
  static const Color surfaceDim = Color(0xFFDDDAD1);
  static const Color surfaceBright = Color(0xFFF4F2EE);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFECEAE5);
  static const Color surfaceContainer = Color(0xFFE8E6E0);
  static const Color surfaceHigh = Color(0xFFE4E2DC);
  static const Color surfaceHighest = Color(0xFFDCDAD4);

  static const Color onSurface = Color(0xFF1A1A18);
  static const Color onSurfaceVariant = Color(0xFF4A4A46);

  static const Color primary = Color(0xFF2F2F2C);
  static const Color onPrimary = Color(0xFFF4F2EE);
  static const Color primaryContainer = Color(0xFF3D4A43);
  static const Color onPrimaryContainer = Color(0xFFF4F2EE);
  static const Color primaryFixed = Color(0xFFD8D6D0);

  static const Color secondary = Color(0xFF785A00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED16E);
  static const Color onSecondaryContainer = Color(0xFF775900);
  static const Color secondaryFixed = Color(0xFFFFDF9D);

  static const Color tertiary = Color(0xFF486177);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF829CB4);
  static const Color tertiaryFixed = Color(0xFFCBE6FF);

  static const Color outline = Color(0xFF707973);
  static const Color outlineVariant = Color(0xFFC0C9C2);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color inverseSurface = Color(0xFF31312B);
  static const Color inverseOnSurface = Color(0xFFF4F0E8);

  /// Floating dock from the Stitch screens (cool slate, not inverse brown).
  static const Color navDock = Color(0xFF2C3A45);
  static const Color navActive = Color(0xFFFED16E);

  static const Color quoteWash = Color(0xFFE8E2D4);
  static const Color splitMint = Color(0xFF8FBFB0);

  static const Color toolPhoto = Color(0xFFB5EFD2);
  static const Color toolCamera = Color(0xFFCBE6FF);
  static const Color toolSticker = Color(0xFFFFDF9D);
  static const Color toolDoodle = Color(0xFFFFDAD6);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color like = Color(0xFF316852);
  static const Color dislike = Color(0xFFBA1A1A);
  static const Color comment = Color(0xFF486177);
  static const Color heart = Color(0xFFBA1A1A);
  static const Color reply = Color(0xFF316852);
  static const Color mention = Color(0xFF6DA58B);

  static const Color notifFollow = Color(0xFF6DA58B);
  static const Color notifLike = Color(0xFF316852);
  static const Color notifDislike = Color(0xFFBA1A1A);
  static const Color notifComment = Color(0xFF486177);
  static const Color notifReply = Color(0xFF316852);

  static const Color strokeOnDark = Color(0xFFF4F0E8);
  static const Color strokeOnLight = Color(0xFF1C1C17);
  static const Color frogFill = Color(0xFF316852);
  static const Color ghostFill = Color(0xFFF4F0E8);

  // ── Ink / paper aliases (legacy names → tactile light) ────────────
  static const Color inkDeep = Color(0xFF1C1C17);
  static const Color inkBase = surface;
  static const Color inkMid = surfaceLowest;
  static const Color inkWarm = surfaceHigh;

  static const Color paperSage = surfaceLowest;
  static const Color paperClay = surfaceContainer;
  static const Color paperAsh = surfaceLow;
  static const Color paperWarm = secondaryContainer;

  static const Color cream100 = primary;
  static const Color cream80 = primaryContainer;
  static const Color cream60 = secondaryContainer;
  static const Color cream08 = Color(0x14316852);

  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textTertiary = outline;
  static const Color textOnCream = onPrimary;
  static const Color textMuted = outline;

  static const Color borderSubtle = outlineVariant;
  static const Color borderDefault = outline;
  static const Color borderStrong = onSurface;

  static const double stroke = 1.5;

  static List<BoxShadow> shadowCard = const [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(3, 3),
      blurRadius: 0,
    ),
  ];
  static List<BoxShadow> shadowFloat = const [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];
  static List<BoxShadow> haloPress = const [
    BoxShadow(color: Color(0x22316852), blurRadius: 0, offset: Offset(1, 1)),
  ];
  static List<BoxShadow> haloStory = const [];
  static List<BoxShadow> haloLike = const [];
  static List<BoxShadow> haloDislike = const [];

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF316852), Color(0xFF6DA58B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color inversePrimary = Color(0xFF99D3B7);
  static const Color onSurfaceDark = onSurface;
  static const Color onSurfaceVariantDark = onSurfaceVariant;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color backgroundDark = surface;
  static const Color surfaceContainerLow = surfaceLow;
  static const Color surfaceContainerHigh = surfaceHigh;
  static const Color errorLight = error;

  static const Color backgroundLight = surface;
  static const Color surfaceLight = surfaceLowest;
  static const Color surfaceContainerLight = surfaceLow;
  static const Color surfaceContainerHighLight = surfaceHigh;
  static const Color onSurfaceLight = onSurface;
  static const Color onSurfaceVariantLight = onSurfaceVariant;
  static const Color outlineVariantLight = outlineVariant;
  static const Color primaryContainerLight = primary;

  static Color bg(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color card(BuildContext context) => surfaceLowest;
  static Color cardHigh(BuildContext context) => surfaceHigh;
  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSecondaryStyle(BuildContext context) => onSurfaceVariant;
  static Color input(BuildContext context) => surfaceLow;
  static Color border(BuildContext context) => outlineVariant;
}
