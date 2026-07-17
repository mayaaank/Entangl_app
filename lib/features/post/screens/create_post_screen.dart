import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/supabase_service.dart';
import '../../../features/stories/widgets/create_story_sheet.dart';
import '../../feed/providers/feed_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/create_post_provider.dart';
import '../widgets/create_post_form.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CreatePostState>(createPostProvider, (_, next) {
      if (next.submitted) {
        ref.read(feedProvider.notifier).refresh();
        final uid = SupabaseService.currentUserId;
        if (uid != null) {
          ref.invalidate(profileStatsProvider(uid));
          ref.invalidate(userPostsProvider(uid));
        }
        ref.invalidate(createPostProvider);
        context.pop();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.dislike,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    final state = ref.watch(createPostProvider);

    return Scaffold(
      backgroundColor: AppColors.inkBase,
      appBar: AppBar(
        backgroundColor: AppColors.inkBase,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () {
            // Keep draft in SharedPreferences; only reset in-memory notifier.
            ref.invalidate(createPostProvider);
            context.pop();
          },
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        ),
        title: Text(
          'New Post',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Story button
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const CreateStorySheet(),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.inkWarm,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.cream100, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Story',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Post button — uses canSubmit
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: _PostButton(state: state),
          ),
        ],
      ),
      body: const CreatePostForm(),
    );
  }
}

class _PostButton extends ConsumerStatefulWidget {
  final CreatePostState state;
  const _PostButton({required this.state});

  @override
  ConsumerState<_PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends ConsumerState<_PostButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final canPost = widget.state.canSubmit;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: canPost
          ? () => ref.read(createPostProvider.notifier).submit()
          : null,
      child: AnimatedScale(
        scale: _isTapped && canPost ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: canPost ? AppColors.cream100 : AppColors.inkWarm,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: canPost ? AppColors.shadowCard : null,
          ),
          child: widget.state.isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnCream),
                )
              : Text(
                  'Post',
                  style: TextStyle(
                    color: canPost ? AppColors.textOnCream : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
