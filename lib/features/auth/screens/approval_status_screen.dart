import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';


/// Shown to users whose profile status is 'pending' or 'rejected'.
/// They can only log out from here.
class ApprovalStatusScreen extends ConsumerWidget {
  const ApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: _ApprovalStatusBody(),
      ),
    );
  }
}

class _ApprovalStatusBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ApprovalStatusBody> createState() =>
      _ApprovalStatusBodyState();
}

class _ApprovalStatusBodyState extends ConsumerState<_ApprovalStatusBody> {
  bool _loading = true;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final profile =
          await ref.read(usersRepositoryProvider).getOwnProfile();
      if (profile == null) {
        if (mounted) context.go(AppRoutes.login);
        return;
      }
      // If user is approved, send them to home
      if (profile.isApproved) {
        if (mounted) context.go(AppRoutes.home);
        return;
      }
      if (mounted) {
        setState(() {
          _status  = profile.status;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2));
    }

    final isPending  = _status == 'pending';
    final isRejected = _status == 'rejected';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientText('Entangl',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: 40),

            // Icon
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPending
                    ? const Color(0xFFF59E0B).withOpacity(0.12)
                    : AppColors.error.withOpacity(0.12),
              ),
              child: Icon(
                isPending
                    ? Icons.hourglass_top_rounded
                    : Icons.cancel_outlined,
                color: isPending
                    ? const Color(0xFFF59E0B)
                    : AppColors.error,
                size: 44,
              ),
            ),
            const SizedBox(height: 28),

            Text(
              isPending ? 'Awaiting Approval' : 'Access Denied',
              style: AppTextStyles.sectionTitle
                  .copyWith(color: AppColors.onSurfaceDark),
            ),
            const SizedBox(height: 12),

            if (isPending) ...[
              Text(
                'Your account has been created successfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariantDark),
              ),
              const SizedBox(height: 8),
              Text(
                'The platform owner needs to approve your account '
                'before you can start using Entangl. Please check back later.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.outlineVariant),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.schedule_rounded,
                      color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your request is being reviewed.',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ],

            if (isRejected) ...[
              Text(
                'Your registration request has been rejected.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariantDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Unfortunately, the platform owner has not approved your '
                'account at this time. If you believe this is a mistake, '
                'please contact the administrator.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.outlineVariant),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.error.withOpacity(0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.block_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your registration was not approved.',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 40),

            // Refresh button
            GestureDetector(
              onTap: () {
                setState(() => _loading = true);
                _checkStatus();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: AppColors.onSurfaceDark, size: 18),
                    const SizedBox(width: 8),
                    Text('Check Again',
                        style: AppTextStyles.buttonMedium
                            .copyWith(color: AppColors.onSurfaceDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout button
            GestureDetector(
              onTap: () async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: AppColors.outlineVariant, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: AppColors.onSurfaceVariantDark,
                        size: 18),
                    const SizedBox(width: 8),
                    Text('Log Out',
                        style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.onSurfaceVariantDark)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
