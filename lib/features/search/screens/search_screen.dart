import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/recent_search_provider.dart';
import '../providers/search_provider.dart';

/// Full-screen ink-styled search (replaces Material SearchDelegate chrome).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  String _debounced = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _timer?.cancel();
    final t = q.trim();
    if (t.isEmpty) {
      setState(() => _debounced = '');
      return;
    }
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _debounced = t);
    });
  }

  Future<void> _openUser(UserModel u) async {
    await ref.read(recentSearchProvider.notifier).add(u);
    if (!mounted) return;
    context.push('/profile/${u.id}');
  }

  Future<void> _openRecent(RecentSearchEntry e) async {
    if (!mounted) return;
    context.push('/profile/${e.id}');
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _ctrl.text.trim().isNotEmpty;
    final waitingDebounce =
        hasQuery && (_debounced.isEmpty || _debounced != _ctrl.text.trim());

    return Scaffold(
      backgroundColor: AppColors.inkBase,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary, size: 20),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.paperAsh,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AppColors.textTertiary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              onChanged: (v) {
                                setState(() {});
                                _onChanged(v);
                              },
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              cursorColor: AppColors.cream100,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                hintText: 'Search users...',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_ctrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _ctrl.clear();
                                _timer?.cancel();
                                setState(() => _debounced = '');
                              },
                              child: const Icon(Icons.close_rounded,
                                  color: AppColors.textSecondary, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !hasQuery
                  ? _IdleBody(
                      onOpenRecent: _openRecent,
                      onOpenSuggested: _openUser,
                    )
                  : waitingDebounce
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cream100,
                            ),
                          ),
                        )
                      : _ResultsBody(
                          query: _debounced,
                          onTap: _openUser,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleBody extends ConsumerWidget {
  final ValueChanged<RecentSearchEntry> onOpenRecent;
  final ValueChanged<UserModel> onOpenSuggested;

  const _IdleBody({
    required this.onOpenRecent,
    required this.onOpenSuggested,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSearchProvider);
    final suggestedAsync = ref.watch(suggestedUsersProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        recentAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (recent) {
            if (recent.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'RECENT',
                      style: AppTextStyles.sectionLabel(),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          ref.read(recentSearchProvider.notifier).clear(),
                      child: Text(
                        'Clear',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.cream100,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...recent.map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: AvatarWidget(imageUrl: e.avatarUrl, size: 44),
                    title: Text(
                      e.fullName,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      '@${e.username}',
                      style: AppTextStyles.timestamp
                          .copyWith(color: AppColors.textTertiary),
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textTertiary),
                      onPressed: () => ref
                          .read(recentSearchProvider.notifier)
                          .remove(e.id),
                    ),
                    onTap: () => onOpenRecent(e),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
        Text('SUGGESTED', style: AppTextStyles.sectionLabel()),
        const SizedBox(height: 8),
        suggestedAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.cream100,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => Text(
            'Could not load suggestions.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiary),
          ),
          data: (users) {
            if (users.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const FrogMascot(
                        expression: FrogExpression.waving, size: 80),
                    const SizedBox(height: 12),
                    Text(
                      'Search for connections',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: users
                  .map(
                    (u) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: AvatarWidget(imageUrl: u.avatarUrl, size: 44),
                      title: Text(
                        u.fullName,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        '@${u.username}',
                        style: AppTextStyles.timestamp
                            .copyWith(color: AppColors.textTertiary),
                      ),
                      onTap: () => onOpenSuggested(u),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ResultsBody extends ConsumerWidget {
  final String query;
  final ValueChanged<UserModel> onTap;

  const _ResultsBody({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchResultsProvider(query));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.cream100),
      ),
      error: (_, __) => Center(
        child: Text(
          'Search failed. Try again.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FrogMascot(
                      expression: FrogExpression.confused, size: 96),
                  const SizedBox(height: 20),
                  Text(
                    'No results found',
                    style: AppTextStyles.displayMd
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We couldn\'t find anyone matching "$query"',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i];
            return ListTile(
              leading: AvatarWidget(imageUrl: u.avatarUrl, size: 44),
              title: Text(
                u.fullName,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                '@${u.username}',
                style: AppTextStyles.timestamp
                    .copyWith(color: AppColors.textTertiary),
              ),
              onTap: () => onTap(u),
            );
          },
        );
      },
    );
  }
}
