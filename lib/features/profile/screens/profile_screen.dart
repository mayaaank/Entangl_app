import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/connect_nav_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/masonry/masonry_feed.dart';
import '../../../shared/widgets/masonry/masonry_skeleton.dart';
import '../../../shared/widgets/masonry/scrap_card.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/tactile_connector.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/scraps_provider.dart';
import '../widgets/follow_list.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = SupabaseService.currentUserId ?? '';
    return _ProfileScaffold(userId: uid, isOwn: true);
  }
}

class OtherProfileScreen extends ConsumerWidget {
  final String userId;
  const OtherProfileScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwn = userId == (SupabaseService.currentUserId ?? '');
    return _ProfileScaffold(userId: userId, isOwn: isOwn);
  }
}

class _ProfileScaffold extends ConsumerStatefulWidget {
  final String userId;
  final bool isOwn;
  const _ProfileScaffold({required this.userId, required this.isOwn});

  @override
  ConsumerState<_ProfileScaffold> createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends ConsumerState<_ProfileScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    if (!widget.isOwn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.invalidate(profileStatsProvider(widget.userId));
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(profileStatsProvider(widget.userId));

    ref.listen(profileStatsProvider(widget.userId), (_, next) {
      next.whenData((stats) {
        if (!widget.isOwn && stats != null) {
          ref.read(followProvider.notifier).init(stats.isFollowing, widget.userId);
        }
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: widget.isOwn
            ? IconButton(
                onPressed: () => context.push(AppRoutes.settings),
                icon: const Icon(Icons.menu_rounded),
              )
            : IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
        title: Text('entangl', style: AppTextStyles.brandName),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
        error: (e, _) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FrogMascot(expression: FrogExpression.sad, size: 88),
              SizedBox(height: 16),
              Text('Profile not found'),
            ],
          ),
        ),
        data: (stats) {
          if (stats == null) {
            return const Center(child: Text('Profile not found'));
          }
          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(
                child: ProfileHeader(
                  stats: stats,
                  isOwn: widget.isOwn,
                  onLogout: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  onEditProfile: () => context.push(AppRoutes.editProfile),
                  onFollowTap: widget.isOwn
                      ? null
                      : () => ref.read(followProvider.notifier).toggle(),
                ),
              ),
              const SliverToBoxAdapter(child: TactileConnector(height: 32)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedTabBar(
                  TabBar(
                    controller: _tabs,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    labelColor: AppColors.onSurface,
                    unselectedLabelColor: AppColors.outline,
                    labelStyle: AppTextStyles.labelLarge,
                    unselectedLabelStyle: AppTextStyles.bodyMedium,
                    tabs: const [
                      Tab(text: 'Recent Scraps'),
                      Tab(text: 'Followers'),
                      Tab(text: 'Following'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _PostsTab(userId: widget.userId, isOwn: widget.isOwn),
                FollowList(userId: widget.userId, type: 'followers'),
                FollowList(userId: widget.userId, type: 'following'),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.isOwn
          ? ConnectNavBar(
              currentIndex: 3,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(AppRoutes.home);
                    break;
                  case 1:
                    context.push(AppRoutes.createPost);
                    break;
                  case 2:
                    context.push(AppRoutes.notifications);
                    break;
                }
              },
            )
          : null,
    );
  }
}

class _PostsTab extends ConsumerWidget {
  final String userId;
  final bool isOwn;
  const _PostsTab({required this.userId, required this.isOwn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrapsAsync = ref.watch(scrapsProvider(userId));
    final palette = context.palette;

    return scrapsAsync.when(
      loading: () => const MasonrySkeleton(),
      error: (_, __) => Center(
        child: Text(
          'Could not load scraps',
          style: AppTextStyles.bodyMedium.copyWith(color: palette.outline),
        ),
      ),
      data: (page) {
        return MasonryFeed(
          items: page.items,
          hasMore: page.hasMore,
          onPrefetch: () =>
              ref.read(scrapsProvider(userId).notifier).loadMore(),
          onRefresh: () =>
              ref.read(scrapsProvider(userId).notifier).refresh(),
          itemBuilder: (context, scrap, cardWidth) => ScrapCard(
            scrap: scrap,
            cardWidth: cardWidth,
          ),
          footer: page.loadingMore
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.primary,
                      ),
                    ),
                  ),
                )
              : null,
          empty: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 72),
              const GhostMascot(
                expression: GhostExpression.floating,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(
                'Your space is empty.',
                textAlign: TextAlign.center,
                style: AppTextStyles.title2,
              ),
              const SizedBox(height: 6),
              Text(
                isOwn
                    ? 'Create your first scrap.'
                    : 'Nothing tangled here yet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
              if (isOwn) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 72),
                  child: GradientButton(
                    label: 'Create scrap',
                    onTap: () => context.push(AppRoutes.createPost),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PinnedTabBar extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _PinnedTabBar(this.tabBar);
  @override
  Widget build(_, __, ___) =>
      Container(color: AppColors.surface, child: tabBar);
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_) => false;
}
