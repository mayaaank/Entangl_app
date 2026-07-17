import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Ink Background Layers ─────────────────────────────────────────
  // Named "ink" not "surface" — these are warm, like paper soaked in ink
  static const Color inkDeep    = Color(0xFF0E0D0B); // Story viewer, immersive overlay
  static const Color inkBase    = Color(0xFF141210); // Main scaffold background
  static const Color inkMid     = Color(0xFF1C1A17); // Sheets, modals, nav bar
  static const Color inkWarm    = Color(0xFF2C2920); // Pressed/active state on tappable rows

  // ── Paper Card Surfaces ───────────────────────────────────────────
  // Each surface has a distinct warm tint — not the same grey at different opacities
  static const Color paperSage  = Color(0xFF2E3328); // Post cards — muted olive
  static const Color paperClay  = Color(0xFF352D24); // Notification tiles — terracotta-brown
  static const Color paperAsh   = Color(0xFF28261F); // Input fields — neutral warm grey
  static const Color paperWarm  = Color(0xFF3A3328); // Selected / active state on cards

  // ── Cream (Primary Action Surface) ────────────────────────────────
  // Replaces gradient on all CTAs. Stamp-quality, zine-authentic.
  static const Color cream100   = Color(0xFFFFF8E8); // Button fill, story ring solid
  static const Color cream80    = Color(0xFFF5EDD4); // Button press state, story ring active
  static const Color cream60    = Color(0xFFE8DDB8); // Nav active dot, secondary accents
  static const Color cream08    = Color(0x14FFF8E8); // Unviewed story ring, subtle tint

  // ── Text ──────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0E8D8); // Warm offwhite — all primary text
  static const Color textSecondary = Color(0xFFA89880); // Warm clay mid — secondary text
  // Raised from #6B5F50 for AA-ish contrast on ink backgrounds (timestamps / hints).
  static const Color textTertiary  = Color(0xFF9A8B78); // Warm clay mid-light — timestamps
  static const Color textOnCream   = Color(0xFF1A1610); // Near-black — text ON cream buttons
  static const Color textMuted     = Color(0xFF6B5F50); // Disabled / placeholder (was tertiary)

  // ── Semantic Reaction Colors (Ink Pens) ───────────────────────────
  // Each is a different ink color in a doodle set. Muted, botanical, distinct.
  static const Color like       = Color(0xFF7CB87A); // Fern green — botanical, not neon
  static const Color dislike    = Color(0xFFC4714A); // Terracotta — earthy, not alarming
  static const Color comment    = Color(0xFF6B8FA8); // Dusty slate — handwritten biro
  static const Color heart      = Color(0xFFB8788A); // Warm mauve — personal, not fashion
  static const Color reply      = Color(0xFF7CB87A); // Same as like (green = positive)
  static const Color mention    = Color(0xFF8FA882); // Sage green — frog world, not tech

  // ── Notification Type Colors ──────────────────────────────────────
  static const Color notifFollow  = Color(0xFF8FA882); // Sage — welcoming
  static const Color notifLike    = Color(0xFF7CB87A); // Fern — positive
  static const Color notifDislike = Color(0xFFC4714A); // Terracotta — notable
  static const Color notifComment = Color(0xFF6B8FA8); // Dusty slate — informational
  static const Color notifReply   = Color(0xFF7CB87A); // Fern — same as like

  // ── Doodle Stroke Colors ──────────────────────────────────────────
  static const Color strokeOnDark  = Color(0xFFF0E8D8); // Cream ink on dark surfaces
  static const Color strokeOnLight = Color(0xFF1E1A14); // Warm near-black on light
  static const Color frogFill      = Color(0xFF4A7A3A); // Muted forest green
  static const Color ghostFill     = Color(0xFFF0E8D8); // Ghost IS the paper — same as textPrimary

  // ── Borders ───────────────────────────────────────────────────────
  static const Color borderSubtle  = Color(0x12FFF5DC); // 7% warm cream — default border
  static const Color borderDefault = Color(0x1EFFF5DC); // 12% warm cream — hover/focus
  static const Color borderStrong  = Color(0x38FFF5DC); // 22% warm cream — active border

  // ── Shadow System ─────────────────────────────────────────────────
  // NO colored glows. Depth is weight, not color.
  static List<BoxShadow> shadowCard = [
    const BoxShadow(color: Color(0x73000000), blurRadius: 12, offset: Offset(0, 2)),
    const BoxShadow(color: Color(0x4D000000), blurRadius: 3,  offset: Offset(0, 1)),
  ];
  static List<BoxShadow> shadowFloat = [
    const BoxShadow(color: Color(0x8C000000), blurRadius: 24, offset: Offset(0, 4)),
    const BoxShadow(color: Color(0x59000000), blurRadius: 6,  offset: Offset(0, 1)),
  ];

  // ── Warm Halos (Restrained — lamp, not laser) ─────────────────────
  // Used sparingly: button press only, story ring pulse only
  static List<BoxShadow> haloPress = [
    const BoxShadow(color: Color(0x29FFF8E8), blurRadius: 16), // Cream halo on button tap
  ];
  static List<BoxShadow> haloStory = [
    const BoxShadow(color: Color(0x38FFF8E8), blurRadius: 14), // Cream throb on story ring
  ];
  static List<BoxShadow> haloLike = [
    const BoxShadow(color: Color(0x4D7CB87A), blurRadius: 12), // Fern — quiet, botanical
  ];
  static List<BoxShadow> haloDislike = [
    const BoxShadow(color: Color(0x4DC4714A), blurRadius: 12), // Terracotta — warm
  ];

  // ── Brand Gradient (RESERVED — splash icon treatment only) ────────
  // Do NOT apply to buttons, text, nav, story rings, or any interactive element.
  // This gradient's rarity is what makes it meaningful.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color gradientStart = Color(0xFF6D28D9);
  static const Color gradientEnd   = Color(0xFFDB2777);
  static const LinearGradient primaryGradient = brandGradient;

  // ── Legacy mappings for compatibility ──────────────────────────────
  static const Color primary = cream100;
  static const Color primaryContainer = cream60;
  static const Color primaryContainerLight = cream60;
  static const Color onPrimary = textOnCream;
  static const Color onPrimaryContainer = cream100;
  static const Color inversePrimary = cream80;

  static const Color secondary = cream60;
  static const Color secondaryContainer = paperWarm;
  static const Color onSecondary = textOnCream;
  static const Color onSecondaryContainer = cream100;

  static const Color onSurfaceDark = textPrimary;
  static const Color onSurfaceVariantDark = textSecondary;
  static const Color outline = textTertiary;
  static const Color outlineVariant = textMuted;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color backgroundDark = inkBase;
  static const Color surfaceContainerLow = inkBase;
  static const Color surfaceContainerHigh = inkMid;
  static const Color error = dislike;
  static const Color errorContainer = dislike;
  static const Color onError = textOnCream;
  static const Color errorLight = dislike;

  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF3F0F5);
  static const Color surfaceContainerHighLight = Color(0xFFEDE8F0);
  static const Color onSurfaceLight = Color(0xFF111111);
  static const Color onSurfaceVariantLight = Color(0xFF555060);
  static const Color outlineVariantLight = Color(0xFFE5E5E5);

  // Theme-aware helpers
  static Color bg(BuildContext context) => inkBase;
  static Color card(BuildContext context) => paperSage;
  static Color cardHigh(BuildContext context) => inkMid;
  static Color text(BuildContext context) => textPrimary;
  static Color textSecondaryStyle(BuildContext context) => textSecondary;
  static Color input(BuildContext context) => paperAsh;
  static Color border(BuildContext context) => borderSubtle;
}
