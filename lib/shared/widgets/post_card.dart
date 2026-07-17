import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/post_model.dart';
import '../../data/services/supabase_service.dart';
import '../../features/comments/widgets/comments_sheet.dart';
import '../../features/feed/providers/feed_provider.dart';
import 'avatar_widget.dart';
import 'doodle_widget.dart';
import 'reactions_sheet.dart';
import 'avatar_viewer_screen.dart';

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

  void _animateDislike() {
    HapticFeedback.lightImpact();
    ref.read(feedProvider.notifier).toggleDislike(widget.post.id);
  }

  Future<void> _confirmDelete() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.inkMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete post?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.dislike),
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

    final isShortText = post.content.length < 60 && (post.imageUrl == null || post.imageUrl!.isEmpty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paperSage,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 0.5,
        ),
        boxShadow: AppColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         // ── Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${post.userId}'),
                  onLongPress: () {
                    if (post.author?.avatarUrl != null &&
                        post.author!.avatarUrl!.isNotEmpty) {
                      AvatarViewerScreen.show(
                        context,
                        imageUrl: post.author!.avatarUrl!,
                        heroTag: 'avatar_${post.userId}_feed',
                      );
                    }
                  },
                  child: AvatarWidget(
                    imageUrl: post.author?.avatarUrl,
                    size: 42,
                    heroTag: 'avatar_${post.userId}_feed',
                    onTap: () => context.push('/profile/${post.userId}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/profile/${post.userId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author?.fullName ?? 'Unknown',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Text(
                              '@${post.author?.username ?? ''}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '  ·  ${time != null ? timeago.format(time) : ''}',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOwn)
                  PopupMenuButton<String>(
                    color: AppColors.inkMid,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onSelected: (v) {
                      if (v == 'delete') _confirmDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: AppColors.dislike, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.dislike)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: isShortText
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 16,
                          bottom: -4,
                          child: Animate(
                            onPlay: (c) => c.repeat(),
                            child: const DoodleWidget(
                              type: DoodleType.sparkle,
                              size: 48,
                              opacity: 0.08,
                            ),
                          ).rotate(begin: 0, end: 1, duration: 25.seconds),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            post.content,
                            style: AppTextStyles.displayMd.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        post.content,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
            ),

          // ── Image ───────────────────────────────────────
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 280),
                    fadeOutDuration: const Duration(milliseconds: 120),
                    memCacheWidth: 900,
                    placeholder: (_, __) => Container(
                      color: AppColors.inkWarm,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.inkWarm,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Actions ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                _ActionChip(
                  icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: post.isLiked ? AppColors.like : AppColors.textSecondary,
                  count: post.likeCount,
                  activeColor: AppColors.like.withOpacity(0.12),
                  isActive: post.isLiked,
                  onTap: _animateLike,
                  shadows: post.isLiked ? AppColors.haloLike : null,
                ),
                const SizedBox(width: 4),
                _ActionChip(
                  icon: post.isDisliked ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
                  color: post.isDisliked ? AppColors.dislike : AppColors.textSecondary,
                  count: post.dislikeCount,
                  activeColor: AppColors.dislike.withOpacity(0.12),
                  isActive: post.isDisliked,
                  onTap: _animateDislike,
                  shadows: post.isDisliked ? AppColors.haloDislike : null,
                ),
                const SizedBox(width: 4),
                _CommentChip(post: post),
                const Spacer(),
                if (post.likeCount + post.dislikeCount > 0)
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => ReactionsSheet(postId: post.id),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.inkWarm,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likeCount + post.dislikeCount}',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentChip extends ConsumerStatefulWidget {
  final PostModel post;
  const _CommentChip({required this.post});

  @override
  ConsumerState<_CommentChip> createState() => _CommentChipState();
}

class _CommentChipState extends ConsumerState<_CommentChip> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.post.commentCount;
  }

  @override
  Widget build(BuildContext context) {
    return _ActionChip(
      icon: Icons.chat_bubble_outline_rounded,
      color: AppColors.textSecondary,
      count: _count,
      activeColor: Colors.transparent,
      isActive: false,
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

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int count;
  final Color activeColor;
  final bool isActive;
  final VoidCallback onTap;
  final List<BoxShadow>? shadows;

  const _ActionChip({
    required this.icon,
    required this.color,
    required this.count,
    required this.activeColor,
    required this.isActive,
    required this.onTap,
    this.shadows,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> with SingleTickerProviderStateMixin {
  late AnimationController _springCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant _ActionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _springCtrl.forward(from: 0.0).then((_) => _springCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(widget.icon, color: widget.color, size: 19);
    iconWidget = ScaleTransition(scale: _scale, child: iconWidget);

    return GestureDetector(
      onTap: () {
        widget.onTap();
        _springCtrl.forward(from: 0.0).then((_) => _springCtrl.reverse());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: widget.isActive ? widget.activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: widget.isActive ? widget.color.withOpacity(0.2) : Colors.transparent,
            width: 0.5,
          ),
          boxShadow: widget.isActive ? widget.shadows : null,
        ),
        child: Row(
          children: [
            iconWidget,
            if (widget.count > 0) ...[
              const SizedBox(width: 5),
              Text(
                '${widget.count}',
                style: TextStyle(
                  color: widget.isActive ? widget.color : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
