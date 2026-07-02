import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/post_card.dart';
import '../providers/feed_provider.dart';

class FeedList extends ConsumerStatefulWidget {
  const FeedList({super.key});

  @override
  ConsumerState<FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);

    return feedAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            color: AppColors.cream100, strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dislike.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.dislike, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              e.toString(),
              style: TextStyle(
                color: AppColors.textSecondary
                    .withOpacity(0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => ref.refresh(feedProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cream100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                      color: AppColors.textOnCream,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          ]),
        ),
      ),
      data: (posts) => posts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.inkWarm,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.cream100, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text('Nothing here yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  Text('Be the first to post something',
                      style: TextStyle(
                        color: AppColors.textSecondary
                            .withOpacity(0.5),
                        fontSize: 14,
                      )),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () =>
                        context.push(AppRoutes.createPost),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cream100,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: AppColors.shadowCard,
                      ),
                      child: const Text('Create post',
                          style: TextStyle(
                            color: AppColors.textOnCream,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          )),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.cream100,
              backgroundColor: AppColors.inkMid,
              onRefresh: () =>
                  ref.read(feedProvider.notifier).refresh(),
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.only(top: 8, bottom: 120),
                itemCount: posts.length + 1,
                itemBuilder: (_, i) {
                  if (i == posts.length) {
                    // Bottom loader
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.cream100,
                          ),
                        ),
                      ),
                    );
                  }
                  return PostCard(post: posts[i]);
                },
              ),
            ),
    );
  }
}
