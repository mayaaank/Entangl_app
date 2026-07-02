import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/entangl_app_bar.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.inkBase,
      appBar: EntanglAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.cream100),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.textPrimary)),
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
                        "No new activity to show right now.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: notifs.length,
                itemBuilder: (_, i) => NotificationTile(
                  notification: notifs[i],
                  onTap: () {
                    notifier.markRead(notifs[i].id);
                    if (notifs[i].actorId.isNotEmpty) {
                      context.push('/profile/${notifs[i].actorId}');
                    }
                  },
                  onDismiss: () => notifier.remove(notifs[i].id),
                )
                    .animate()
                    .fadeIn(delay: (60 * i).ms, duration: 350.ms)
                    .slideY(begin: 0.08, end: 0, duration: 250.ms, curve: Curves.easeOutQuad),
              ),
      ),
    );
  }
}
