import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/post_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../comments/widgets/comments_sheet.dart';
import '../../feed/providers/feed_provider.dart';
import '../providers/notifications_provider.dart';

/// Type-aware notification deep linking.
///
/// - follow → actor profile
/// - like / dislike / comment / reply → post context (comments sheet)
/// - missing post → actor profile fallback
Future<void> openNotificationTarget(
  BuildContext context,
  WidgetRef ref,
  NotificationModel n,
) async {
  // Fire-and-forget mark read; never block navigation on network.
  ref.read(notificationsProvider.notifier).markRead(n.id);

  if (n.type == NotificationType.follow) {
    if (n.actorId.isNotEmpty && context.mounted) {
      context.push('/profile/${n.actorId}');
    }
    return;
  }

  final postId = n.postId;
  if (postId == null || postId.isEmpty) {
    if (n.actorId.isNotEmpty && context.mounted) {
      context.push('/profile/${n.actorId}');
    }
    return;
  }

  // Prefer post already in feed cache to avoid an extra round-trip.
  PostModel? post;
  final feedPosts = ref.read(feedProvider).valueOrNull;
  if (feedPosts != null) {
    for (final p in feedPosts) {
      if (p.id == postId) {
        post = p;
        break;
      }
    }
  }

  if (post == null) {
    try {
      post = await ref.read(postsRepositoryProvider).getPostById(postId);
    } catch (_) {
      post = null;
    }
  }

  if (!context.mounted) return;

  if (post == null) {
    if (n.actorId.isNotEmpty) {
      context.push('/profile/${n.actorId}');
    }
    return;
  }

  final openComments = n.type == NotificationType.comment ||
      n.type == NotificationType.reply;

  if (openComments) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(post: post!),
    );
    return;
  }

  // like / dislike — show post preview with path into comments
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _NotificationPostSheet(post: post!),
  );
}

class _NotificationPostSheet extends StatelessWidget {
  final PostModel post;
  const _NotificationPostSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
      decoration: BoxDecoration(
        color: AppColors.inkMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AvatarWidget(
                    imageUrl: post.author?.avatarUrl,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author?.fullName ?? 'Unknown',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (post.author?.username.isNotEmpty == true)
                          Text(
                            '@${post.author!.username}',
                            style: AppTextStyles.timestamp.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  post.content,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    post.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _stat(Icons.favorite_rounded, post.likeCount, AppColors.like),
                  const SizedBox(width: 16),
                  _stat(Icons.thumb_down_rounded, post.dislikeCount,
                      AppColors.dislike),
                  const SizedBox(width: 16),
                  _stat(Icons.chat_bubble_rounded, post.commentCount,
                      AppColors.comment),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsSheet(post: post),
                    );
                  },
                  child: const Text('View comments'),
                ),
              ),
              if (post.author != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/profile/${post.userId}');
                    },
                    child: const Text('View profile'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
