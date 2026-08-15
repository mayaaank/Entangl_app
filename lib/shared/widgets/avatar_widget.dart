import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showRing;
  final VoidCallback? onTap;
  final Color? ringColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 44,
    this.showRing = false,
    this.onTap,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceHigh,
                  child: Icon(
                    Icons.person_rounded,
                    size: size * 0.45,
                    color: AppColors.outline,
                  ),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  size: size * 0.45,
                  color: AppColors.outline,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: size * 0.45,
                color: AppColors.outline,
              ),
      ),
    );

    if (showRing) {
      avatar = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ringColor ?? AppColors.secondaryContainer,
          border: Border.all(color: AppColors.outline, width: 1.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
          ),
          child: avatar,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
