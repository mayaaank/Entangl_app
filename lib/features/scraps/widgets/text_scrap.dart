import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../domain/scrap/scrap_content.dart';
import '../../../shared/widgets/emoji_text.dart';

class TextScrap extends StatelessWidget {
  final TextContent content;
  final double width;

  const TextScrap({
    super.key,
    required this.content,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: content.heightFor(width),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EmojiText(
                content.text,
                maxLines: 14,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: palette.onSurface,
                  height: 1.35,
                ),
              ),
            ),
            if (content.text.length > 180)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Show more',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
