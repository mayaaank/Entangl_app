import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/push_notification_service.dart';

class NotificationSettings {
  final bool pushEnabled;
  final bool followers;
  final bool likes;
  final bool dislikes;
  final bool comments;
  final bool replies;

  const NotificationSettings({
    this.pushEnabled = true,
    this.followers   = true,
    this.likes       = true,
    this.dislikes    = false,
    this.comments    = true,
    this.replies     = true,
  });

  NotificationSettings copyWith({
    bool? pushEnabled, bool? followers, bool? likes,
    bool? dislikes, bool? comments, bool? replies,
  }) =>
      NotificationSettings(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        followers:   followers   ?? this.followers,
        likes:       likes       ?? this.likes,
        dislikes:    dislikes    ?? this.dislikes,
        comments:    comments    ?? this.comments,
        replies:     replies     ?? this.replies,
      );
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    _load();
    return const NotificationSettings();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = NotificationSettings(
      pushEnabled: p.getBool('notif_push')      ?? true,
      followers:   p.getBool('notif_followers') ?? true,
      likes:       p.getBool('notif_likes')     ?? true,
      dislikes:    p.getBool('notif_dislikes')  ?? false,
      comments:    p.getBool('notif_comments')  ?? true,
      replies:     p.getBool('notif_replies')   ?? true,
    );
  }

  Future<void> toggle(String key) async {
    final p = await SharedPreferences.getInstance();
    switch (key) {
      case 'push':
        final enabled = !state.pushEnabled;
        state = state.copyWith(pushEnabled: enabled);
        await p.setBool('notif_push', enabled);
        if (enabled) {
          await PushNotificationService.instance.registerToken();
        } else {
          await PushNotificationService.instance.unregisterToken();
        }
      case 'followers':
        state = state.copyWith(followers: !state.followers);
        await p.setBool('notif_followers', state.followers);
      case 'likes':
        state = state.copyWith(likes: !state.likes);
        await p.setBool('notif_likes', state.likes);
      case 'dislikes':
        state = state.copyWith(dislikes: !state.dislikes);
        await p.setBool('notif_dislikes', state.dislikes);
      case 'comments':
        state = state.copyWith(comments: !state.comments);
        await p.setBool('notif_comments', state.comments);
      case 'replies':
        state = state.copyWith(replies: !state.replies);
        await p.setBool('notif_replies', state.replies);
    }
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        NotificationSettingsNotifier.new);
