import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/search_provider.dart';

/// SearchDelegate — pure UI. Reads searchResultsProvider only.
class UserSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  UserSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search users...';

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.inkBase,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.inkBase,
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

  @override
  Widget buildResults(BuildContext context) => _SearchResults(
        query: query,
        ref: ref,
        onTap: (id) {
          close(context, null);
          context.push('/profile/$id');
        },
      );

  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(
        query: query,
        ref: ref,
        onTap: (id) {
          close(context, null);
          context.push('/profile/$id');
        },
      );
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final WidgetRef ref;
  final ValueChanged<String> onTap;
  const _SearchResults({required this.query, required this.ref, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    if (query.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FrogMascot(expression: FrogExpression.waving, size: 96),
              const SizedBox(height: 20),
              Text(
                'Search for connections',
                style: AppTextStyles.displayMd.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your friends by name or @username',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
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
                  onTap: () => onTap(u.id),
                );
              },
            ),
    );
  }
}
