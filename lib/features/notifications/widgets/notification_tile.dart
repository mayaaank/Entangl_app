import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// Pure display tile. Emits onTap and onDismiss — no logic inside.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateTime.tryParse(notification.createdAt);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.dislike.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.dislike),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.paperClay : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppColors.borderSubtle : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (isUnread)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.cream100,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 16),
                
                // Stacked avatar + type badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarWidget(imageUrl: notification.actor?.avatarUrl, size: 44),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.inkBase,
                          shape: BoxShape.circle,
                          border: Border(
                            top: BorderSide(color: AppColors.borderSubtle, width: 1),
                            bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                            left: BorderSide(color: AppColors.borderSubtle, width: 1),
                            right: BorderSide(color: AppColors.borderSubtle, width: 1),
                          ),
                        ),
                        child: _typeIcon(notification.type),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(notification),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time != null ? timeago.format(time) : '',
                        style: AppTextStyles.timestamp.copyWith(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (notification.post?['image_url'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      notification.post!['image_url'] as String,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeIcon(NotificationType t) {
    switch (t) {
      case NotificationType.follow:
        return const Icon(Icons.person_add_rounded, color: AppColors.notifFollow, size: 12);
      case NotificationType.like:
        return const Icon(Icons.favorite_rounded, color: AppColors.notifLike, size: 12);
      case NotificationType.dislike:
        return const Icon(Icons.thumb_down_rounded, color: AppColors.notifDislike, size: 12);
      case NotificationType.comment:
        return const Icon(Icons.chat_bubble_rounded, color: AppColors.notifComment, size: 12);
      case NotificationType.reply:
        return const Icon(Icons.reply_rounded, color: AppColors.notifReply, size: 12);
    }
  }

  String _text(NotificationModel n) {
    final name = n.actor?.fullName ?? 'Someone';
    switch (n.type) {
      case NotificationType.follow:
        return '$name started following you';
      case NotificationType.like:
        return '$name liked your post';
      case NotificationType.dislike:
        return '$name disliked your post';
      case NotificationType.comment:
        return '$name commented on your post';
      case NotificationType.reply:
        return '$name replied to your comment';
    }
  }
}
