import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/profile_stats_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/doodle_widget.dart';
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
    // Read follow state from local provider — instant, no DB wait
    final followState = ref.watch(followProvider);
    final isFollowing = isOwn ? false : followState.isFollowing;

    // Apply local delta to follower count so it updates instantly
    final displayedFollowers = stats.followerCount + (isOwn ? 0 : followState.followerDelta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Banner ───────────────────────────────────────
        Stack(
          children: [
            Container(
              height: 140,
              color: AppColors.inkWarm,
            ),
            // Floating Doodle in corner of banner
            const Positioned(
              top: 16,
              right: 16,
              child: DoodleWidget(
                type: DoodleType.sparkle,
                size: 32,
                opacity: 0.25,
              ),
            ),
            const Positioned(
              top: 40,
              left: 20,
              child: DoodleWidget(
                type: DoodleType.star,
                size: 20,
                opacity: 0.15,
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar row ─────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar — offset up over banner
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border(
                                top: BorderSide(color: AppColors.inkBase, width: 3.5),
                                bottom: BorderSide(color: AppColors.inkBase, width: 3.5),
                                left: BorderSide(color: AppColors.inkBase, width: 3.5),
                                right: BorderSide(color: AppColors.inkBase, width: 3.5),
                              ),
                            ),
                            child: AvatarWidget(imageUrl: stats.user.avatarUrl, size: 72),
                          ),
                          // Mascot badge stacked on avatar
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.inkBase,
                                shape: BoxShape.circle,
                              ),
                              child: isOwn
                                  ? const GhostMascot(
                                      expression: GhostExpression.waving,
                                      size: 24,
                                      animate: true,
                                      )
                                  : const FrogMascot(
                                      expression: FrogExpression.happy,
                                      size: 24,
                                      animate: true,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Action buttons
                  if (isOwn) ...[
                    _OutlineButton(
                      label: 'Edit profile',
                      onTap: onEditProfile,
                    ),
                    const SizedBox(width: 8),
                    _OutlineButton(
                      label: 'Log out',
                      onTap: onLogout,
                      isDestructive: true,
                    ),
                  ] else
                    // Follow / Following button — reads local state
                    _FollowButton(
                      isFollowing: isFollowing,
                      onTap: onFollowTap,
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // ── Name + username ────────────────────────
              Text(
                stats.user.fullName,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '@${stats.user.username}',
                style: AppTextStyles.username.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (stats.user.bio?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  stats.user.bio!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],

              const SizedBox(height: 20),

              // ── Stats row (Paper Card) ────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.paperSage,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 0.5,
                  ),
                  boxShadow: AppColors.shadowCard,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Stat(
                      label: 'Posts',
                      value: stats.postCount,
                    ),
                    _Stat(
                      label: 'Followers',
                      value: displayedFollowers.clamp(0, 999999999),
                    ),
                    _Stat(
                      label: 'Following',
                      value: stats.followingCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Follow button — animated, reads local state ───────────────
class _FollowButton extends ConsumerStatefulWidget {
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowButton({
    required this.isFollowing,
    this.onTap,
  });

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
        scale: _isTapped ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isFollowing ? AppColors.inkWarm : AppColors.cream100,
            border: Border.all(
              color: widget.isFollowing ? AppColors.borderSubtle : Colors.transparent,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: widget.isFollowing ? null : AppColors.shadowCard,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              widget.isFollowing ? 'Following' : 'Follow',
              key: ValueKey(widget.isFollowing),
              style: TextStyle(
                color: widget.isFollowing ? AppColors.textPrimary : AppColors.textOnCream,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OutlineButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isTapped ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDestructive ? AppColors.dislike.withOpacity(0.08) : AppColors.inkWarm,
            border: Border.all(
              color: widget.isDestructive ? AppColors.dislike.withOpacity(0.4) : AppColors.borderSubtle,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isDestructive ? AppColors.dislike : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
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
    final display = value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';
    return Column(
      children: [
        Text(
          display,
          style: AppTextStyles.statNumber.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.statLabel.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
