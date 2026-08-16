import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/snackbar.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/connect_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/change_email_sheet.dart';
import '../../settings/widgets/change_password_sheet.dart';
import '../../settings/widgets/delete_account_dialog.dart';
import '../../settings/widgets/settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationSettingsProvider);
    final notifN = ref.read(notificationSettingsProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final palette = context.palette;
    final pushOn = notifs.pushEnabled;
    final isAdmin =
        AppConstants.isAdminEmail(SupabaseService.currentEmail);

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: ConnectAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: palette.onSurface,
            size: 20,
          ),
        ),
        title: 'Settings',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control your digital footprint',
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            SettingsSection(
              label: 'Appearance',
              rows: [
                _ThemeModeRow(
                  label: 'Light',
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.light),
                ),
                Divider(height: 1, indent: 56, color: palette.outlineVariant),
                _ThemeModeRow(
                  label: 'Dark',
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.dark),
                ),
                Divider(height: 1, indent: 56, color: palette.outlineVariant),
                _ThemeModeRow(
                  label: 'System',
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SettingsSection(
              label: 'Notifications',
              rows: [
                SettingsToggleRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Push Notifications',
                  subtitle: 'Real-time engagement alerts',
                  value: notifs.pushEnabled,
                  onChanged: (_) => notifN.toggle('push'),
                ),
                Divider(height: 1, indent: 56, color: palette.outlineVariant),
                SettingsSubToggle(
                  label: 'New Followers',
                  value: notifs.followers && pushOn,
                  onChanged: pushOn ? (_) => notifN.toggle('followers') : null,
                ),
                SettingsSubToggle(
                  label: 'Likes',
                  value: notifs.likes && pushOn,
                  onChanged: pushOn ? (_) => notifN.toggle('likes') : null,
                ),
                SettingsSubToggle(
                  label: 'Dislikes',
                  value: notifs.dislikes && pushOn,
                  onChanged: pushOn ? (_) => notifN.toggle('dislikes') : null,
                ),
                SettingsSubToggle(
                  label: 'Comments',
                  value: notifs.comments && pushOn,
                  onChanged: pushOn ? (_) => notifN.toggle('comments') : null,
                ),
                SettingsSubToggle(
                  label: 'Replies',
                  value: notifs.replies && pushOn,
                  onChanged: pushOn ? (_) => notifN.toggle('replies') : null,
                ),
              ],
            ),
            const SizedBox(height: 28),
            SettingsSection(
              label: 'Account',
              rows: [
                SettingsChevronRow(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () async {
                    final ok = await showChangePasswordSheet(context);
                    if (ok && context.mounted) {
                      showSuccessSnackBar(context, 'Password updated.');
                    }
                  },
                ),
                Divider(height: 1, indent: 56, color: palette.outlineVariant),
                SettingsChevronRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Settings',
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                Divider(height: 1, indent: 56, color: palette.outlineVariant),
                SettingsChevronRow(
                  icon: Icons.alternate_email,
                  label: 'Change Email',
                  subtitle: 'Needs admin approval',
                  onTap: () async {
                    final ok = await showChangeEmailSheet(context);
                    if (ok && context.mounted) {
                      showSuccessSnackBar(
                        context,
                        'Email change submitted for review.',
                      );
                    }
                  },
                ),
                if (isAdmin) ...[
                  Divider(height: 1, indent: 56, color: palette.outlineVariant),
                  SettingsChevronRow(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Requests',
                    subtitle: 'Registrations and email changes',
                    onTap: () => context.push(AppRoutes.adminRequests),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),
            SettingsSection(
              label: 'Danger Zone',
              labelColor: palette.error,
              rows: [
                SettingsDangerRow(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
                Divider(height: 1, indent: 56, color: palette.outlineVariant),
                SettingsDangerRow(
                  icon: Icons.delete_forever_outlined,
                  label: 'Delete Account',
                  muted: true,
                  onTap: () async {
                    final deleted = await confirmDeleteAccount(context);
                    if (deleted && context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
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

class _ThemeModeRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? palette.primary : palette.outline,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: palette.onSurface),
      ),
      onTap: onTap,
    );
  }
}
