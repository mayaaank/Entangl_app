import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? AppTextStyles.brandName).copyWith(
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
