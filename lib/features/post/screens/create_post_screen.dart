import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/supabase_service.dart';
import '../../../features/stories/widgets/create_story_sheet.dart';
import '../../feed/providers/feed_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/providers/scraps_provider.dart';
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
          ref.invalidate(scrapsProvider(uid));
        }
        ref.invalidate(createPostProvider);
        context.pop();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    final state = ref.watch(createPostProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            ref.invalidate(createPostProvider);
            context.pop();
          },
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
        ),
        title: Text(
          'New Entanglement',
          style: AppTextStyles.title2.copyWith(
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Story',
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const CreateStorySheet(),
            ),
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canPost = widget.state.canSubmit;
    return GestureDetector(
      onTapDown: canPost ? (_) => setState(() => _pressed = true) : null,
      onTapUp: canPost ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: canPost
          ? () => ref.read(createPostProvider.notifier).submit()
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(
          _pressed ? 2 : 0,
          _pressed ? 2 : 0,
          0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: canPost ? AppColors.surfaceLowest : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.onSurface, width: 1.5),
          boxShadow: canPost && !_pressed ? AppColors.shadowCard : null,
        ),
        child: widget.state.isSubmitting
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onSurface,
                ),
              )
            : Text(
                'Post',
                style: AppTextStyles.labelSmall.copyWith(
                  color: canPost ? AppColors.onSurface : AppColors.outline,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    );
  }
}
