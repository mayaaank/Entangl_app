import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display Headings (Inter 800 with tight letter spacing) ──
  static final TextStyle displayXl = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 52 / 48,
    letterSpacing: -1.92,
    color: AppColors.textPrimary,
  );

  static final TextStyle displayLg = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 44 / 40,
    letterSpacing: -1.20,
    color: AppColors.textPrimary,
  );

  static final TextStyle displayMd = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    letterSpacing: -0.48,
    color: AppColors.textPrimary,
  );

  static final TextStyle title1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 34 / 28,
    letterSpacing: -0.56,
    color: AppColors.textPrimary,
  );

  static final TextStyle title2 = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.44,
    color: AppColors.textPrimary,
  );

  static final TextStyle subtitle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ── Body text ──
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.16,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.14,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.13,
    color: AppColors.textSecondary,
  );

  // ── Labels ──
  static final TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.38,
    letterSpacing: 0.26,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.44,
    color: AppColors.textSecondary,
  );

  // ── Timestamp / caption ──
  static final TextStyle timestamp = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: 0.13,
    color: AppColors.textSecondary,
  );

  // ── Doodle Accent Style (Comic Neue for mascot descriptions) ──
  static final TextStyle doodleAccent = GoogleFonts.comicNeue(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  // ── Legacy mappings for compatibility ──
  static final TextStyle heroTitle = displayXl;
  static final TextStyle pageTitle = displayLg;
  static final TextStyle sectionTitle = title1;
  static final TextStyle brandName = title2;
  static final TextStyle username = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
  static final TextStyle statNumber = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textPrimary,
  );
  static final TextStyle statLabel = labelSmall;
  static final TextStyle buttonLarge = labelMedium.copyWith(fontSize: 13);
  static final TextStyle buttonMedium = labelMedium.copyWith(fontSize: 13);

  static TextStyle sectionLabel({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: color ?? AppColors.textSecondary,
  );
}
