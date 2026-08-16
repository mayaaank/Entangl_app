import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../data/services/push_notification_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

final authStateProvider = StreamProvider<AuthState>((ref) =>
    ref.watch(authRepositoryProvider).authStateChanges);

/// Holds loading / error state for auth actions.
/// Contains NO navigation logic — callers react to state changes.
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      // Push must never block login if FCM fails.
      try {
        await PushNotificationService.instance.syncWithPreferences();
      } catch (_) {}
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            fullName: fullName,
            username: username,
          );
      await UsersRepository().markOwnProfilePending();
      try {
        await PushNotificationService.instance.syncWithPreferences();
      } catch (_) {}
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(authRepositoryProvider).signInWithGoogle();
      } on GoogleSignInCancelled {
        return;
      }
      try {
        await PushNotificationService.instance.syncWithPreferences();
      } catch (_) {}
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        // Remove this device token while the session is still valid (RLS).
        await PushNotificationService.instance.unregisterToken();
      } catch (_) {}
      await ref.read(authRepositoryProvider).signOut();
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
    });
  }

  Future<void> signOutOtherSessions() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(authRepositoryProvider).signOutOtherSessions();
    });
  }

  Future<void> deleteAccount({required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await PushNotificationService.instance.unregisterToken();
      } catch (_) {}
      await ref.read(authRepositoryProvider).deleteAccount(password: password);
    });
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
