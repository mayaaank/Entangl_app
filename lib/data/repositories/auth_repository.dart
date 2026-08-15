import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final _client = SupabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'username': username, 'avatar_url': ''},
    );
    if (res.user == null) throw Exception('Sign up failed');
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<void> updateEmail(String newEmail) async {
    final res = await _client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
    if (res.user == null) throw Exception('Failed to update email');
  }

  String? get currentEmail => _client.auth.currentUser?.email;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _client.auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw Exception('No email on this account.');
    }
    await _client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOutOtherSessions() =>
      _client.auth.signOut(scope: SignOutScope.others);

  /// Removes this user's scraps, then signs out.
  /// Full auth-user deletion needs a privileged backend function.
  Future<void> deleteAccount({required String password}) async {
    final user = _client.auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw Exception('No email on this account.');
    }
    await _client.auth.signInWithPassword(email: email, password: password);
    await _client.from('posts').delete().eq('user_id', user.id);
    try {
      await _client.rpc('delete_own_account');
    } catch (_) {}
    await _client.auth.signOut();
  }
}
