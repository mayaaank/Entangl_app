import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../providers/stories_provider.dart';
import '../screens/story_viewer_screen.dart';

class StoryCirclesRow extends ConsumerWidget {
  const StoryCirclesRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);

    return storiesAsync.when(
      loading: () => const _SkeletonRow(),
      error: (_, __) => const SizedBox.shrink(),
      data: (userStories) {
        if (userStories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: userStories.length,
            itemBuilder: (_, i) {
              final us = userStories[i];
              return _StoryCircle(
                userStory: us,
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => StoryViewerScreen(
                      allUserStories: userStories,
                      initialUserIndex: i,
                    ),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 180),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryCircle extends StatefulWidget {
  final UserStories userStory;
  final VoidCallback onTap;

  const _StoryCircle({required this.userStory, required this.onTap});

  @override
  State<_StoryCircle> createState() => _StoryCircleState();
}

class _StoryCircleState extends State<_StoryCircle> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final isOwn = widget.userStory.user.id == SupabaseService.currentUserId;
    final viewed = widget.userStory.allViewed;
    final name = isOwn ? 'Your story' : widget.userStory.user.fullName.split(' ').first;

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
                  // Outer border ring
                  WidgetBorderRing(viewed: viewed),
                  // Gap ring using inkBase
                  Container(
                    width: 57,
                    height: 57,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.inkBase,
                    ),
                  ),
                  // Avatar
                  AvatarWidget(
                    imageUrl: widget.userStory.user.avatarUrl,
                    size: 52,
                    onTap: widget.onTap,
                  ),
                  // Add badge — bottom right only for own story
                  if (isOwn)
                    Positioned(
                      bottom: 0,
                      right: 2,
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
                ],
              ),
              const SizedBox(height: 5),
              Text(
                name,
                style: TextStyle(
                  color: viewed
                      ? AppColors.textSecondary.withOpacity(0.45)
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
  const WidgetBorderRing({super.key, required this.viewed});

  @override
  Widget build(BuildContext context) {
    final ring = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: viewed ? Colors.transparent : AppColors.cream100,
        border: viewed ? Border.all(color: AppColors.borderSubtle, width: 1.5) : null,
        boxShadow: viewed ? null : AppColors.haloStory,
      ),
    );

    if (viewed) return ring;

    // Pulse animation for unviewed stories
    return ring
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.04, duration: 1500.ms, curve: Curves.easeInOut);
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
