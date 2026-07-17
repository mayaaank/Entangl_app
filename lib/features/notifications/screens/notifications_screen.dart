import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/entangl_app_bar.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/notifications_provider.dart';
import '../utils/notification_navigation.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const _maxStaggerItems = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.inkBase,
      appBar: EntanglAppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
        ),
        title: 'Notifications',
        trailing: TextButton(
          onPressed: notifier.markAllRead,
          child: const Text(
            'Mark all read',
            style: TextStyle(
              color: AppColors.cream100,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
      body: notifsAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            height: 72,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.inkWarm,
              borderRadius: BorderRadius.circular(16),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1400.ms, color: AppColors.inkMid),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FrogMascot(
                  expression: FrogExpression.sad,
                  size: 88,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load notifications',
                  style: AppTextStyles.displayMd.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 140,
                  child: GradientButton(
                    label: 'Retry',
                    onTap: () => ref.invalidate(notificationsProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (notifs) => notifs.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FrogMascot(
                        expression: FrogExpression.waving,
                        size: 96,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "You're all caught up",
                        style: AppTextStyles.displayMd.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No new activity to show right now.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: AppColors.cream100,
                backgroundColor: AppColors.inkMid,
                onRefresh: notifier.refresh,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: notifs.length,
                  itemBuilder: (_, i) {
                    Widget tile = NotificationTile(
                      notification: notifs[i],
                      onTap: () =>
                          openNotificationTarget(context, ref, notifs[i]),
                      onDismiss: () => notifier.remove(notifs[i].id),
                    );
                    // Cap entrance motion so long lists do not feel laggy.
                    if (i < _maxStaggerItems) {
                      tile = tile
                          .animate()
                          .fadeIn(
                              delay: (40 * i).ms, duration: 220.ms)
                          .slideY(
                              begin: 0.04,
                              end: 0,
                              duration: 200.ms,
                              curve: Curves.easeOutQuad);
                    }
                    return tile;
                  },
                ),
              ),
      ),
    );
  }
}
