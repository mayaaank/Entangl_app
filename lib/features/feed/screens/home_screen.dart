import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/stories/widgets/story_circles_row.dart';
import '../../../shared/widgets/entangl_nav_bar.dart';
import '../../../shared/widgets/feed_skeleton.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/suggested_users_section.dart';
import '../../../features/stories/widgets/create_story_sheet.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/feed_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.inkMid,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.cream100),
              title: Text('New post',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textPrimary)),
              subtitle: Text('Share text or a photo',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary)),
              onTap: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.createPost);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.cream100),
              title: Text('New story',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textPrimary)),
              subtitle: Text('Disappears after 24 hours',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary)),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const CreateStorySheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.inkBase,
      extendBody: true,
      body: const _HomeBody(),
      bottomNavigationBar: EntanglNavBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1:
              context.push(AppRoutes.createPost);
              break;
            case 2:
              context.push(AppRoutes.profile);
              break;
          }
        },
        onCreateLongPress: () => _showCreateMenu(context),
      ),
    );
  }
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody();

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final feedAsync = ref.watch(feedProvider);
    final feedNotifier = ref.read(feedProvider.notifier);

    // Header height: status bar + name row (52) + stories (96) + divider (1)
    final headerHeight = top + 52.0 + 96.0 + 1.0;

    return RefreshIndicator(
      color: AppColors.cream100,
      backgroundColor: AppColors.inkMid,
      strokeWidth: 2.5,
      displacement: headerHeight + 10,
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.inkBase,
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            toolbarHeight: 0,
            expandedHeight: headerHeight,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRect(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: top + 10),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 8, bottom: 4),
                      child: Row(
                        children: [
                          GradientText(
                            'entangl',
                            style: AppTextStyles.displayLg.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const Spacer(),
                          _SearchButton(),
                          _NotifBell(),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 96,
                      child: StoryCirclesRow(),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: AppColors.borderSubtle,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Prefer previous data over a blank loading state.
          if (feedAsync.isLoading && !feedAsync.hasValue)
            const FeedSkeletonList()
          else
            feedAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const FeedSkeletonList(),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GhostMascot(
                          expression: GhostExpression.sad,
                          size: 96,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Failed to load feed',
                          style: AppTextStyles.displayMd.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The connection failed to resolve. Check your network connection.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 140,
                          child: GradientButton(
                            label: 'Retry',
                            onTap: () =>
                                ref.read(feedProvider.notifier).refresh(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (posts) => posts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            const FrogMascot(
                              expression: FrogExpression.confused,
                              size: 88,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nothing here yet',
                              style: AppTextStyles.displayMd.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Follow people or create the first post to get started.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 180,
                              child: GradientButton(
                                label: 'Create Post',
                                onTap: () =>
                                    context.push(AppRoutes.createPost),
                              ),
                            ),
                            const SizedBox(height: 28),
                            const SuggestedUsersSection(),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(top: 4, bottom: 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            if (i == posts.length) {
                              if (!feedNotifier.hasMore) {
                                return const SizedBox(height: 24);
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: feedNotifier.isLoadingMore
                                          ? AppColors.cream100
                                          : AppColors.cream100.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return PostCard(post: posts[i]);
                          },
                          childCount: posts.length + 1,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _SearchButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Search users',
      onPressed: () => context.push(AppRoutes.search),
      icon: const Icon(
        Icons.search_rounded,
        color: AppColors.textSecondary,
        size: 22,
      ),
    );
  }
}

class _NotifBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    return Stack(
      children: [
        IconButton(
          tooltip: count > 0
              ? 'Notifications, $count unread'
              : 'Notifications',
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Semantics(
              label: '$count unread notifications',
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.cream100,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
