import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/profile_stats_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UsersRepository {
  final _db = SupabaseService.client;

  Future<UserModel?> getOwnProfile() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return null;
    final row = await _db.from('profiles').select().eq('id', uid).single();
    return UserModel.fromJson(row as Map<String, dynamic>);
  }

  Future<ProfileStatsModel?> getProfileStats(String userId) async {
    final uid = SupabaseService.currentUserId;

    final profile = await _db.from('profiles').select()
        .eq('id', userId).single();

    final followersRes = await _db.from('follows')
        .select('id')
        .eq('following_id', userId);
    final followerCount = (followersRes as List).length;

    final followingRes = await _db.from('follows')
        .select('id')
        .eq('follower_id', userId);
    final followingCount = (followingRes as List).length;

    final postsRes = await _db.from('posts')
        .select('id')
        .eq('user_id', userId);
    final postCount = (postsRes as List).length;

    bool isFollowing = false;
    if (uid != null && uid != userId) {
      final f = await _db.from('follows').select()
          .eq('follower_id', uid).eq('following_id', userId).maybeSingle();
      isFollowing = f != null;
    }

    return ProfileStatsModel(
      user: UserModel.fromJson(profile as Map<String, dynamic>),
      postCount:      postCount,
      followerCount:  followerCount,
      followingCount: followingCount,
      isFollowing:    isFollowing,
    );
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String username,
    String? bio,
    File?   avatarFile,
    String? oldAvatarUrl, // passed in so we can evict old cache entry
  }) async {
    final uid = SupabaseService.currentUserId!;
    String? avatarUrl;

    if (avatarFile != null) {
      // Use a timestamp suffix so the public URL changes every upload,
      // which busts CachedNetworkImage's disk + memory cache automatically.
      final ext       = avatarFile.path.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path      = '$uid/avatar_$timestamp.$ext';

      await _db.storage.from(AppConstants.avatarsBucket).upload(
            path, avatarFile,
            fileOptions: const FileOptions(upsert: true));

      avatarUrl = _db.storage
          .from(AppConstants.avatarsBucket)
          .getPublicUrl(path);

      // Evict the OLD url from CachedNetworkImage so it doesn't
      // show the stale image anywhere else in the app.
      if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(oldAvatarUrl);
      }
    }

    final row = await _db.from('profiles').update({
      'full_name':  fullName,
      'username':   username,
      if (bio != null)        'bio':        bio,
      if (avatarUrl != null)  'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid).select().single();

    return UserModel.fromJson(row as Map<String, dynamic>);
  }

  Future<void> followUser(String userId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('follows')
        .insert({'follower_id': uid, 'following_id': userId});
  }

  Future<void> unfollowUser(String userId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('follows').delete()
        .eq('follower_id', uid).eq('following_id', userId);
  }

  Future<List<UserModel>> getFollowers(String userId) async {
    final rows = await _db
        .from('follows')
        .select('profiles!follower_id (id, username, full_name, avatar_url, created_at)')
        .eq('following_id', userId);
    return _extractProfiles(rows as List);
  }

  Future<List<UserModel>> getFollowing(String userId) async {
    final rows = await _db
        .from('follows')
        .select('profiles!following_id (id, username, full_name, avatar_url, created_at)')
        .eq('follower_id', userId);
    return _extractProfiles(rows as List);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _db
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,full_name.ilike.%$query%')
        .limit(AppConstants.searchResultsLimit);
    return (rows as List)
        .map((r) => UserModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  List<UserModel> _extractProfiles(List rows) {
    return rows.map((item) {
      final p = item['profiles'];
      final m = p is List
          ? p.first as Map<String, dynamic>
          : p as Map<String, dynamic>;
      return UserModel.fromJson(m);
    }).toList();
  }
}