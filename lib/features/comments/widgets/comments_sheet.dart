import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/comments_provider.dart';

class CommentsSheet extends ConsumerWidget {
  final PostModel     post;
  final VoidCallback? onCommentAdded;

  const CommentsSheet({
    super.key,
    required this.post,
    this.onCommentAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider(post.id));
    final isPostOwner = post.userId == SupabaseService.currentUserId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 0.5,
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize:     0.95,
        minChildSize:     0.4,
        expand:           false,
        builder: (_, scrollController) => Column(children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: Row(children: [
              Text('Comments',
                  style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 20)),
              const Spacer(),
              commentsAsync.whenData((c) => Text(
                    '${c.fold(0, (n, c) => n + 1 + c.replies.length)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  )).value ??
                  const SizedBox.shrink(),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close,
                    color: AppColors.textSecondary,
                    size: 20),
              ),
            ]),
          ),
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.cream100, strokeWidth: 2)),
              error: (e, _) => const Center(
                  child: Text('Could not load comments',
                      style: TextStyle(
                          color: AppColors.textSecondary))),
              data: (comments) => comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GhostMascot(
                            expression: GhostExpression.floating,
                            size: 88,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: AppTextStyles.displayMd.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share your thoughts!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller:  scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount:   comments.length,
                      itemBuilder: (_, i) => CommentTile(
                        comment:     comments[i],
                        isPostOwner: isPostOwner,
                        postId:      post.id,
                      ),
                    ),
            ),
          ),
          _CommentInput(
            postId:         post.id,
            onCommentAdded: onCommentAdded,
          ),
        ]),
      ),
    );
  }
}

class CommentTile extends ConsumerWidget {
  final CommentModel comment;
  final bool         isPostOwner;
  final String       postId;

  const CommentTile({
    super.key,
    required this.comment,
    required this.isPostOwner,
    required this.postId,
  });

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String commentId,
      {String? parentId}) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.inkMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete comment?',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text(
          'This cannot be undone.',
          style: TextStyle(
              color: AppColors.textSecondary
                  .withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.dislike)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      HapticFeedback.lightImpact();
      ref.read(commentsProvider(postId).notifier)
          .deleteComment(commentId, parentId: parentId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn  = comment.userId == SupabaseService.currentUserId;
    final time   = DateTime.tryParse(comment.createdAt);
    final input  = ref.read(commentInputProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(
                  imageUrl: comment.author?.avatarUrl, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.paperSage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                              comment.author?.fullName ?? 'User',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            if (isOwn)
                              GestureDetector(
                                onTap: () => _confirmDelete(
                                    context, ref, comment.id),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 15,
                                  color: AppColors.dislike,
                                ),
                              ),
                          ]),
                          const SizedBox(height: 3),
                          Text(comment.content,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                height: 1.4,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8, top: 4),
                      child: Row(children: [
                        Text(
                          time != null
                              ? timeago.format(time)
                              : '',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        if (isPostOwner) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => input.setReplyingTo(
                              comment.id,
                              comment.author?.fullName ?? 'User',
                            ),
                            child: const Text('Reply',
                                style: TextStyle(
                                  color: AppColors.cream100,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies
          ...comment.replies.map((r) => Padding(
                padding:
                    const EdgeInsets.only(left: 44, top: 6),
                child: _ReplyTile(
                  reply:    r,
                  postId:   postId,
                  parentId: comment.id,
                  onDelete: () => _confirmDelete(
                      context, ref, r.id,
                      parentId: comment.id),
                ),
              )),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final CommentModel reply;
  final String       postId;
  final String       parentId;
  final VoidCallback onDelete;

  const _ReplyTile({
    required this.reply,
    required this.postId,
    required this.parentId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwn = reply.userId == SupabaseService.currentUserId;
    final time  = DateTime.tryParse(reply.createdAt);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.subdirectory_arrow_right_rounded,
            size: 14,
            color: AppColors.textTertiary.withOpacity(0.4)),
        const SizedBox(width: 4),
        AvatarWidget(imageUrl: reply.author?.avatarUrl, size: 26),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.paperSage,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(reply.author?.fullName ?? 'User',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      )),
                  const Spacer(),
                  if (isOwn)
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 12,
                          color: AppColors.dislike),
                    ),
                ]),
                Text(reply.content,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    )),
                const SizedBox(height: 2),
                Text(
                  time != null ? timeago.format(time) : '',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Comment input — clears controller after send ─────────────
class _CommentInput extends ConsumerStatefulWidget {
  final String        postId;
  final VoidCallback? onCommentAdded;

  const _CommentInput({
    required this.postId,
    this.onCommentAdded,
  });

  @override
  ConsumerState<_CommentInput> createState() =>
      _CommentInputState();
}

class _CommentInputState extends ConsumerState<_CommentInput> {
  // Own controller so we can clear it reliably after submit
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputState    = ref.watch(commentInputProvider);
    final inputNotifier = ref.read(commentInputProvider.notifier);
    final commentsNotifier =
        ref.read(commentsProvider(widget.postId).notifier);

    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.inkMid,
        border: Border(
          top: BorderSide(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply banner
          if (inputState.replyingToId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 3, height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.cream100,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Replying to ${inputState.replyingToName}',
                  style: const TextStyle(
                    color: AppColors.cream100,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: inputNotifier.clearReply,
                  child: const Icon(Icons.close,
                      size: 14,
                      color: AppColors.textSecondary),
                ),
              ]),
            ),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged:  inputNotifier.setText,
                cursorColor: context.palette.primary,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: context.palette.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: context.palette.onSurfaceVariant,
                  ),
                  filled:      true,
                  fillColor:   context.palette.surfaceLow,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: inputState.isSubmitting
                  ? null
                  : () async {
                      await inputNotifier.submit(
                          widget.postId, commentsNotifier);
                      // Clear the text field visually
                      _ctrl.clear();
                      widget.onCommentAdded?.call();
                    },
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: inputState.text.trim().isEmpty
                      ? AppColors.paperAsh
                      : AppColors.cream100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 0.5,
                  ),
                ),
                child: inputState.isSubmitting
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnCream))
                    : Icon(
                        Icons.send_rounded,
                        color: inputState.text.trim().isEmpty
                            ? AppColors.textMuted
                            : AppColors.textOnCream,
                        size: 18,
                      ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
