import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
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

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateStorySheet(),
    );
  }

  void _openViewer(
    BuildContext context,
    List<UserStories> all,
    int index,
  ) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);
    final ownProfile = ref.watch(ownProfileProvider).valueOrNull;
    final uid = SupabaseService.currentUserId;

    return storiesAsync.when(
      loading: () => const _SkeletonRow(),
      error: (_, __) => _buildRow(
        context,
        _withOwnEntry(const [], ownProfile, uid),
      ),
      data: (userStories) => _buildRow(
        context,
        _withOwnEntry(userStories, ownProfile, uid),
      ),
    );
  }

  /// Always put a "Your story" cell first so creation stays discoverable
  /// even when the user has no active stories.
  List<UserStories> _withOwnEntry(
    List<UserStories> source,
    UserModel? ownProfile,
    String? uid,
  ) {
    if (uid == null) return source;
    final list = List<UserStories>.from(source);
    final ownIndex = list.indexWhere((us) => us.user.id == uid);
    if (ownIndex >= 0) {
      // Ensure own stories stay first.
      if (ownIndex > 0) {
        final own = list.removeAt(ownIndex);
        list.insert(0, own);
      }
      return list;
    }
    if (ownProfile == null) return list;
    list.insert(
      0,
      UserStories(
        user: ownProfile,
        stories: const [],
        allViewed: true,
      ),
    );
    return list;
  }

  Widget _buildRow(BuildContext context, List<UserStories> userStories) {
    if (userStories.isEmpty) {
      // No session / no profile yet — still show a create affordance.
      return SizedBox(
        height: 96,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _AddStoryCircle(onTap: () => _openCreate(context)),
          ],
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: userStories.length,
        itemBuilder: (_, i) {
          final us = userStories[i];
          final isOwn = us.user.id == SupabaseService.currentUserId;
          final emptyOwn = isOwn && us.stories.isEmpty;

          return _StoryCircle(
            userStory: us,
            onTap: () {
              if (emptyOwn) {
                _openCreate(context);
              } else {
                // Viewer only needs entries that have media.
                final viewable = userStories
                    .where((e) => e.stories.isNotEmpty)
                    .toList();
                final vi = viewable.indexWhere((e) => e.user.id == us.user.id);
                if (vi < 0) {
                  if (isOwn) _openCreate(context);
                  return;
                }
                _openViewer(context, viewable, vi);
              }
            },
            onAddTap: isOwn ? () => _openCreate(context) : null,
          );
        },
      ),
    );
  }
}

/// Standalone create cell when we cannot resolve own profile yet.
class _AddStoryCircle extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStoryCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inkWarm,
                border: Border.all(color: AppColors.cream100, width: 1.5),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.cream100,
                size: 28,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your story',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCircle extends StatefulWidget {
  final UserStories userStory;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  const _StoryCircle({
    required this.userStory,
    required this.onTap,
    this.onAddTap,
  });

  @override
  State<_StoryCircle> createState() => _StoryCircleState();
}

class _StoryCircleState extends State<_StoryCircle> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final isOwn = widget.userStory.user.id == SupabaseService.currentUserId;
    final viewed = widget.userStory.allViewed || widget.userStory.stories.isEmpty;
    final name = isOwn
        ? 'Your story'
        : widget.userStory.user.fullName.split(' ').first;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  WidgetBorderRing(
                    viewed: viewed,
                    animate: !reduceMotion && !viewed,
                  ),
                  Container(
                    width: 57,
                    height: 57,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.inkBase,
                    ),
                  ),
                  AvatarWidget(
                    imageUrl: widget.userStory.user.avatarUrl,
                    size: 52,
                    onTap: widget.onTap,
                  ),
                  if (isOwn)
                    Positioned(
                      bottom: 0,
                      right: 2,
                      child: GestureDetector(
                        onTap: widget.onAddTap ?? widget.onTap,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.cream100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.inkBase,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.textOnCream,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                name,
                style: TextStyle(
                  color: viewed
                      ? AppColors.textSecondary.withOpacity(0.7)
                      : AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: viewed ? FontWeight.w400 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetBorderRing extends StatelessWidget {
  final bool viewed;
  final bool animate;
  const WidgetBorderRing({
    super.key,
    required this.viewed,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final ring = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: viewed ? Colors.transparent : AppColors.cream100,
        border: viewed
            ? Border.all(color: AppColors.borderSubtle, width: 1.5)
            : null,
        boxShadow: viewed ? null : AppColors.haloStory,
      ),
    );

    if (viewed || !animate) return ring;

    return ring
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
            begin: 1.0,
            end: 1.04,
            duration: 1500.ms,
            curve: Curves.easeInOut);
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 5,
        itemBuilder: (_, __) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inkWarm,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1500.ms, color: AppColors.inkMid),
                const SizedBox(height: 6),
                Container(
                  width: 38,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.inkWarm,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1500.ms, color: AppColors.inkMid),
              ],
            ),
          );
        },
      ),
    );
  }
}
