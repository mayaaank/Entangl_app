// App-wide constants
// Sensitive keys (Supabase URL/key) live in lib/core/secrets.dart
// which is gitignored. See secrets.dart.example for the template.
class AppConstants {
  AppConstants._();

  // ── Storage buckets ───────────────────────────────────────
  static const String avatarsBucket    = 'avatars';
  static const String postImagesBucket = 'post-images';

  // ── Pagination ────────────────────────────────────────────
  static const int feedPageSize             = 20;
  static const int notificationsPageSize    = 30;
  static const int searchResultsLimit       = 15;

  // ── Validation ────────────────────────────────────────────
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 30;
  static const int bioMaxLength      = 160;
  static const int postMaxLength     = 500;
  static const int passwordMinLength = 6;

  /// Deep link that returns from Google / Apple OAuth.
  /// Must be listed in Supabase Auth → URL Configuration → Redirect URLs.
  static const oauthRedirectTo = 'entangl://auth-callback';
  static const oauthCallbackScheme = 'entangl';

  /// Profile emails that can open Admin Requests.
  static const adminEmails = [
    'rekt11.cam@gmail.com',
  ];

  static bool isAdminEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return adminEmails.contains(email.toLowerCase());
  }
}
