import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/entangl_colors.dart';
import '../../data/models/post_model.dart';
import '../../data/services/supabase_service.dart';
import '../../domain/scrap/scrap_content.dart';
import '../../features/comments/widgets/comments_sheet.dart';
import '../../features/feed/providers/feed_provider.dart';
import '../../features/scraps/widgets/collage_scrap.dart';
import '../../features/scraps/widgets/photo_scrap.dart';
import 'avatar_widget.dart';
import 'emoji_text.dart';
import 'reactions_sheet.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _deleting = false;

  void _animateLike() {
    HapticFeedback.lightImpact();
    ref.read(feedProvider.notifier).toggleLike(widget.post.id);
  }

  Future<void> _confirmDelete() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete post?', style: AppTextStyles.title2),
        content: Text(
          'This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _deleting = true);
      await ref.read(feedProvider.notifier).deletePost(widget.post.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isOwn = post.userId == SupabaseService.currentUserId;
    final time = DateTime.tryParse(post.createdAt);
    if (_deleting) return const SizedBox.shrink();

    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/profile/${post.userId}'),
                child: AvatarWidget(
                  imageUrl: post.author?.avatarUrl,
                  size: 32,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/profile/${post.userId}'),
                  child: Text(
                    post.author?.username ?? post.author?.fullName ?? 'Unknown',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Text(
                time != null ? timeago.format(time) : '',
                style: AppTextStyles.timestamp,
              ),
              if (isOwn)
                PopupMenuButton<String>(
                  color: palette.surfaceLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: palette.outline, width: 1.5),
                  ),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: palette.outline,
                    size: 20,
                  ),
                  onSelected: (v) {
                    if (v == 'delete') _confirmDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: palette.error,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          switch (post.content) {
            PhotoContent photo => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PhotoScrap(content: photo),
              ),
            CollageContent collage => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CollageScrap(content: collage),
              ),
            TextContent text => _QuoteFrame(content: text.text),
          },
          if (post.caption.isNotEmpty) ...[
            const SizedBox(height: 12),
            EmojiText(post.caption, style: AppTextStyles.bodyLarge),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _Action(
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                count: post.likeCount,
                active: post.isLiked,
                color: post.isLiked ? palette.error : palette.onSurface,
                onTap: _animateLike,
              ),
              const SizedBox(width: 8),
              _CommentAction(post: post),
              const Spacer(),
              IconButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => ReactionsSheet(postId: post.id),
                ),
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: palette.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteFrame extends StatelessWidget {
  final String content;
  const _QuoteFrame({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.quoteWash,
        borderRadius: BorderRadius.circular(12),
      ),
      child: EmojiText(
        '"$content"',
        style: AppTextStyles.quote,
      ),
    );
  }
}

class _CommentAction extends ConsumerStatefulWidget {
  final PostModel post;
  const _CommentAction({required this.post});

  @override
  ConsumerState<_CommentAction> createState() => _CommentActionState();
}

class _CommentActionState extends ConsumerState<_CommentAction> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.post.commentCount;
  }

  @override
  Widget build(BuildContext context) {
    return _Action(
      icon: Icons.chat_bubble_outline_rounded,
      count: _count,
      active: false,
      color: context.palette.onSurface,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CommentsSheet(
          post: widget.post,
          onCommentAdded: () {
            if (mounted) setState(() => _count++);
          },
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.count,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

@Deprecated('Use ScrapCard inside MasonryFeed')
class ScrapPin extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const ScrapPin({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.outline, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            switch (post.content) {
              PhotoContent photo => PhotoScrap(content: photo),
              CollageContent collage => CollageScrap(content: collage),
              TextContent text => ColoredBox(
                  color: palette.quoteWash,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Center(
                      child: EmojiText(
                        text.text,
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            },
            if (post.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: EmojiText(
                  post.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
