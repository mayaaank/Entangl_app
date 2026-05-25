import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/stories_provider.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  final List<UserStories> allUserStories;
  final int               initialUserIndex;

  const StoryViewerScreen({
    super.key,
    required this.allUserStories,
    required this.initialUserIndex,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() =>
      _StoryViewerScreenState();
}

class _StoryViewerScreenState
    extends ConsumerState<StoryViewerScreen>
    with TickerProviderStateMixin {
  late int                 _userIndex;
  late int                 _storyIndex;
  late AnimationController _progressCtrl;
  VideoPlayerController?   _videoCtrl;
  bool                     _videoReady = false;
  bool                     _paused     = false;
  bool                     _showHeartGhost = false;

  late AnimationController _likeCtrl;
  late Animation<double>   _likeScale;

  // Swipe-down dismiss
  double _dragOffset = 0.0;

  static const _imageDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _userIndex  = widget.initialUserIndex;
    _storyIndex = 0;

    _progressCtrl = AnimationController(vsync: this);
    _progressCtrl.addListener(() => setState(() {}));

    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut),
    );

    // Force true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _loadStory();
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _progressCtrl.dispose();
    _likeCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  List<UserStories> get _allUsers  => widget.allUserStories;
  UserStories       get _curUser   => _allUsers[_userIndex];
  StoryModel        get _curStory  => _curUser.stories[_storyIndex];

  void _loadStory() {
    _progressCtrl.reset();
    _videoCtrl?.dispose();
    _videoCtrl  = null;
    _videoReady = false;
    _paused     = false;

    if (_curStory.userId != SupabaseService.currentUserId) {
      ref.read(storiesProvider.notifier).markViewed(_curStory.id);
    }

    if (_curStory.mediaType == StoryMediaType.video) {
      _initVideo();
    } else {
      _startTimer(_imageDuration);
    }
  }

  void _initVideo() {
    final ctrl =
        VideoPlayerController.networkUrl(Uri.parse(_curStory.mediaUrl));
    _videoCtrl = ctrl;
    ctrl.initialize().then((_) {
      if (!mounted) return;
      setState(() => _videoReady = true);
      ctrl.play();
      _startTimer(ctrl.value.duration);
    });
  }

  void _startTimer(Duration d) {
    _progressCtrl.duration = d;
    _progressCtrl.forward().then((_) {
      if (mounted && !_paused) _nextStory();
    });
  }

  void _nextStory() {
    if (_storyIndex < _curUser.stories.length - 1) {
      setState(() => _storyIndex++);
      _loadStory();
    } else {
      _nextUser();
    }
  }

  void _prevStory() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _loadStory();
    } else {
      _prevUser();
    }
  }

  void _nextUser() {
    if (_userIndex < _allUsers.length - 1) {
      setState(() { _userIndex++; _storyIndex = 0; });
      _loadStory();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevUser() {
    if (_userIndex > 0) {
      setState(() { _userIndex--; _storyIndex = 0; });
      _loadStory();
    }
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _progressCtrl.stop();
      _videoCtrl?.pause();
    } else {
      _progressCtrl.forward();
      _videoCtrl?.play();
    }
  }

  void _animateLike() {
    _likeCtrl.forward().then((_) => _likeCtrl.reverse());
    setState(() => _showHeartGhost = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showHeartGhost = false);
      }
    });
    ref.read(storiesProvider.notifier).toggleLike(_curStory.id);
  }

  @override
  Widget build(BuildContext context) {
    // Pull fresh story state so like updates reflect immediately
    final fresh = ref.watch(storiesProvider).valueOrNull;
    StoryModel story = _curStory;
    if (fresh != null &&
        _userIndex < fresh.length &&
        _storyIndex < fresh[_userIndex].stories.length) {
      story = fresh[_userIndex].stories[_storyIndex];
    }

    final isOwn  = story.userId == SupabaseService.currentUserId;
    final author = story.author;
    final time   = DateTime.tryParse(story.createdAt);
    final size   = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    final dragFraction = (_dragOffset / size.height).clamp(0.0, 1.0);
    final scale   = 1.0 - dragFraction * 0.2;
    final opacity = 1.0 - dragFraction * 0.6;

    return Scaffold(
      // These two lines are critical — allow content behind status bar
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onVerticalDragUpdate: (d) {
          if (d.delta.dy > 0 || _dragOffset > 0) {
            setState(() {
              _dragOffset = (_dragOffset + d.delta.dy).clamp(0.0, size.height);
            });
          }
        },
        onVerticalDragEnd: (d) {
          if (_dragOffset > 120 || d.primaryVelocity! > 800) {
            Navigator.of(context).pop();
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        child: AnimatedContainer(
          duration: _dragOffset == 0
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _dragOffset)
            ..scale(scale),
          transformAlignment: Alignment.topCenter,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: SizedBox.expand(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) {
                  final x = d.localPosition.dx;
                  if (x < size.width * 0.3) {
                    _prevStory();
                  } else if (x > size.width * 0.7) {
                    _nextStory();
                  } else {
                    _togglePause();
                  }
                },
                onLongPressStart: (_) {
                  setState(() => _paused = true);
                  _progressCtrl.stop();
                  _videoCtrl?.pause();
                },
                onLongPressEnd: (_) {
                  setState(() => _paused = false);
                  _progressCtrl.forward();
                  _videoCtrl?.play();
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    // ── 1. MEDIA (fills entire screen) ────────────
                    _MediaLayer(
                      story:      story,
                      videoCtrl:  _videoCtrl,
                      videoReady: _videoReady,
                    ),

              // ── 2. TOP gradient (status bar → below header) ─
              Positioned(
                top: 0, left: 0, right: 0,
                height: topPad + 120,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                      colors: [
                        Color(0xCC000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── 3. BOTTOM gradient ──────────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: 180,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end:   Alignment.topCenter,
                      colors: [
                        Color(0xBB000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── 4. PROGRESS BARS — pinned to top ───────────
              Positioned(
                top: topPad + 6,
                left: 8, right: 8,
                child: Row(
                  children: List.generate(
                    _curUser.stories.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: AppColors.cream08,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: i < _storyIndex
                                ? 1.0
                                : i == _storyIndex
                                    ? _progressCtrl.value
                                    : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cream100,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: AppColors.shadowCard,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 5. HEADER — user info, just below progress ─
              Positioned(
                top: topPad + 18,
                left: 12, right: 8,
                child: Row(
                  children: [
                    // Avatar
                    AvatarWidget(
                      imageUrl: author?.avatarUrl,
                      size: 38,
                    ),
                    const SizedBox(width: 10),
                    // Name + time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            author?.fullName ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          if (time != null)
                            Text(
                              timeago.format(time),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Owner 3-dot menu
                    if (isOwn)
                      _OwnerMenuButton(
                        onDelete: () {
                          ref
                              .read(storiesProvider.notifier)
                              .deleteStory(story.id);
                          Navigator.pop(context);
                        },
                        onViewers: () =>
                            _showViewers(context, story.id),
                      ),
                    // Close — always last, always visible
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34, height: 34,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              // ── 6. LIKE BUTTON — bottom center (other users) ─
              if (!isOwn)
                Positioned(
                  bottom: 32 + MediaQuery.of(context).padding.bottom,
                  left: 0, right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _animateLike,
                      child: ScaleTransition(
                        scale: _likeScale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: story.isLiked
                                ? AppColors.heart.withOpacity(0.22)
                                : Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: story.isLiked
                                  ? AppColors.heart.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.25),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                story.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                color: story.isLiked
                                    ? AppColors.heart
                                    : Colors.white,
                                size: 22,
                              ),
                              if (story.likeCount > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${story.likeCount}',
                                  style: TextStyle(
                                    color: story.isLiked
                                        ? AppColors.heart
                                        : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── 7. LIKE COUNT for own story ────────────────
              if (isOwn && story.likeCount > 0)
                Positioned(
                  bottom: 32 + MediaQuery.of(context).padding.bottom,
                  left: 0, right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: AppColors.heart, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${story.likeCount} like${story.likeCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            if (_showHeartGhost)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Animate(
                          child: const GhostMascot(
                            expression: GhostExpression.dancing,
                            size: 160,
                            animate: true,
                          ),
                        ).scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Liked!',
                          style: AppTextStyles.displayMd.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            shadows: [
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
          ),  // Opacity
        ),    // AnimatedContainer
      ),      // outer GestureDetector
    );       // Scaffold
  }

  void _showViewers(BuildContext context, String storyId) async {
    _progressCtrl.stop();
    _videoCtrl?.pause();
    setState(() => _paused = true);

    final viewers = await ref
        .read(storiesRepositoryProvider)
        .getStoryViewers(storyId);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ViewersSheet(viewers: viewers),
    );

    if (mounted) {
      setState(() => _paused = false);
      _progressCtrl.forward();
      _videoCtrl?.play();
    }
  }
}

// ── Media layer ────────────────────────────────────────────────
class _MediaLayer extends StatelessWidget {
  final StoryModel             story;
  final VideoPlayerController? videoCtrl;
  final bool                   videoReady;

  const _MediaLayer({
    required this.story,
    required this.videoCtrl,
    required this.videoReady,
  });

  @override
  Widget build(BuildContext context) {
    if (story.mediaType == StoryMediaType.image) {
      return CachedNetworkImage(
        imageUrl:    story.mediaUrl,
        fit:         BoxFit.cover,
        width:       double.infinity,
        height:      double.infinity,
        placeholder: (_, __) =>
            Container(color: Colors.black),
        errorWidget: (_, __, ___) =>
            Container(color: Colors.black),
      );
    }

    if (videoReady && videoCtrl != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width:  videoCtrl!.value.size.width,
            height: videoCtrl!.value.size.height,
            child:  VideoPlayer(videoCtrl!),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white, strokeWidth: 2),
      ),
    );
  }
}

// ── Owner 3-dot menu ───────────────────────────────────────────
class _OwnerMenuButton extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onViewers;

  const _OwnerMenuButton({
    required this.onDelete,
    required this.onViewers,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.inkMid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      icon: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert_rounded,
            color: Colors.white, size: 18),
      ),
      onSelected: (v) {
        if (v == 'delete')  onDelete();
        if (v == 'viewers') onViewers();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'viewers',
          child: Row(children: [
            Icon(Icons.visibility_outlined,
                size: 18, color: AppColors.cream100),
            SizedBox(width: 10),
            Text('View viewers'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded,
                size: 18, color: AppColors.dislike),
            SizedBox(width: 10),
            Text('Delete story',
                style: TextStyle(color: AppColors.dislike)),
          ]),
        ),
      ],
    );
  }
}

// ── Viewers bottom sheet ───────────────────────────────────────
class _ViewersSheet extends StatelessWidget {
  final List<dynamic> viewers;
  const _ViewersSheet({required this.viewers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkMid,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36, height: 3,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: Row(children: [
              const Icon(Icons.visibility_outlined,
                  color: AppColors.cream100, size: 20),
              const SizedBox(width: 8),
              Text(
                'Viewed by ${viewers.length}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ),
          if (viewers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No views yet',
                style: TextStyle(
                  color: AppColors.textSecondary
                      .withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...viewers.map((u) {
              final user = u as dynamic;
              final url  = user.avatarUrl as String?;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      url != null ? NetworkImage(url) : null,
                  backgroundColor:
                      AppColors.inkWarm,
                  child: url == null
                      ? const Icon(Icons.person,
                          color: AppColors.textMuted)
                      : null,
                ),
                title: Text(
                  user.fullName as String,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                subtitle: Text(
                  '@${user.username}',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12),
                ),
              );
            }),
        ],
      ),
    );
  }
}
