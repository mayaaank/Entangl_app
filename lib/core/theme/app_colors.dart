import 'package:flutter/material.dart';

/// Entangl design tokens — Stitch "paper doodle" system (project 730203883861208133).
///
/// Visual language: warm cream paper, white cards with ink outlines,
/// soft pastel action chips, playful rounded geometry.
class AppColors {
  AppColors._();

  // ── Paper Background Layers ───────────────────────────────────────
  // Named "ink*" for historical API stability; values are light paper.
  static const Color inkDeep = Color(0xFF1A1610); // Immersive overlays (story viewer)
  static const Color inkBase = Color(0xFFFDF8F0); // Main scaffold — cream paper
  static const Color inkMid = Color(0xFFFFFFFF); // Sheets, modals, cards
  static const Color inkWarm = Color(0xFFF3EBE0); // Pressed / muted surface

  // ── Card Surfaces ─────────────────────────────────────────────────
  static const Color paperSage = Color(0xFFFFFFFF); // Post cards — pure white
  static const Color paperClay = Color(0xFFFFF9F2); // Notification tiles
  static const Color paperAsh = Color(0xFFF7F0E6); // Input fields
  static const Color paperWarm = Color(0xFFFFF3DC); // Selected / active cards
  static const Color paperGrid = Color(0xFFFAF4EA); // Create-post doodle canvas

  // ── Accent Yellow (Primary CTA) ───────────────────────────────────
  // Stitch: Post / Following / Create FAB
  static const Color cream100 = Color(0xFFF0C84A); // Solid yellow CTA
  static const Color cream80 = Color(0xFFE8B82E); // Pressed yellow
  static const Color cream60 = Color(0xFFF5D76E); // Soft yellow (Following idle)
  static const Color cream08 = Color(0x28F0C84A); // Subtle yellow tint

  // ── Pastel Action Palette (Stitch feed chips) ─────────────────────
  static const Color pastelPink = Color(0xFFFFB6C8); // Like chip fill
  static const Color pastelMint = Color(0xFFA8E6CF); // Comment chip fill
  static const Color pastelBlue = Color(0xFFA8D4F0); // Share / Message chip
  static const Color pastelYellow = Color(0xFFF5E08A); // Bookmark chip
  static const Color pastelLavender = Color(0xFFD4C4F0); // Extra accent
  static const Color pastelPeach = Color(0xFFFFD0B5); // Extra accent
  static const Color pastelRose = Color(0xFFF5C0C8); // Color swatch
  static const Color pastelSky = Color(0xFFB8DCF5); // Color swatch

  // ── Text ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1610); // Near-black ink
  static const Color textSecondary = Color(0xFF6B6560); // Warm mid-gray
  static const Color textTertiary = Color(0xFF9A9288); // Timestamps / hints
  static const Color textOnCream = Color(0xFF1A1610); // Text on yellow CTAs
  static const Color textMuted = Color(0xFFB0A89C); // Disabled / placeholder
  static const Color textOnDark = Color(0xFFF0E8D8); // Text on inkDeep overlays

  // ── Semantic Reaction Colors ──────────────────────────────────────
  static const Color like = Color(0xFFE86B8A); // Heart pink
  static const Color dislike = Color(0xFFC4714A); // Terracotta
  static const Color comment = Color(0xFF4A9B7A); // Mint green text
  static const Color heart = Color(0xFFE86B8A);
  static const Color reply = Color(0xFF4A9B7A);
  static const Color mention = Color(0xFF6B8FA8);

  // ── Notification Type Colors ──────────────────────────────────────
  static const Color notifFollow = Color(0xFF6BA88A);
  static const Color notifLike = Color(0xFFE86B8A);
  static const Color notifDislike = Color(0xFFC4714A);
  static const Color notifComment = Color(0xFF4A9B7A);
  static const Color notifReply = Color(0xFF4A9B7A);

