import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/search/providers/search_provider.dart'
    show suggestedUsersProvider;
import 'avatar_widget.dart';

/// Horizontal suggested people row for empty feed / cold start.
class SuggestedUsersSection extends ConsumerWidget {
  const SuggestedUsersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(suggestedUsersProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.cream100,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'People to follow',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _SuggestCard(user: users[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestCard extends ConsumerStatefulWidget {
  final UserModel user;
  const _SuggestCard({required this.user});

  @override
  ConsumerState<_SuggestCard> createState() => _SuggestCardState();
}

class _SuggestCardState extends ConsumerState<_SuggestCard> {
  bool _following = false;
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    final repo = ref.read(usersRepositoryProvider);
    final prev = _following;
    setState(() {
      _following = !prev;
      _busy = true;
    });
    HapticFeedback.lightImpact();
    try {
      if (!prev) {
        await repo.followUser(widget.user.id);
      } else {
        await repo.unfollowUser(widget.user.id);
      }
    } catch (_) {
      if (mounted) setState(() => _following = prev);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Container(
      width: 148,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.paperSage,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/${u.id}'),
            child: AvatarWidget(imageUrl: u.avatarUrl, size: 52),
          ),
          const SizedBox(height: 8),
          Text(
            u.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '@${u.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.timestamp.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: _following
                ? OutlinedButton(
                    onPressed: _busy ? null : _toggle,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      'Following',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _busy ? null : _toggle,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 34),
                    ),
                    child: Text(
                      'Follow',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnCream,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
