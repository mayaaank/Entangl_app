import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/posts_repository.dart';

final postsRepositoryProvider =
    Provider<PostsRepository>((_) => PostsRepository());

class FeedNotifier extends AsyncNotifier<List<PostModel>> {
  // Track in-flight optimistic state so DB rebuilds
  // don't overwrite what the user just tapped.
  final _likedIds    = <String>{};
  final _dislikedIds = <String>{};
  final _unlikedIds  = <String>{};
  final _undislikedIds = <String>{};

  /// Whether another page may exist (hide end-of-list spinner when false).
  bool hasMore = true;

  /// True while a background page fetch is in flight.
  bool isLoadingMore = false;

  @override
  Future<List<PostModel>> build() async {
    final posts = await ref.read(postsRepositoryProvider).getFeedPosts();
    hasMore = posts.length >= AppConstants.feedPageSize;
    return _applyPending(posts);
  }

  // Apply any in-flight optimistic state on top of fresh DB data
  List<PostModel> _applyPending(List<PostModel> posts) {
    return posts.map((p) {
      var post = p;
      if (_likedIds.contains(p.id) && !p.isLiked) {
        post = post.copyWith(
          isLiked:    true,
          isDisliked: false,
          likeCount:  post.likeCount + 1,
          dislikeCount: post.isDisliked
              ? post.dislikeCount - 1
              : post.dislikeCount,
        );
      } else if (_unlikedIds.contains(p.id) && p.isLiked) {
        post = post.copyWith(
          isLiked:   false,
          likeCount: post.likeCount - 1,
        );
      }
      if (_dislikedIds.contains(p.id) && !p.isDisliked) {
        post = post.copyWith(
          isDisliked:  true,
          isLiked:     false,
          dislikeCount: post.dislikeCount + 1,
          likeCount: post.isLiked
              ? post.likeCount - 1
              : post.likeCount,
        );
      } else if (_undislikedIds.contains(p.id) && p.isDisliked) {
        post = post.copyWith(
          isDisliked:   false,
          dislikeCount: post.dislikeCount - 1,
        );
      }
      return post;
    }).toList();
  }

  /// Pull-to-refresh without wiping the list (keeps previous data visible).
  Future<void> refresh() async {
    try {
      final posts =
          await ref.read(postsRepositoryProvider).getFeedPosts();
      hasMore = posts.length >= AppConstants.feedPageSize;
      state = AsyncData(_applyPending(posts));
    } catch (e, st) {
      debugPrint('CONNECT refresh error: $e');
      // Only surface error if we have nothing to show.
      if (!state.hasValue) {
        state = AsyncError(e, st);
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull ?? [];
    if (!hasMore || isLoadingMore || current.isEmpty) return;
    isLoadingMore = true;
    // Nudge listeners so footer can show a spinner.
    state = AsyncData(current);
    try {
      final more = await ref
          .read(postsRepositoryProvider)
          .getFeedPosts(offset: current.length);
      if (more.isEmpty || more.length < AppConstants.feedPageSize) {
        hasMore = false;
      }
      if (more.isNotEmpty) {
        state = AsyncData([...current, ..._applyPending(more)]);
      } else {
        state = AsyncData(current);
      }
    } catch (e) {
      debugPrint('CONNECT loadMore error: $e');
      state = AsyncData(current);
    } finally {
      isLoadingMore = false;
    }
  }

  void toggleLike(String postId) {
    final posts = state.valueOrNull;
    if (posts == null) return;
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post      = posts[idx];
    final nowLiked  = !post.isLiked;
    final repo      = ref.read(postsRepositoryProvider);

    // Update pending sets
    if (nowLiked) {
      _likedIds.add(postId);
      _unlikedIds.remove(postId);
      _dislikedIds.remove(postId);
      _undislikedIds.add(postId);
    } else {
      _unlikedIds.add(postId);
      _likedIds.remove(postId);
    }

    // Apply immediately to current state
    final updated = post.copyWith(
      isLiked:      nowLiked,
      isDisliked:   nowLiked ? false : post.isDisliked,
      likeCount:    nowLiked ? post.likeCount + 1 : post.likeCount - 1,
      dislikeCount: nowLiked && post.isDisliked
          ? post.dislikeCount - 1
          : post.dislikeCount,
    );
    final newList = [...posts];
    newList[idx]  = updated;
    state         = AsyncData(newList);

    // Persist — clear pending on success or revert on failure
    (nowLiked ? repo.likePost(postId) : repo.unlikePost(postId))
        .then((_) {
      _likedIds.remove(postId);
      _unlikedIds.remove(postId);
    }).catchError((e) {
      debugPrint('CONNECT like error: $e');
      _likedIds.remove(postId);
      _unlikedIds.remove(postId);
      _dislikedIds.remove(postId);
      _undislikedIds.remove(postId);
      // Revert
      final current = state.valueOrNull ?? [];
      final i = current.indexWhere((p) => p.id == postId);
      if (i == -1) return;
      final reverted = [...current];
      reverted[i] = post;
      state = AsyncData(reverted);
    });
  }

  void toggleDislike(String postId) {
    final posts = state.valueOrNull;
    if (posts == null) return;
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post         = posts[idx];
    final nowDisliked  = !post.isDisliked;
    final repo         = ref.read(postsRepositoryProvider);

    if (nowDisliked) {
      _dislikedIds.add(postId);
      _undislikedIds.remove(postId);
      _likedIds.remove(postId);
      _unlikedIds.add(postId);
    } else {
      _undislikedIds.add(postId);
      _dislikedIds.remove(postId);
    }

    final updated = post.copyWith(
      isDisliked:   nowDisliked,
      isLiked:      nowDisliked ? false : post.isLiked,
      dislikeCount: nowDisliked
          ? post.dislikeCount + 1
          : post.dislikeCount - 1,
      likeCount: nowDisliked && post.isLiked
          ? post.likeCount - 1
          : post.likeCount,
    );
    final newList = [...posts];
    newList[idx]  = updated;
    state         = AsyncData(newList);

    (nowDisliked
            ? repo.dislikePost(postId)
            : repo.undislikePost(postId))
        .then((_) {
      _dislikedIds.remove(postId);
      _undislikedIds.remove(postId);
    }).catchError((e) {
      debugPrint('CONNECT dislike error: $e');
      _dislikedIds.remove(postId);
      _undislikedIds.remove(postId);
      _likedIds.remove(postId);
      _unlikedIds.remove(postId);
      final current = state.valueOrNull ?? [];
      final i = current.indexWhere((p) => p.id == postId);
      if (i == -1) return;
      final reverted = [...current];
      reverted[i] = post;
      state = AsyncData(reverted);
    });
  }

  Future<void> deletePost(String postId) async {
    final posts = state.valueOrNull ?? [];
    state = AsyncData(posts.where((p) => p.id != postId).toList());
    try {
      await ref.read(postsRepositoryProvider).deletePost(postId);
    } catch (e) {
      debugPrint('CONNECT deletePost error: $e');
      refresh();
    }
  }
}

final feedProvider =
    AsyncNotifierProvider<FeedNotifier, List<PostModel>>(
        FeedNotifier.new);
