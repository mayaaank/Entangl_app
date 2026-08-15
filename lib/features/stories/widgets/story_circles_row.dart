import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/stories_provider.dart';
import '../screens/story_viewer_screen.dart';
import 'create_story_sheet.dart';



class StoryCirclesRow extends ConsumerWidget {
  const StoryCirclesRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);
    final me = ref.watch(ownProfileProvider).valueOrNull;
    final uid = SupabaseService.currentUserId;

    return storiesAsync.when(
      loading: () => const _SkeletonRow(),
      error: (_, __) => _row(context, const <UserStories>[], me, uid),
      data: (userStories) => _row(context, userStories, me, uid),
    );
  }

  Widget _row(
    BuildContext context,
    List<UserStories> userStories,
    UserModel? me,
    String? uid,
  ) {
    final others = uid == null
        ? userStories
        : userStories.where((us) => us.user.id != uid).toList();
    UserStories? own;
    if (uid != null) {
      for (final us in userStories) {
        if (us.user.id == uid) {
          own = us;
          break;
        }
      }
    }

    final ownStories = own;
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _AddStoryCircle(
          avatarUrl: me?.avatarUrl ?? ownStories?.user.avatarUrl,
          hasStory: ownStories != null && ownStories.stories.isNotEmpty,
          onAdd: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const CreateStorySheet(),
          ),
          onOpen: ownStories == null
              ? null
              : () => _openViewer(
                    context,
                    userStories,
                    userStories.indexOf(ownStories),
                  ),
        ),
        ...others.asMap().entries.map((e) {
          return _StoryCircle(
            userStory: e.value,
            onTap: () => _openViewer(context, userStories, userStories.indexOf(e.value)),
          );
        }),
      ],
    );
  }

  void _openViewer(
    BuildContext context,
    List<UserStories> all,
    int index,
  ) {
    if (index < 0) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => StoryViewerScreen(
          allUserStories: all,
          initialUserIndex: index,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 180),
      ),
    );
  }
}

class _AddStoryCircle extends StatelessWidget {
  final String? avatarUrl;
  final bool hasStory;
  final VoidCallback onAdd;
  final VoidCallback? onOpen;

  const _AddStoryCircle({
    required this.avatarUrl,
    required this.hasStory,
    required this.onAdd,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: hasStory ? onOpen : onAdd,
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceHigh,
                  border: Border.all(color: AppColors.outline, width: 1.5),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: AvatarWidget(imageUrl: avatarUrl, size: 56),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _plusBadge(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Story',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plusBadge() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.onSurface, width: 1.5),
        ),
        child: const Icon(Icons.add_rounded, size: 12),
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final UserStories userStory;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.userStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final viewed = userStory.allViewed;
    final name = userStory.user.fullName.split(' ').first;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: viewed ? palette.surfaceHigh : palette.onSurface,
                  border: Border.all(color: palette.outline, width: 1.5),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  alignment: Alignment.center,
                  child: AvatarWidget(
                    imageUrl: userStory.user.avatarUrl,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceHigh,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
