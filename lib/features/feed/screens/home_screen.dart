import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/post_model.dart';
import '../../../features/stories/widgets/story_circles_row.dart';
import '../../../shared/widgets/connect_nav_bar.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../search/screens/search_screen.dart';
import '../providers/feed_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.inkBase,
      extendBody: true,
      body: const _HomeBody(),
      bottomNavigationBar: ConnectNavBar(
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
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final feedAsync = ref.watch(feedProvider);

    // Header height: status bar + name row (52) + stories (96) + divider (1)
    final headerHeight = top + 52.0 + 96.0 + 1.0;

    return RefreshIndicator(
      color: AppColors.cream100,
      backgroundColor: AppColors.inkMid,
      strokeWidth: 2.5,
      displacement: headerHeight + 10,
      onRefresh: () async {
        return ref.refresh(feedProvider);
      },
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Floating header — scrolls away, snaps back on scroll up
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
                // prevents any pixel overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status bar spacer
                    SizedBox(height: top + 10),
                    // Top bar: Connect + search + bell
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 8, bottom: 4),
                      child: Row(
                        children: [
                          GradientText(
                            'connect',
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
                    // Stories row — fixed height 96
                    const SizedBox(
                      height: 96,
                      child: StoryCirclesRow(),
                    ),
                    // Divider
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

          // Feed content
          feedAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GhostMascot(
                      expression: GhostExpression.floating,
                      size: 96,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Summoning posts...',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          onTap: () => ref.refresh(feedProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (posts) => posts.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FrogMascot(
                              expression: FrogExpression.confused,
                              size: 96,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Nothing here yet',
                              style: AppTextStyles.displayMd.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to post something and get the conversation started.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: 180,
                              child: GradientButton(
                                label: 'Create Post',
                                onTap: () => context.push(AppRoutes.createPost),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.only(top: 4, bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          if (i == posts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.cream100,
                                  ),
                                ),
                              ),
                            );
                          }
                          return PostCard(post: posts[i] as PostModel);
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
      onPressed: () => showSearch(
        context: context,
        delegate: UserSearchDelegate(ref),
      ),
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
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.cream100,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
