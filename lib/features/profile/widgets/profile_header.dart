import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../shared/widgets/emoji_text.dart';
import '../../../data/models/profile_stats_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/tactile_connector.dart';
import '../providers/profile_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final ProfileStatsModel stats;
  final bool isOwn;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback? onFollowTap;

  const ProfileHeader({
    super.key,
    required this.stats,
    required this.isOwn,
    required this.onLogout,
    required this.onEditProfile,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followProvider);
    final isFollowing = isOwn ? false : followState.isFollowing;
    final displayedFollowers =
        stats.followerCount + (isOwn ? 0 : followState.followerDelta);

    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.onSurface, width: 1.5),
                ),
                child: AvatarWidget(
                  imageUrl: stats.user.avatarUrl,
                  size: 96,
                ),
              ),
              if (isOwn)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: onEditProfile,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: palette.navActive,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.onSurface,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(Icons.edit_rounded, size: 16),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(stats.user.fullName, style: AppTextStyles.title1),
          const SizedBox(height: 4),
          EmojiText(
            stats.user.bio?.isNotEmpty == true
                ? stats.user.bio!
                : '@${stats.user.username}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (isOwn) ...[
                Expanded(
                  child: GradientButton(
                    label: 'Edit profile',
                    onTap: onEditProfile,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    label: 'Log out',
                    outlined: true,
                    onTap: onLogout,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: GradientButton(
                    label: isFollowing ? 'Following' : 'Follow',
                    outlined: isFollowing,
                    onTap: onFollowTap,
                  ),
                ),
              ],
            ],
          ),
          const TactileConnector(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: palette.surfaceLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.outline, width: 1.5),
            ),
            child: Row(
              children: [
                _Stat(label: 'Doodles', value: stats.postCount),
                _Divider(),
                _Stat(
                  label: 'Followers',
                  value: displayedFollowers.clamp(0, 999999999),
                ),
                _Divider(),
                _Stat(label: 'Following', value: stats.followingCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1.5, height: 36, color: context.palette.outlineVariant);
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final display =
        value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';
    return Expanded(
      child: Column(
        children: [
          Text(display, style: AppTextStyles.statNumber),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}
