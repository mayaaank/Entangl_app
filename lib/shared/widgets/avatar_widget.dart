import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'avatar_viewer_screen.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showRing;
  final VoidCallback? onTap;
  // When set, tapping the avatar opens the full-screen viewer
  // with a Hero animation keyed to this tag.
  final String? heroTag;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 44,
    this.showRing = false,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.inkWarm,
      ),
      child: ClipOval(
        child: hasImage
            ? Hero(
                tag: heroTag ?? imageUrl!,
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
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

    // Determine tap behaviour:
    // 1. Custom onTap overrides everything
    // 2. If imageUrl exists, open full-screen viewer
    // 3. Otherwise nothing
    final effectiveTap = onTap ??
        (hasImage
            ? () => AvatarViewerScreen.show(
                  context,
                  imageUrl: imageUrl!,
                  heroTag: heroTag ?? imageUrl!,
                )
            : null);

    if (effectiveTap != null) {
      return GestureDetector(onTap: effectiveTap, child: avatar);
    }
    return avatar;
  }
}
