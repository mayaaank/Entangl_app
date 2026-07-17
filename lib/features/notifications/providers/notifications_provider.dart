import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((_) => NotificationsRepository());

class NotificationsNotifier
    extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() =>
      ref.read(notificationsRepositoryProvider).getNotifications();

  Future<void> refresh() async {
    try {
      final list =
          await ref.read(notificationsRepositoryProvider).getNotifications();
      state = AsyncData(list);
      ref.invalidate(unreadCountProvider);
    } catch (e, st) {
      if (!state.hasValue) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> markRead(String id) async {
    // Optimistic local update + badge refresh; network can lag behind.
    state = AsyncData((state.valueOrNull ?? [])
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList());
    ref.invalidate(unreadCountProvider);
    try {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
    } catch (_) {
      // Keep local read state; next refresh will reconcile.
    }
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllAsRead();
    state = AsyncData((state.valueOrNull ?? [])
        .map((n) => n.copyWith(isRead: true))
        .toList());
    ref.invalidate(unreadCountProvider);
  }

  Future<void> remove(String id) async {
    await ref.read(notificationsRepositoryProvider).deleteNotification(id);
    state = AsyncData(
        (state.valueOrNull ?? []).where((n) => n.id != id).toList());
    ref.invalidate(unreadCountProvider);
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
        NotificationsNotifier.new);

final unreadCountProvider = FutureProvider<int>((ref) =>
    ref.read(notificationsRepositoryProvider).getUnreadCount());
