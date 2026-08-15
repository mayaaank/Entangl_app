import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/stories/widgets/story_circles_row.dart';
import '../../../shared/widgets/connect_nav_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/tactile_connector.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../search/screens/search_screen.dart';
import '../providers/feed_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              context.push(AppRoutes.notifications);
              break;
            case 3:
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
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final feedAsync = ref.watch(feedProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceLowest,
      displacement: top + 72,
      onRefresh: () async => ref.refresh(feedProvider),
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: top),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
              ),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.push(AppRoutes.settings),
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'entangl',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.brandName,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showSearch(
                        context: context,
                        delegate: UserSearchDelegate(ref),
                      ),
                      icon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    _NotifBell(),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 8),
              child: SizedBox(height: 104, child: StoryCirclesRow()),
            ),
          ),
          feedAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GhostMascot(
                      expression: GhostExpression.floating,
                      size: 88,
                    ),
                    SizedBox(height: 16),
                    Text('Summoning posts...'),
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
                        size: 88,
                      ),
                      const SizedBox(height: 16),
                      Text('Couldn’t load the feed', style: AppTextStyles.title2),
                      const SizedBox(height: 8),
                      Text(
                        'Check your network, then try again.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                              size: 88,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nothing tangled yet',
                              style: AppTextStyles.title2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to post a scrap and start the thread.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 200,
                              child: GradientButton(
                                label: 'New Entanglement',
                                onTap: () =>
                                    context.push(AppRoutes.createPost),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.only(top: 12, bottom: 140),
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
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              if (i > 0) const TactileConnector(height: 28),
                              PostCard(post: posts[i]),
                            ],
                          );
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
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
