import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/notification_service.dart';

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
    state = await AsyncValue.guard(() => ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(authRepositoryProvider)
        .signUp(email: email, password: password,
                fullName: fullName, username: username));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    // Drop FCM token while session is still valid (RLS needs auth.uid()).
    try {
      await NotificationService.instance.unregisterBeforeSignOut();
    } catch (_) {}
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).signOut());
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
