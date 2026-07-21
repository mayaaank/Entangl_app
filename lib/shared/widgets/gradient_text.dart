import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Brand wordmark text — solid ink on cream paper (Stitch).
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient; // Retained for API compatibility

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      color: AppColors.textPrimary,
    );
    return Text(
      text,
      style: effectiveStyle,
    );
  }
}
