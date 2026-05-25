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

  /// Send a password-reset email.
  /// The user will receive a link that opens the web reset-password page.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update password for the currently authenticated user
  /// (used from Edit Profile → Change Password).
  Future<void> updatePassword(String newPassword) async {
    final res = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (res.user == null) throw Exception('Failed to update password');
  }

  /// Update email for the currently authenticated user.
  /// Called when admin approves the email-change request.
  Future<void> updateEmail(String newEmail) async {
    final res = await _client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
    if (res.user == null) throw Exception('Failed to update email');
  }

  /// Get the current user's email from auth.
  String? get currentEmail => _client.auth.currentUser?.email;
}
