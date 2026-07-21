import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography — Fredoka (display/brand) + Nunito (body).
/// Matches ui-ux-pro-max playful pairing for social/creative apps.
class AppTextStyles {
  AppTextStyles._();

  // ── Display Headings (Fredoka) ────────────────────────────────────
  static final TextStyle displayXl = GoogleFonts.fredoka(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 52 / 48,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle displayLg = GoogleFonts.fredoka(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 40 / 36,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static final TextStyle displayMd = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 30 / 24,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static final TextStyle title1 = GoogleFonts.fredoka(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 34 / 28,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static final TextStyle title2 = GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static final TextStyle subtitle = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ── Body text (Nunito) ────────────────────────────────────────────
  static final TextStyle bodyLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodySmall = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  // ── Labels ────────────────────────────────────────────────────────
  static final TextStyle labelLarge = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMedium = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.38,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelSmall = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  // ── Timestamp / caption ───────────────────────────────────────────
  static final TextStyle timestamp = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.38,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  // ── Doodle Accent (Comic Neue for mascot moments) ─────────────────
  static final TextStyle doodleAccent = GoogleFonts.comicNeue(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  // ── Brand wordmark ────────────────────────────────────────────────
  static final TextStyle brandWordmark = GoogleFonts.fredoka(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  // ── Legacy mappings ───────────────────────────────────────────────
  static final TextStyle heroTitle = displayXl;
  static final TextStyle pageTitle = displayLg;
  static final TextStyle sectionTitle = title1;
  static final TextStyle brandName = brandWordmark;
  static final TextStyle username = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle statNumber = GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textPrimary,
  );
  static final TextStyle statLabel = labelSmall;
  static final TextStyle buttonLarge = labelMedium.copyWith(fontSize: 14);
  static final TextStyle buttonMedium = labelMedium.copyWith(fontSize: 13);

  static TextStyle sectionLabel({Color? color}) => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: color ?? AppColors.textSecondary,
      );
}
