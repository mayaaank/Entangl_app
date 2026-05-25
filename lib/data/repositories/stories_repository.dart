import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class StoriesRepository {
  final _db = SupabaseService.client;

  Future<List<UserStories>> getActiveStories() async {
    final uid    = SupabaseService.currentUserId!;
    final cutoff = DateTime.now()
        .subtract(const Duration(hours: 24))
        .toIso8601String();

    final rows = await _db
        .from('stories')
        .select('''
          id, user_id, media_url, media_type, created_at,
          profiles (id, username, full_name, avatar_url),
          story_views (viewer_id),
          story_likes (user_id)
        ''')
        .gte('created_at', cutoff)
        .order('created_at', ascending: false);

    final stories = (rows as List)
        .map((r) {
          debugPrint('ENTANGL story raw: id=${(r as Map)['id']}, '
              'media_url=${r['media_url']}, '
              'media_type=${r['media_type']}');
          return StoryModel.fromJson(
                r as Map<String, dynamic>,
                currentUserId: uid,
              );
        })
        .toList();

    final Map<String, List<StoryModel>> grouped = {};
    final Map<String, UserModel>        users   = {};

    for (final story in stories) {
      grouped.putIfAbsent(story.userId, () => []).add(story);
      if (story.author != null) {
        users[story.userId] = story.author!;
      }
    }

    final result = <UserStories>[];

    // Own stories first
    if (grouped.containsKey(uid) && users.containsKey(uid)) {
      final ownStories = grouped[uid]!;
      result.add(UserStories(
        user:      users[uid]!,
        stories:   ownStories,
        allViewed: false,
      ));
    }

    // Others
    for (final entry in grouped.entries) {
      if (entry.key == uid) continue;
      if (!users.containsKey(entry.key)) continue;
      final allViewed = entry.value.every((s) => s.isViewed);
      result.add(UserStories(
        user:      users[entry.key]!,
        stories:   entry.value,
        allViewed: allViewed,
      ));
    }

    return result;
  }

  Future<void> createStory({
    required File           file,
    required StoryMediaType mediaType,
  }) async {
    final uid  = SupabaseService.currentUserId!;
    final ext  = file.path.split('.').last;
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _db.storage.from('stories').upload(path, file);
    final url = _db.storage.from('stories').getPublicUrl(path);

    await _db.from('stories').insert({
      'user_id':    uid,
      'media_url':  url,
      'media_type': mediaType == StoryMediaType.video ? 'video' : 'image',
    });
  }

  Future<void> markViewed(String storyId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('story_views').upsert({
      'story_id':  storyId,
      'viewer_id': uid,
    });
  }

  Future<void> likeStory(String storyId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('story_likes').upsert({
      'story_id': storyId,
      'user_id':  uid,
    });
  }

  Future<void> unlikeStory(String storyId) async {
    final uid = SupabaseService.currentUserId!;
    await _db.from('story_likes')
        .delete()
        .eq('story_id', storyId)
        .eq('user_id', uid);
  }

  Future<void> deleteStory(String storyId) async {
    await _db.from('stories').delete().eq('id', storyId);
  }

  Future<List<UserModel>> getStoryViewers(String storyId) async {
    final rows = await _db
        .from('story_views')
        .select('profiles:viewer_id (id, username, full_name, avatar_url)')
        .eq('story_id', storyId);
    return (rows as List).map((r) {
      final p = r['profiles'];
      final m = p is List
          ? p.first as Map<String, dynamic>
          : p as Map<String, dynamic>;
      return UserModel.fromJson(m);
    }).toList();
  }
}
