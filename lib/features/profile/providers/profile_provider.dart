import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/profile_stats_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/posts_repository.dart';
import '../../../data/repositories/users_repository.dart';

final usersRepositoryProvider =
    Provider<UsersRepository>((_) => UsersRepository());

final ownProfileProvider = FutureProvider<UserModel?>((ref) =>
    ref.watch(usersRepositoryProvider).getOwnProfile());

final profileStatsProvider =
    FutureProvider.family<ProfileStatsModel?, String>((ref, userId) =>
        ref.watch(usersRepositoryProvider).getProfileStats(userId));

final userPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) =>
        PostsRepository().getUserPosts(userId));

// ── Follow state ─────────────────────────────────────────────
class FollowState {
  final bool   isFollowing;
  final int    followerDelta;
  final String targetUserId;

  const FollowState({
    this.isFollowing   = false,
    this.followerDelta = 0,
    this.targetUserId  = '',
  });
}

class FollowNotifier extends Notifier<FollowState> {
  @override
  FollowState build() => const FollowState();

  void init(bool isFollowing, String userId) {
    if (state.targetUserId == userId) return;
    state = FollowState(
      isFollowing:   isFollowing,
      followerDelta: 0,
      targetUserId:  userId,
    );
  }

  Future<void> toggle() async {
    final repo         = ref.read(usersRepositoryProvider);
    final prev         = state;
    final nowFollowing = !state.isFollowing;

    state = FollowState(
      isFollowing:   nowFollowing,
      followerDelta: nowFollowing
          ? prev.followerDelta + 1
          : prev.followerDelta - 1,
      targetUserId:  prev.targetUserId,
    );

    nowFollowing
        ? HapticFeedback.mediumImpact()
        : HapticFeedback.lightImpact();

    try {
      nowFollowing
          ? await repo.followUser(prev.targetUserId)
          : await repo.unfollowUser(prev.targetUserId);

      ref.invalidate(profileStatsProvider(prev.targetUserId));
    } catch (_) {
      state = prev;
    }
  }
}

final followProvider =
    NotifierProvider<FollowNotifier, FollowState>(FollowNotifier.new);

// ── Edit profile ─────────────────────────────────────────────
class EditProfileState {
  final String  fullName;
  final String  username;
  final String  bio;
  final String? avatarUrl;
  final File?   avatarFile;
  final bool    isSaving;
  final bool    saved;
  final String? error;

  const EditProfileState({
    this.fullName  = '',
    this.username  = '',
    this.bio       = '',
    this.avatarUrl,
    this.avatarFile,
    this.isSaving  = false,
    this.saved     = false,
    this.error,
  });

  EditProfileState copyWith({
    String? fullName, String? username, String? bio,
    String? avatarUrl, File? avatarFile,
    bool? isSaving, bool? saved, String? error,
  }) => EditProfileState(
    fullName:   fullName   ?? this.fullName,
    username:   username   ?? this.username,
    bio:        bio        ?? this.bio,
    avatarUrl:  avatarUrl  ?? this.avatarUrl,
    avatarFile: avatarFile ?? this.avatarFile,
    isSaving:   isSaving   ?? this.isSaving,
    saved:      saved      ?? this.saved,
    error:      error,
  );
}

class EditProfileNotifier extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  void load(UserModel profile) {
    state = state.copyWith(
      fullName:  profile.fullName,
      username:  profile.username,
      bio:       profile.bio ?? '',
      avatarUrl: profile.avatarUrl,
    );
  }

  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setUsername(String v) => state = state.copyWith(username: v);
  void setBio(String v)      => state = state.copyWith(bio: v);
  void setAvatar(File f)     => state = state.copyWith(avatarFile: f);

  Future<void> save() async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true);
    try {
      // Pass old URL so repository can evict it from image cache
      final updatedUser = await ref.read(usersRepositoryProvider).updateProfile(
        fullName:     state.fullName,
        username:     state.username,
        bio:          state.bio,
        avatarFile:   state.avatarFile,
        oldAvatarUrl: state.avatarUrl,
      );

      // Invalidate so every widget reading ownProfileProvider
      // gets fresh data immediately after save
      ref.invalidate(ownProfileProvider);

      // Also invalidate this user's profile stats so the profile
      // screen re-renders with the new name/avatar
      ref.invalidate(profileStatsProvider(updatedUser.id));

      state = state.copyWith(isSaving: false, saved: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
        EditProfileNotifier.new);