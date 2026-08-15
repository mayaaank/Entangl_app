import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../data/models/user_model.dart';
import '../providers/recent_search_provider.dart';
import '../providers/search_provider.dart';

/// SearchDelegate — pure UI. Reads searchResultsProvider only.
class UserSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  UserSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search users...';

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          filled: false,
          hintStyle: TextStyle(color: AppColors.textTertiary),
        ),
      );

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
      );

  Future<void> _openUser(BuildContext context, UserModel user) async {
    await ref.read(recentSearchProvider.notifier).add(user);
    if (!context.mounted) return;
    close(context, null);
    context.push('/profile/${user.id}');
  }

  Future<void> _openRecent(
    BuildContext context,
    RecentSearchEntry entry,
  ) async {
    close(context, null);
    context.push('/profile/${entry.id}');
  }

  @override
  Widget buildResults(BuildContext context) => _SearchResults(
        query: query,
        ref: ref,
        onTap: (user) => _openUser(context, user),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _RecentSearches(
        onOpen: (entry) => _openRecent(context, entry),
      );
    }
    return _SearchResults(
      query: query,
      ref: ref,
      onTap: (user) => _openUser(context, user),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  final ValueChanged<RecentSearchEntry> onOpen;

  const _RecentSearches({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSearchProvider);
    return recentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (recent) {
        if (recent.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FrogMascot(expression: FrogExpression.waving, size: 96),
                  const SizedBox(height: 20),
                  Text(
                    'Find people to tangle with',
                    style: AppTextStyles.displayMd
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your friends by name or @username',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('RECENT', style: AppTextStyles.sectionLabel()),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        ref.read(recentSearchProvider.notifier).clear(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            ...recent.map(
              (e) => ListTile(
                leading: AvatarWidget(imageUrl: e.avatarUrl, size: 44),
                title: Text(e.fullName, style: AppTextStyles.labelLarge),
                subtitle: Text(
                  '@${e.username}',
                  style: AppTextStyles.timestamp.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () =>
                      ref.read(recentSearchProvider.notifier).remove(e.id),
                ),
                onTap: () => onOpen(e),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final WidgetRef ref;
  final ValueChanged<UserModel> onTap;
  const _SearchResults({required this.query, required this.ref, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final async = ref.watch(searchResultsProvider(query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cream100)),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white))),
      data: (users) => users.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FrogMascot(expression: FrogExpression.confused, size: 96),
                    const SizedBox(height: 20),
                    Text(
                      'No results found',
                      style: AppTextStyles.displayMd.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We couldn\'t find any users matching "$query"',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                return ListTile(
                  tileColor: Colors.transparent,
                  leading: AvatarWidget(imageUrl: u.avatarUrl, size: 44),
                  title: Text(
                    u.fullName,
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    '@${u.username}',
                    style: AppTextStyles.timestamp.copyWith(color: AppColors.textTertiary),
                  ),
                  onTap: () => onTap(u),
                );
              },
            ),
    );
  }
}
