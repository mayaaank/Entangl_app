import 'package:supabase_flutter/supabase_flutter.dart';

/// Single source of truth for the Supabase client.
/// Nothing else should import supabase_flutter directly.
class SupabaseService {
  SupabaseService._();
  static SupabaseClient get client => Supabase.instance.client;
  static User?    get currentUser   => client.auth.currentUser;
  static String?  get currentUserId => currentUser?.id;
  static Session? get currentSession => client.auth.currentSession;

  static String? get currentEmail {
    try {
      return currentUser?.email;
    } catch (_) {
      return null;
    }
  }
}
