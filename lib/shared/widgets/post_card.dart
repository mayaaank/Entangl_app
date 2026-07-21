import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/post_model.dart';
import '../../data/services/supabase_service.dart';
import '../../features/comments/widgets/comments_sheet.dart';
import '../../features/feed/providers/feed_provider.dart';
import 'avatar_widget.dart';
import 'dynamic_post_image.dart';
import 'reactions_sheet.dart';
import 'avatar_viewer_screen.dart';

/// Feed card matching Stitch home: white surface, 2px ink outline,
/// pastel action chips (like / comment / share / bookmark-style).
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderCard, width: 2),
        ),
        title: Text(
          'Delete post?',
          style: AppTextStyles.title2.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
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

    final isShortText = post.content.length < 60 &&
        (post.imageUrl == null || post.imageUrl!.isEmpty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paperSage,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderCard, width: 2),
        boxShadow: AppColors.shadowDoodle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 0),
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
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderCard,
                        width: 1.5,
                      ),
                    ),
                    child: AvatarWidget(
                      imageUrl: post.author?.avatarUrl,
                      size: 38,
                      heroTag: 'avatar_${post.userId}_feed',
                      onTap: () => context.push('/profile/${post.userId}'),
                    ),
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
                          post.author?.username ??
                              post.author?.fullName ??
                              'Unknown',
                          style: AppTextStyles.username.copyWith(fontSize: 15),
                        ),
                        if (time != null)
                          Text(
                            timeago.format(time),
                            style: AppTextStyles.timestamp.copyWith(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isOwn)
                  PopupMenuButton<String>(
                    color: AppColors.inkMid,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: AppColors.borderCard,
                        width: 1.5,
                      ),
                    ),
                    icon: const Icon(
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
                            Icon(Icons.delete_outline_rounded,
                                color: AppColors.dislike, size: 18),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppColors.dislike)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Content (sizes with text — no fixed block) ──
          if (post.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                10,
                14,
                post.imageUrl != null && post.imageUrl!.isNotEmpty ? 0 : 0,
              ),
              child: Text(
                post.content,
                style: isShortText
                    ? AppTextStyles.displayMd.copyWith(
                        fontSize: _shortTextSize(post.content),
                        height: 1.35,
                        color: AppColors.textPrimary,
                      )
                    : AppTextStyles.bodyLarge.copyWith(
                        fontSize: 15,
                        height: 1.55,
                      ),
              ),
            ),

          // ── Image — natural aspect ratio (not fixed crop) ─
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: DynamicPostImage(
                networkUrl: post.imageUrl!,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderCard,
                  width: 1.5,
                ),
              ),
            ),

          // ── Meta + pastel action chips ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.likeCount > 0 || post.commentCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 2),
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => ReactionsSheet(postId: post.id),
                      ),
                      child: Text(
                        [
                          if (post.likeCount > 0) '${post.likeCount} likes',
                          if (post.commentCount > 0)
                            '${post.commentCount} comments',
                        ].join('  ·  '),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Even action strip — no Spacer gaps (like · dislike · comment · more)
                Row(
                  children: [
                    Expanded(
                      child: _PastelAction(
                        fill: AppColors.pastelPink,
                        icon: post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        iconColor: post.isLiked
                            ? AppColors.like
                            : AppColors.textPrimary,
                        label: 'Like',
                        isActive: post.isLiked,
                        onTap: _animateLike,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PastelAction(
                        fill: AppColors.pastelPeach,
                        icon: post.isDisliked
                            ? Icons.thumb_down_rounded
                            : Icons.thumb_down_outlined,
                        iconColor: post.isDisliked
                            ? AppColors.dislike
                            : AppColors.textPrimary,
                        label: 'Dislike',
                        isActive: post.isDisliked,
                        onTap: _animateDislike,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PastelAction(
                        fill: AppColors.pastelMint,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.textPrimary,
                        label: 'Comment',
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CommentsSheet(post: post),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PastelAction(
                        fill: AppColors.pastelBlue,
                        icon: Icons.ios_share_rounded,
                        iconColor: AppColors.textPrimary,
                        label: 'Share',
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          final text = post.content.trim().isNotEmpty
                              ? post.content.trim()
                              : 'Check out this post on Entangl';
                          await Clipboard.setData(
                            ClipboardData(text: text),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post copied — ready to share'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Short caption scale: fewer words → larger type (still soft bounds).
  double _shortTextSize(String content) {
    final len = content.trim().length;
    if (len <= 24) return 22;
    if (len <= 40) return 20;
    return 18;
  }
}

class _PastelAction extends StatefulWidget {
  final Color fill;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isActive;
  final String label;

  const _PastelAction({
    required this.fill,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.label,
    this.isActive = false,
  });

  @override
  State<_PastelAction> createState() => _PastelActionState();
}

class _PastelActionState extends State<_PastelAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _springCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant _PastelAction oldWidget) {
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
    // Full-width equal cells — eliminates uneven dead space between actions.
    return Semantics(
      button: true,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: GestureDetector(
          onTap: () {
            widget.onTap();
            _springCtrl.forward(from: 0.0).then((_) => _springCtrl.reverse());
          },
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 48,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.fill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderCard,
                  width: 1.5,
                ),
                boxShadow: widget.isActive ? AppColors.haloLike : null,
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
