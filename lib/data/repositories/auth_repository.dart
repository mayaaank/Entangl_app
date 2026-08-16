import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../services/supabase_service.dart';

/// User closed the in-app Google account picker.
class GoogleSignInCancelled implements Exception {}

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

  /// Opens Google account chooser in an in-app auth sheet, then
  /// exchanges the callback for a session before returning.
  ///
  /// supabase_flutter's [signInWithOAuth] forces the system browser for
  /// Google on Android. We build the URL ourselves and present it with
  /// ASWebAuthenticationSession / Chrome Auth Tab so the sheet closes
  /// and control returns to the app.
  Future<void> signInWithGoogle() async {
    final res = await _client.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: AppConstants.oauthRedirectTo,
    );

    late final String callback;
    try {
      callback = await FlutterWebAuth2.authenticate(
        url: res.url,
        callbackUrlScheme: AppConstants.oauthCallbackScheme,
      );
    } on PlatformException catch (e) {
      final code = e.code.toUpperCase();
      if (code == 'CANCELED' || code == 'CANCELLED') {
        throw GoogleSignInCancelled();
      }
      rethrow;
    }

    await _client.auth.getSessionFromUrl(Uri.parse(callback));
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
