import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/masonry_config.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../features/comments/widgets/comments_sheet.dart';
import '../../../features/feed/providers/feed_provider.dart';
import 'scrap_caption.dart';
import 'scrap_content_view.dart';

/// Card chrome only. Content type decisions live in [ScrapContentView].
class ScrapCard extends ConsumerWidget {
  final PostModel scrap;
  final double cardWidth;
  final MasonryConfig config;

  const ScrapCard({
    super.key,
    required this.scrap,
    required this.cardWidth,
    this.config = MasonryConfig.scraps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return GestureDetector(
      onTap: () => _openDetail(context),
      onLongPress: () {
        HapticFeedback.lightImpact();
        ref.read(feedProvider.notifier).toggleLike(scrap.id);
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: palette.surfaceLowest,
          borderRadius: BorderRadius.circular(config.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScrapContentView(
              content: scrap.content,
              width: cardWidth,
              liked: scrap.isLiked,
            ),
            if (scrap.caption.isNotEmpty) ScrapCaption(text: scrap.caption),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(post: scrap),
    );
  }
}
