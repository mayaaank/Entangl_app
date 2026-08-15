import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/widgets/connect_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/settings_section.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final busy = ref.watch(authNotifierProvider) is AsyncLoading;

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
        title: 'Privacy',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who can see you',
              style: AppTextStyles.title1.copyWith(color: palette.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Profiles, scraps, and follows are public in this version of entangl. Anyone in the app can find you by name or username.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            SettingsSection(
              label: 'Sessions',
              rows: [
                SettingsChevronRow(
                  icon: Icons.devices_outlined,
                  label: 'Sign out other devices',
                  subtitle: 'Keep this phone signed in',
                  onTap: () {
                    if (!busy) _signOutOthers(context, ref);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOutOthers(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final palette = ctx.palette;
        return AlertDialog(
          backgroundColor: palette.surfaceLowest,
          title: Text('Sign out other devices?', style: AppTextStyles.title2),
          content: Text(
            'This phone stays signed in. Every other session will need to log in again.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out others'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(authNotifierProvider.notifier).signOutOtherSessions();
    if (!context.mounted) return;
    final next = ref.read(authNotifierProvider);
    if (next is AsyncError) {
      showErrorSnackBar(context, humaniseAuthError(next.error));
    } else {
      showSuccessSnackBar(context, 'Other devices were signed out.');
    }
  }
}
