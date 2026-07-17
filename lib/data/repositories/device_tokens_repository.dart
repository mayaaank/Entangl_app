import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/supabase_service.dart';

/// Persists FCM device tokens in Supabase for push delivery.
class DeviceTokensRepository {
  /// Lazy — must not touch Supabase until after [Supabase.initialize].
  get _db => SupabaseService.client;

  static String get currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }

  /// Upsert token for the authenticated user (unique on token).
  Future<void> upsertToken(String token) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null || token.isEmpty) return;

    await _db.from('device_tokens').upsert(
      {
        'user_id': uid,
        'token': token,
        'platform': currentPlatform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'token',
    );
  }

  /// Remove a specific device token.
  Future<void> deleteToken(String token) async {
    if (token.isEmpty) return;
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;

    await _db
        .from('device_tokens')
        .delete()
        .eq('token', token)
        .eq('user_id', uid);
  }

  /// Remove all tokens for the current user (full logout cleanup).
  Future<void> deleteAllForCurrentUser() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;

    await _db.from('device_tokens').delete().eq('user_id', uid);
  }
}
