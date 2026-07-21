import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Skeleton post cards shown on first feed load (no full-screen spinner).
class FeedSkeletonList extends StatelessWidget {
  final int count;
  const FeedSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 4, bottom: 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => const _SkeletonCard(),
          childCount: count,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.paperSage,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderCard, width: 2),
        boxShadow: AppColors.shadowDoodle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bone(circle: true, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bone(width: 120, height: 12),
                    const SizedBox(height: 8),
                    _bone(width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _bone(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          _bone(width: 220, height: 12),
          const SizedBox(height: 8),
          _bone(width: 160, height: 12),
          const SizedBox(height: 16),
          _bone(width: double.infinity, height: 140, radius: 16),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _bone(height: 48, radius: 14)),
              const SizedBox(width: 8),
              Expanded(child: _bone(height: 48, radius: 14)),
              const SizedBox(width: 8),
              Expanded(child: _bone(height: 48, radius: 14)),
              const SizedBox(width: 8),
              Expanded(child: _bone(height: 48, radius: 14)),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
            duration: 1400.ms, color: AppColors.paperWarm.withOpacity(0.7));
  }

  Widget _bone({
    double? width,
    double? height,
    double size = 0,
    bool circle = false,
    double radius = 8,
  }) {
    return Container(
      width: circle ? size : width,
      height: circle ? size : height,
      decoration: BoxDecoration(
        color: AppColors.inkWarm,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Compact profile header skeleton (centered, Stitch-style).
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 24),
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.inkWarm,
            border: Border.all(color: AppColors.borderCard, width: 2),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.inkWarm,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.inkWarm,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.inkWarm,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDefault, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.inkWarm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.inkWarm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
            duration: 1400.ms, color: AppColors.paperWarm.withOpacity(0.7));
  }
}
