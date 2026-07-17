import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';

const _kRecentKey = 'entangl_recent_searches_v1';
const _maxRecent = 8;

class RecentSearchEntry {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;

  const RecentSearchEntry({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
  });

  factory RecentSearchEntry.fromUser(UserModel u) => RecentSearchEntry(
        id: u.id,
        username: u.username,
        fullName: u.fullName,
        avatarUrl: u.avatarUrl,
      );

  factory RecentSearchEntry.fromJson(Map<String, dynamic> j) =>
      RecentSearchEntry(
        id: j['id'] as String,
        username: j['username'] as String? ?? '',
        fullName: j['fullName'] as String? ?? '',
        avatarUrl: j['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
      };
}

class RecentSearchNotifier extends AsyncNotifier<List<RecentSearchEntry>> {
  @override
  Future<List<RecentSearchEntry>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRecentKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => RecentSearchEntry.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(UserModel user) async {
    final current = List<RecentSearchEntry>.from(state.valueOrNull ?? []);
    current.removeWhere((e) => e.id == user.id);
    current.insert(0, RecentSearchEntry.fromUser(user));
    final next = current.take(_maxRecent).toList();
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> remove(String id) async {
    final current = List<RecentSearchEntry>.from(state.valueOrNull ?? []);
    current.removeWhere((e) => e.id == id);
    state = AsyncData(current);
    await _persist(current);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentKey);
  }

  Future<void> _persist(List<RecentSearchEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kRecentKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}

final recentSearchProvider =
    AsyncNotifierProvider<RecentSearchNotifier, List<RecentSearchEntry>>(
        RecentSearchNotifier.new);
