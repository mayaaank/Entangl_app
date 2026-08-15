import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/post_model.dart';
import '../../feed/providers/feed_provider.dart';

class ScrapsPage {
  final List<PostModel> items;
  final bool hasMore;
  final bool loadingMore;

  const ScrapsPage({
    required this.items,
    this.hasMore = false,
    this.loadingMore = false,
  });

  ScrapsPage copyWith({
    List<PostModel>? items,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      ScrapsPage(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class ScrapsNotifier extends FamilyAsyncNotifier<ScrapsPage, String> {
  @override
  Future<ScrapsPage> build(String userId) async {
    final items =
        await ref.read(postsRepositoryProvider).getUserPosts(userId);
    return ScrapsPage(
      items: items,
      hasMore: items.length >= AppConstants.feedPageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref.read(postsRepositoryProvider).getUserPosts(
            arg,
            offset: current.items.length,
          );
      state = AsyncData(ScrapsPage(
        items: [...current.items, ...next],
        hasMore: next.length >= AppConstants.feedPageSize,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final scrapsProvider =
    AsyncNotifierProvider.family<ScrapsNotifier, ScrapsPage, String>(
  ScrapsNotifier.new,
);