  // ── Doodle Stroke Colors ──────────────────────────────────────────
  static const Color strokeInk = Color(0xFF1A1610); // Thick doodle outline
  static const Color strokeOnDark = Color(0xFFF0E8D8);
  static const Color strokeOnLight = Color(0xFF1A1610);
  static const Color frogFill = Color(0xFF6BB86A);
  static const Color ghostFill = Color(0xFFFFFFFF);

  // ── Borders ───────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0x1A1A1610); // 10% ink
  static const Color borderDefault = Color(0x331A1610); // 20% ink
  static const Color borderStrong = Color(0xFF1A1610); // Full ink outline
  static const Color borderCard = Color(0xFF1A1610); // 2px card stroke

  // ── Shadow System (soft paper depth) ──────────────────────────────
  static List<BoxShadow> shadowCard = [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 0,
      offset: Offset(0, 3),
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowFloat = [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowDoodle = [
    const BoxShadow(
      color: Color(0x1A1A1610),
      blurRadius: 0,
      offset: Offset(2, 3),
    ),
  ];

  // ── Halos ─────────────────────────────────────────────────────────
  static List<BoxShadow> haloPress = [
    const BoxShadow(color: Color(0x33F0C84A), blurRadius: 12),
  ];
  static List<BoxShadow> haloStory = [
    const BoxShadow(color: Color(0x33F0C84A), blurRadius: 10),
  ];
  static List<BoxShadow> haloLike = [
    const BoxShadow(color: Color(0x40FFB6C8), blurRadius: 10),
  ];
  static List<BoxShadow> haloDislike = [
    const BoxShadow(color: Color(0x40C4714A), blurRadius: 10),
  ];

  // ── Brand Gradient (splash / rare moments only) ───────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFF0C84A), Color(0xFFFFB6C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color gradientStart = Color(0xFFF0C84A);
  static const Color gradientEnd = Color(0xFFFFB6C8);
  static const LinearGradient primaryGradient = brandGradient;

  // ── Story ring pastels (cycled) ───────────────────────────────────
  static const List<Color> storyRingPastels = [
    Color(0xFFFFB6C8), // pink
    Color(0xFFF5E08A), // yellow
    Color(0xFFA8D4F0), // blue
    Color(0xFFA8E6CF), // mint
    Color(0xFFD4C4F0), // lavender
    Color(0xFFFFD0B5), // peach
  ];

  // ── Doodle color swatches (create post) ───────────────────────────
  static const List<Color> doodleSwatches = [
    Color(0xFFF5C0C8),
    Color(0xFFF5E08A),
    Color(0xFFB8DCF5),
    Color(0xFFA8E6CF),
    Color(0xFFD4C4F0),
    Color(0xFFFFD0B5),
    Color(0xFFF7F0E6),
  ];

  // ── Legacy / Material mappings ────────────────────────────────────
  static const Color primary = cream100;
  static const Color primaryContainer = cream60;
  static const Color primaryContainerLight = cream60;
  static const Color onPrimary = textOnCream;
  static const Color onPrimaryContainer = textPrimary;
  static const Color inversePrimary = cream80;

  static const Color secondary = pastelBlue;
  static const Color secondaryContainer = paperWarm;
  static const Color onSecondary = textPrimary;
  static const Color onSecondaryContainer = textPrimary;

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
  static const Color onError = white;
  static const Color errorLight = dislike;

  static const Color backgroundLight = inkBase;
  static const Color surfaceLight = inkMid;
  static const Color surfaceContainerLight = paperAsh;
  static const Color surfaceContainerHighLight = paperWarm;
  static const Color onSurfaceLight = textPrimary;
  static const Color onSurfaceVariantLight = textSecondary;
  static const Color outlineVariantLight = borderSubtle;

  // Theme-aware helpers
  static Color bg(BuildContext context) => inkBase;
  static Color card(BuildContext context) => paperSage;
  static Color cardHigh(BuildContext context) => inkMid;
  static Color text(BuildContext context) => textPrimary;
  static Color textSecondaryStyle(BuildContext context) => textSecondary;
  static Color input(BuildContext context) => paperAsh;
  static Color border(BuildContext context) => borderSubtle;
}
