import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/profile_stats_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../providers/profile_provider.dart';

/// Centered profile header matching Stitch user_profile.png:
/// large outlined avatar, name/handle, bio, stats strip, dual CTAs.
class ProfileHeader extends ConsumerWidget {
  final ProfileStatsModel stats;
  final bool isOwn;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback? onFollowTap;
  final VoidCallback? onAdminTap;

  const ProfileHeader({
    super.key,
    required this.stats,
    required this.isOwn,
    required this.onLogout,
    required this.onEditProfile,
    this.onFollowTap,
    this.onAdminTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followProvider);
    final isFollowing = isOwn ? false : followState.isFollowing;
    final displayedFollowers =
        stats.followerCount + (isOwn ? 0 : followState.followerDelta);
    final avatarHeroTag = 'avatar_${stats.user.id}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          // Brand chip
          Text(
            'entangl',
            style: AppTextStyles.brandWordmark.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Avatar with thick ink ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderCard, width: 2.5),
              boxShadow: AppColors.shadowDoodle,
            ),
            child: AvatarWidget(
              imageUrl: stats.user.avatarUrl,
              size: 104,
              heroTag: avatarHeroTag,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            stats.user.fullName,
            style: AppTextStyles.title1.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '@${stats.user.username}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (stats.user.bio?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              stats.user.bio!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Stats strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.inkMid,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderCard, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(label: 'Posts', value: stats.postCount),
                ),
                Container(width: 1.5, height: 36, color: AppColors.borderDefault),
                Expanded(
                  child: _Stat(
                    label: 'Followers',
                    value: displayedFollowers.clamp(0, 999999999),
                  ),
                ),
                Container(width: 1.5, height: 36, color: AppColors.borderDefault),
                Expanded(
                  child: _Stat(label: 'Following', value: stats.followingCount),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action row
          if (isOwn)
            Row(
              children: [
                if (onAdminTap != null) ...[
                  Expanded(
                    child: _DoodleButton(
                      label: 'Admin',
                      fill: AppColors.pastelLavender,
                      onTap: onAdminTap!,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _DoodleButton(
                    label: 'Edit profile',
                    fill: AppColors.cream60,
                    onTap: onEditProfile,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DoodleButton(
                    label: 'Log out',
                    fill: AppColors.pastelPink.withOpacity(0.55),
                    onTap: onLogout,
                    isDestructive: true,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _FollowButton(
                    isFollowing: isFollowing,
                    onTap: onFollowTap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DoodleButton(
                    label: 'Message',
                    fill: AppColors.pastelBlue,
                    onTap: () {
                      // Messaging not yet wired — soft no-op toast.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Messaging coming soon',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textOnDark),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    trailing: const Icon(
                      Icons.mail_outline_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FollowButton extends ConsumerStatefulWidget {
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowButton({required this.isFollowing, this.onTap});

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isFollowing ? AppColors.cream60 : AppColors.cream100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderCard, width: 2),
            boxShadow: AppColors.shadowDoodle,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isFollowing ? 'Following' : 'Follow',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnCream,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.isFollowing) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_rounded,
                    size: 18, color: AppColors.textOnCream),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DoodleButton extends StatefulWidget {
  final String label;
  final Color fill;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _DoodleButton({
    required this.label,
    required this.fill,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  State<_DoodleButton> createState() => _DoodleButtonState();
}

class _DoodleButtonState extends State<_DoodleButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderCard, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: widget.isDestructive
                      ? AppColors.dislike
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 6),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final display =
        value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}K' : '$value';
    return Column(
      children: [
        Text(
          display,
          style: AppTextStyles.statNumber,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.statLabel.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
