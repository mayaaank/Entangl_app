import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../utils/notification_navigation.dart';
import 'notifications_provider.dart';

/// Binds FCM token lifecycle to Supabase auth + local push settings.
///
/// Watched from [EntanglApp] so it stays alive for the whole session.
final pushBootstrapProvider = Provider<void>((ref) {
  final service = NotificationService.instance;

  Future<void> apply({required bool signedIn, required bool pushEnabled}) async {
    if (!signedIn) {
      await service.stop(deleteRemoteToken: false);
      return;
    }
    await service.start(pushEnabled: pushEnabled);
  }

  // Auth stream (sign-in / sign-out / token refresh events).
  ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
    next.whenData((authState) async {
      final signedIn = authState.session != null ||
          SupabaseService.currentSession != null;
      final pushEnabled = ref.read(notificationSettingsProvider).pushEnabled;

      if (authState.event == AuthChangeEvent.signedOut) {
        await service.stop(deleteRemoteToken: false);
        return;
      }

      await apply(signedIn: signedIn, pushEnabled: pushEnabled);
    });
  });

  // Push on/off toggle in settings.
  ref.listen<NotificationSettings>(notificationSettingsProvider, (prev, next) {
    final signedIn = SupabaseService.currentSession != null;
    if (!signedIn) return;
    unawaited(apply(signedIn: true, pushEnabled: next.pushEnabled));
  });

  // Foreground message → refresh unread badge.
  final fgSub = service.onForegroundMessage.listen((_) {
    ref.invalidate(unreadCountProvider);
    ref.read(notificationsProvider.notifier).refresh();
  });
  ref.onDispose(fgSub.cancel);

  // Cold start / already signed in when provider first builds.
  final session = SupabaseService.currentSession;
  final pushEnabled = ref.read(notificationSettingsProvider).pushEnabled;
  if (session != null) {
    unawaited(apply(signedIn: true, pushEnabled: pushEnabled));
  }

  return;
});

/// Widget that consumes [pushBootstrapProvider] and routes push taps once UI
/// has a [BuildContext] with [GoRouter] / modals available.
class PushNotificationBinder extends ConsumerStatefulWidget {
  final Widget child;
  const PushNotificationBinder({super.key, required this.child});

  @override
  ConsumerState<PushNotificationBinder> createState() =>
      _PushNotificationBinderState();
}

class _PushNotificationBinderState
    extends ConsumerState<PushNotificationBinder> {
  StreamSubscription? _openSub;
  bool _handledInitial = false;

  @override
  void initState() {
    super.initState();
    final service = NotificationService.instance;
    _openSub = service.onOpenTarget.listen((model) {
      _routeWhenReady(model);
    });
    // Drain cold-start pending after first frame (splash may still be up).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryConsumePending();
    });
  }

  @override
  void dispose() {
    _openSub?.cancel();
    super.dispose();
  }

  void _tryConsumePending() {
    if (_handledInitial) return;
    final pending = NotificationService.instance.takePendingOpenTarget();
    if (pending != null) {
      _handledInitial = true;
      _routeWhenReady(pending);
    }
  }

  Future<void> _routeWhenReady(NotificationModel model) async {
    // Wait until we are past splash and have a session.
    for (var i = 0; i < 20; i++) {
      if (!mounted) return;
      final hasSession = SupabaseService.currentSession != null;
      if (hasSession) break;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (!mounted) return;
    if (SupabaseService.currentSession == null) return;

    // Extra beat so home shell can mount after splash redirect.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    try {
      await openNotificationTarget(context, ref, model);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pushBootstrapProvider);
    // Retry pending once auth/session is available.
    ref.listen(authStateProvider, (prev, next) {
      next.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryConsumePending();
        });
      });
    });
    return widget.child;
  }
}
