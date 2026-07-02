import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/post_model.dart';
import '../services/supabase_service.dart';

class PostsRepository {
  final _db = SupabaseService.client;

  Future<List<PostModel>> getFeedPosts({int offset = 0}) async {
    try {
      final uid = SupabaseService.currentUserId;

      // Step 1: fetch posts alone first to isolate the issue
      final rows = await _db
          .from('posts')
          .select('''
            id,
            user_id,
            content,
            image_url,
            created_at,
            profiles (
              id,
              username,
              full_name,
              avatar_url
            ),
            likes (
              id,
              user_id
            ),
            dislikes (
              id,
              user_id
            ),
            comments (
              id
            )
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + AppConstants.feedPageSize - 1);

      debugPrint('CONNECT: fetched ${(rows as List).length} posts');

      return (rows as List)
          .map((r) => PostModel.fromJson(
                r as Map<String, dynamic>,
                currentUserId: uid,
              ))
          .toList();
    } catch (e, st) {
      debugPrint('CONNECT ERROR getFeedPosts: $e');
      debugPrint('CONNECT STACK: $st');
      rethrow;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId, {int offset = 0}) async {
    try {
      final uid = SupabaseService.currentUserId;
      final rows = await _db
          .from('posts')
          .select('''
            id,
            user_id,
            content,
            image_url,
            created_at,
            profiles (
              id,
              username,
              full_name,
              avatar_url
            ),
            likes (
              id,
              user_id
            ),
            dislikes (
              id,
              user_id
            ),
            comments (
              id
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + AppConstants.feedPageSize - 1);

      debugPrint('CONNECT: fetched ${(rows as List).length} user posts');

      return (rows as List)
          .map((r) => PostModel.fromJson(
                r as Map<String, dynamic>,
                currentUserId: uid,
              ))
          .toList();
    } catch (e, st) {
      debugPrint('CONNECT ERROR getUserPosts: $e');
      debugPrint('CONNECT STACK: $st');
      rethrow;
    }
  }

  Future<void> createPost({required String content, File? imageFile}) async {
    final uid = SupabaseService.currentUserId!;
    String? imageUrl;
    if (imageFile != null) {
      final ext  = imageFile.path.split('.').last;
      final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _db.storage
          .from(AppConstants.postImagesBucket)
          .upload(path, imageFile);
      imageUrl = _db.storage
          .from(AppConstants.postImagesBucket)
          .getPublicUrl(path);
    }
    await _db.from('posts').insert({
      'user_id': uid,
      'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
    });
  }

  Future<void> deletePost(String postId) =>
      _db.from('posts').delete().eq('id', postId);

  Future<void> likePost(String postId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('dislikes').delete()
        .eq('post_id', postId).eq('user_id', uid);
    await _db.from('likes').insert({'user_id': uid, 'post_id': postId});
  }

  Future<void> unlikePost(String postId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('likes').delete()
        .eq('post_id', postId).eq('user_id', uid);
  }

  Future<void> dislikePost(String postId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('likes').delete()
        .eq('post_id', postId).eq('user_id', uid);
    await _db.from('dislikes').insert({'user_id': uid, 'post_id': postId});
  }

  Future<void> undislikePost(String postId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('dislikes').delete()
        .eq('post_id', postId).eq('user_id', uid);
  }

  Future<List<Map<String, dynamic>>> getPostLikes(String postId) async {
    final rows = await _db
        .from('likes')
        .select('created_at, profiles (id, username, full_name, avatar_url)')
        .eq('post_id', postId);
    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> getPostDislikes(String postId) async {
    final rows = await _db
        .from('dislikes')
        .select('created_at, profiles (id, username, full_name, avatar_url)')
        .eq('post_id', postId);
    return List<Map<String, dynamic>>.from(rows as List);
  }
}