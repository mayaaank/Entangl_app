import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationSettingsProvider);
    final notifN = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.onSurfaceDark, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',
                style: AppTextStyles.pageTitle
                    .copyWith(color: AppColors.onSurfaceDark)),
            const SizedBox(height: 4),
            Text('Control your digital footprint',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariantDark,
                    letterSpacing: 1.1)),
            const SizedBox(height: 36),

            // ── Notifications ─────────────────────────────
            SettingsSection(label: 'Notifications', rows: [
              SettingsToggleRow(
                icon: Icons.notifications_active_outlined,
                label: 'Push Notifications',
                subtitle: 'Real-time engagement alerts',
                value: notifs.pushEnabled,
                onChanged: (_) => notifN.toggle('push'),
              ),
              const Divider(height: 1, indent: 56),
              SettingsSubToggle(
                  label: 'New Followers',
                  value: notifs.followers,
                  onChanged: (_) => notifN.toggle('followers')),
              SettingsSubToggle(
                  label: 'Likes',
                  value: notifs.likes,
                  onChanged: (_) => notifN.toggle('likes')),
              SettingsSubToggle(
                  label: 'Dislikes',
                  value: notifs.dislikes,
                  onChanged: (_) => notifN.toggle('dislikes')),
              SettingsSubToggle(
                  label: 'Comments',
                  value: notifs.comments,
                  onChanged: (_) => notifN.toggle('comments')),
              SettingsSubToggle(
                  label: 'Replies',
                  value: notifs.replies,
                  onChanged: (_) => notifN.toggle('replies')),
            ]),
            const SizedBox(height: 28),

            // ── Account ───────────────────────────────────
            SettingsSection(label: 'Account', rows: [
              SettingsChevronRow(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () => context.push(AppRoutes.editProfile)),
              const Divider(height: 1, indent: 56),
              SettingsChevronRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Settings',
                  onTap: () {}),
            ]),
            const SizedBox(height: 28),

            // ── Danger Zone ───────────────────────────────
            SettingsSection(
              label: 'Danger Zone',
              labelColor: AppColors.error,
              rows: [
                SettingsDangerRow(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () async {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
                const Divider(height: 1, indent: 56),
                SettingsDangerRow(
                  icon: Icons.delete_forever_outlined,
                  label: 'Delete Account',
                  muted: true,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}