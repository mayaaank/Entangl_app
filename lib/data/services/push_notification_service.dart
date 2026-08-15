import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_service.dart';

/// Registers this device with FCM and stores the token in Supabase
/// `device_tokens` (and optionally `profiles.fcm_token`).
///
/// Android-first: iOS / web / desktop no-op until APNs is configured.
/// Supabase remains the source of truth for notification *content*;
/// this service only enables FCM *delivery*.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const _prefsPushKey = 'notif_push';
  static const _androidChannelId = 'entangl_push';
  static const _androidChannelName = 'Entangl notifications';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _initialized = false;
  String? _currentToken;

  /// Whether this platform should register for FCM device tokens.
  bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!isSupported) {
      _log('skip init (platform not supported for push)');
      return;
    }

    await _initLocalNotifications();

    // Android 13+ runtime permission; also covers FCM notification permission.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    _log('permission: ${settings.authorizationStatus}');

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      _log('token refreshed');
      _currentToken = token;
      if (await _isPushEnabledInPrefs()) {
        await _upsertToken(token);
      }
    });

    _foregroundSub?.cancel();
    _foregroundSub =
        FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // If user already has a session and push is on, register now.
    if (SupabaseService.currentUserId != null &&
        await _isPushEnabledInPrefs()) {
      await registerToken();
    }
  }

  /// Call after login / when push is turned ON in Settings.
  Future<void> registerToken() async {
    if (!isSupported) {
      _log('registerToken skipped (unsupported platform)');
      return;
    }

    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      _log('registerToken skipped (no session)');
      return;
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _log('registerToken aborted (permission denied)');
        return;
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        _log('registerToken failed (null token)');
        return;
      }

      _currentToken = token;
      await _upsertToken(token);
      _log('token registered (${token.substring(0, token.length.clamp(0, 12))}…)');
    } catch (e, st) {
      _log('registerToken error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// Call when push is turned OFF or before sign-out.
  Future<void> unregisterToken() async {
    if (!isSupported) return;

    final userId = SupabaseService.currentUserId;
    final token = _currentToken ?? await _messaging.getToken();

    try {
      if (userId != null && token != null && token.isNotEmpty) {
        await SupabaseService.client
            .from('device_tokens')
            .delete()
            .eq('user_id', userId)
            .eq('token', token);
        _log('token row deleted');
      }

      // Clear backup column if it matches this device token.
      if (userId != null && token != null) {
        try {
          final row = await SupabaseService.client
              .from('profiles')
              .select('fcm_token')
              .eq('id', userId)
              .maybeSingle();
          if (row != null && row['fcm_token'] == token) {
            await SupabaseService.client
                .from('profiles')
                .update({'fcm_token': null}).eq('id', userId);
          }
        } catch (e) {
          _log('profiles.fcm_token clear skipped: $e');
        }
      }

      // Best-effort: drop FCM registration on this install.
      try {
        await _messaging.deleteToken();
      } catch (e) {
        _log('deleteToken skipped: $e');
      }
      _currentToken = null;
    } catch (e, st) {
      _log('unregisterToken error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// Re-sync token with prefs (e.g. after login or app resume).
  Future<void> syncWithPreferences() async {
    if (!isSupported) return;
    if (SupabaseService.currentUserId == null) return;

    if (await _isPushEnabledInPrefs()) {
      await registerToken();
    }
  }

  Future<void> _upsertToken(String token) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    final now = DateTime.now().toUtc().toIso8601String();

    await SupabaseService.client.from('device_tokens').upsert(
      {
        'user_id': userId,
        'token': token,
        'platform': 'android',
        'updated_at': now,
      },
      onConflict: 'token',
    );

    // Backup column used by older send paths / activity-push.
    try {
      await SupabaseService.client
          .from('profiles')
          .update({'fcm_token': token}).eq('id', userId);
    } catch (e) {
      _log('profiles.fcm_token update skipped: $e');
    }
  }

  Future<bool> _isPushEnabledInPrefs() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_prefsPushKey) ?? true;
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: 'Likes, follows, comments, and other activity',
      importance: Importance.high,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    await _local.show(
      id: notification?.hashCode ?? message.hashCode,
      title: title ?? 'Entangl',
      body: body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Likes, follows, comments, and other activity',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['route'] as String? ??
          message.data['post_id'] as String?,
    );
  }

  void _log(String msg) {
    debugPrint('[FCM] $msg');
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
  }
}

/// Must be a top-level function for background isolates.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is usually already available in the background isolate after
  // the plugin boots it; keep handler light. Heavy work stays on the server.
  debugPrint('[FCM] background message: ${message.messageId}');
}
