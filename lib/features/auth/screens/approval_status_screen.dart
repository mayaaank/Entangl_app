import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/auth_provider.dart';

/// Shown when profile status is pending or rejected.
class ApprovalStatusScreen extends ConsumerStatefulWidget {
  const ApprovalStatusScreen({super.key});

  @override
  ConsumerState<ApprovalStatusScreen> createState() =>
      _ApprovalStatusScreenState();
}

class _ApprovalStatusScreenState
    extends ConsumerState<ApprovalStatusScreen> {
  bool _loading = true;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final profile =
          await ref.read(usersRepositoryProvider).getOwnProfile();
      if (profile == null) {
        if (mounted) context.go(AppRoutes.login);
        return;
      }
      if (profile.isApproved) {
        if (mounted) context.go(AppRoutes.home);
        return;
      }
      if (mounted) {
        setState(() {
          _status = profile.status;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pending = _status == 'pending';

    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: palette.primary,
                  strokeWidth: 2,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      pending
                          ? Icons.hourglass_top_rounded
                          : Icons.cancel_outlined,
                      size: 56,
                      color: pending ? palette.primary : palette.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      pending ? 'Awaiting approval' : 'Access denied',
                      style: AppTextStyles.title1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pending
                          ? 'Your account is in review. A platform owner will approve it before you can post and explore. You can close the app and check back later.'
                          : 'This registration was not approved. If that looks wrong, contact the person who invited you.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: palette.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Check again',
                      onTap: () {
                        setState(() => _loading = true);
                        _check();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      child: Text(
                        'Log out',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: palette.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
