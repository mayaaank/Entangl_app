import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Simplified to solid cream text for the Connect brand wordmark
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient; // Retained for API compatibility but unused

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      color: AppColors.cream100,
    );
    return Text(
      text,
      style: effectiveStyle,
    );
  }
}
