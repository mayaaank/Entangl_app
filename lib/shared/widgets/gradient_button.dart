import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Primary CTA — solid yellow with ink outline (Stitch Post button style).
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.height = 52,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.animateTo(0.96, curve: Curves.easeOutQuad);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.animateTo(1.0, curve: Curves.elasticOut);
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.animateTo(1.0, curve: Curves.easeOutQuad);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null || widget.isLoading;

    final Color containerColor;
    final Color textColor;
    final List<BoxShadow>? shadows;

    if (isDisabled) {
      containerColor = AppColors.inkWarm;
      textColor = AppColors.textMuted;
      shadows = null;
    } else if (_isPressed) {
      containerColor = AppColors.cream80;
      textColor = AppColors.textOnCream;
      shadows = AppColors.haloPress;
    } else {
      containerColor = AppColors.cream100;
      textColor = AppColors.textOnCream;
      shadows = AppColors.shadowDoodle;
    }

    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled
                  ? AppColors.borderDefault
                  : AppColors.borderCard,
              width: 2,
            ),
            boxShadow: shadows,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null && !widget.isLoading) ...[
                widget.leadingIcon!,
                const SizedBox(width: 8),
              ],
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              else
                Text(
                  widget.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (widget.trailingIcon != null && !widget.isLoading) ...[
                const SizedBox(width: 8),
                widget.trailingIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
