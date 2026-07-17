import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../profile/providers/profile_provider.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

/// Search results for a query. Debouncing is applied in the Search UI
/// before this provider is watched (300ms).
final searchResultsProvider =
    FutureProvider.family<List<UserModel>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value([]);
  return ref.read(usersRepositoryProvider).searchUsers(query);
});

/// Suggested users for discovery / empty states.
final suggestedUsersProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.read(usersRepositoryProvider).getSuggestedUsers();
});
