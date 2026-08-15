import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../shared/widgets/emoji_text.dart';

class ScrapCaption extends StatelessWidget {
  final String text;

  const ScrapCaption({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: EmojiText(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          color: context.palette.onSurface,
        ),
      ),
    );
  }
}
