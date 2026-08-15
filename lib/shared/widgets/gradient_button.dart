import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/entangl_colors.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool outlined;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.height = 48,
    this.leadingIcon,
    this.trailingIcon,
    this.outlined = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.isLoading;
    final filled = !widget.outlined;
    final palette = context.palette;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onTap!();
            },
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        height: widget.height,
        transform: Matrix4.translationValues(
          _pressed ? 3 : 0,
          _pressed ? 3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: disabled
              ? palette.surfaceHigh
              : filled
                  ? palette.primary
                  : palette.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.onSurface, width: 1.5),
          boxShadow: disabled || _pressed ? null : palette.shadowCard,
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
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: filled ? palette.onPrimary : palette.onSurface,
                ),
              )
            else
              Text(
                widget.label,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: disabled
                      ? palette.outline
                      : filled
                          ? palette.onPrimary
                          : palette.onSurface,
                ),
              ),
            if (widget.trailingIcon != null && !widget.isLoading) ...[
              const SizedBox(width: 8),
              widget.trailingIcon!,
            ],
          ],
        ),
      ),
    );
  }
}
