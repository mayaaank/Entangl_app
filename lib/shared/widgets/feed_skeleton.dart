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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.paperSage,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bone(circle: true, size: 42),
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
          _bone(width: double.infinity, height: 160, radius: 16),
          const SizedBox(height: 14),
          Row(
            children: [
              _bone(width: 52, height: 28, radius: 100),
              const SizedBox(width: 8),
              _bone(width: 52, height: 28, radius: 100),
              const SizedBox(width: 8),
              _bone(width: 52, height: 28, radius: 100),
            ],
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1400.ms, color: AppColors.inkMid.withOpacity(0.35));
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

/// Compact profile header skeleton.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 140, color: AppColors.inkWarm)
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1400.ms, color: AppColors.inkMid.withOpacity(0.35)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inkWarm,
                    border: Border.all(color: AppColors.inkBase, width: 3),
                  ),
                ),
              ),
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
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.inkWarm,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1400.ms, color: AppColors.inkMid.withOpacity(0.35));
  }
}
