import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../models/notification_model.dart';
import '../repositories/device_tokens_repository.dart';

/// Android high-importance channel for FCM + local notifications.
const String kEntanglPushChannelId = 'entangl_push';
const String kEntanglPushChannelName = 'Entangl';
const String kEntanglPushChannelDesc = 'Likes, comments, follows, and replies';

/// Top-level background handler — must not use Riverpod or UI.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is available in the background isolate.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// Parses FCM / local-notification data into a [NotificationModel] for routing.
NotificationModel? notificationModelFromPushData(Map<String, dynamic> data) {
  final typeRaw = data['type'] as String?;
  if (typeRaw == null || typeRaw.isEmpty) return null;

  final id = (data['notification_id'] as String?)?.isNotEmpty == true
      ? data['notification_id'] as String
      : 'push-${DateTime.now().millisecondsSinceEpoch}';

  final actorId = data['actor_id'] as String? ?? '';
  final postId = _emptyToNull(data['post_id'] as String?);
  final commentId = _emptyToNull(data['comment_id'] as String?);

  return NotificationModel.fromJson({
    'id': id,
    'user_id': data['user_id'] as String? ?? '',
    'actor_id': actorId,
    'type': typeRaw,
    'post_id': postId,
    'comment_id': commentId,
    'is_read': false,
    'created_at': DateTime.now().toUtc().toIso8601String(),
  });
}

String? _emptyToNull(String? v) =>
    (v == null || v.isEmpty) ? null : v;

/// FCM + local notifications. Supabase remains auth/DB; this is delivery only.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Lazy so constructing [NotificationService] never touches Supabase
  /// before [Supabase.initialize] (important for main / hot restart order).
  DeviceTokensRepository get _tokensRepo => DeviceTokensRepository();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  bool _initialized = false;
  bool _started = false;
  String? _currentToken;

  /// Pending deep-link payload until the UI is ready (post-splash).
  NotificationModel? pendingOpenTarget;

  /// Called when a push should open content (UI must subscribe).
  final StreamController<NotificationModel> _openTargetController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get onOpenTarget => _openTargetController.stream;

  /// Called when a foreground message arrives (e.g. refresh unread badge).
  final StreamController<RemoteMessage> _foregroundController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundController.stream;

  Future<void> initializeLocalNotifications() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    if (!kIsWeb && Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        kEntanglPushChannelId,
        kEntanglPushChannelName,
        description: kEntanglPushChannelDesc,
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  /// Request permission, register token, attach message listeners.
  Future<void> start({required bool pushEnabled}) async {
    await initializeLocalNotifications();

    if (!pushEnabled) {
      await stop(deleteRemoteToken: true);
      return;
    }

    if (_started) {
      await _syncToken();
      return;
    }

    final granted = await _requestPermission();
    if (!granted) return;

    await _syncToken();

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      _currentToken = token;
      try {
        await _tokensRepo.upsertToken(token);
      } catch (_) {}
    });

    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((message) async {
      _foregroundController.add(message);
      await _showLocalFromRemote(message);
    });

    _onOpenedSub?.cancel();
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _emitOpenFromData(message.data);
    });

    // Terminated-state tap (cold start).
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      final model = notificationModelFromPushData(
        Map<String, dynamic>.from(initial.data),
      );
      if (model != null) {
        pendingOpenTarget = model;
        _openTargetController.add(model);
      }
    }

    // Local notification that launched the app.
    final launchDetails = await _local.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        _emitOpenFromPayload(payload);
      }
    }

    _started = true;
  }

  /// Unregister listeners and optionally remove token from Supabase + FCM.
  Future<void> stop({bool deleteRemoteToken = false}) async {
    final token = _currentToken;
    _tokenRefreshSub?.cancel();
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
    _tokenRefreshSub = null;
    _onMessageSub = null;
    _onOpenedSub = null;
    _started = false;

    if (deleteRemoteToken && token != null && token.isNotEmpty) {
      try {
        await _tokensRepo.deleteToken(token);
      } catch (_) {}
      try {
        await _messaging.deleteToken();
      } catch (_) {}
      _currentToken = null;
    }
  }

  /// Remove this device token before Supabase sign-out (session still valid).
  Future<void> unregisterBeforeSignOut() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _tokensRepo.deleteToken(token);
      } catch (_) {}
    }
    await stop(deleteRemoteToken: false);
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    _currentToken = null;
  }

  Future<bool> _requestPermission() async {
    if (kIsWeb) return false;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _syncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      _currentToken = token;
      await _tokensRepo.upsertToken(token);
    } catch (_) {}
  }

  Future<void> _showLocalFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ??
        data['title'] as String? ??
        'Entangl';
    final body = notification?.body ??
        data['body'] as String? ??
        '';

    if (title.isEmpty && body.isEmpty) return;

    final payload = jsonEncode(data);

    const androidDetails = AndroidNotificationDetails(
      kEntanglPushChannelId,
      kEntanglPushChannelName,
      channelDescription: kEntanglPushChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    _emitOpenFromPayload(payload);
  }

  void _emitOpenFromPayload(String payload) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      _emitOpenFromData(map.map((k, v) => MapEntry(k, v?.toString() ?? '')));
    } catch (_) {}
  }

  void _emitOpenFromData(Map<String, dynamic> data) {
    final model = notificationModelFromPushData(data);
    if (model == null) return;
    pendingOpenTarget = model;
    _openTargetController.add(model);
  }

  /// Consume and clear a pending cold-start target (once UI is ready).
  NotificationModel? takePendingOpenTarget() {
    final m = pendingOpenTarget;
    pendingOpenTarget = null;
    return m;
  }
}
