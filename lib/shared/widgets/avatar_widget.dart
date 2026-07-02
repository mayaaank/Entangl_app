import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double  size;
  final bool    showRing;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 44,
    this.showRing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width:  size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.inkWarm,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width:  size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.inkWarm,
                  child: Icon(
                    Icons.person_rounded,
                    size: size * 0.45,
                    color: AppColors.textMuted,
                  ),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  size: size * 0.45,
                  color: AppColors.textMuted,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: size * 0.45,
                color: AppColors.textMuted,
              ),
      ),
    );

    if (showRing) {
      avatar = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(
          color: AppColors.cream100,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.inkBase,
            shape: BoxShape.circle,
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
