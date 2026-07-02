import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../data/repositories/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final hasSession =
        Supabase.instance.client.auth.currentSession != null;

    if (!hasSession) {
      context.go(AppRoutes.login);
      return;
    }

    // Check profile status for pending/rejected users
    try {
      final profile = await UsersRepository().getOwnProfile();
      if (!mounted) return;

      if (profile == null) {
        context.go(AppRoutes.login);
        return;
      }

      // Handle approved email change — auto-process it
      if (profile.status.startsWith('email_change_approved:')) {
        final newEmail =
            profile.status.replaceFirst('email_change_approved:', '');
        try {
          await AuthRepository().updateEmail(newEmail);
          await UsersRepository().processApprovedEmailChange(newEmail);
        } catch (_) {
          // Continue even if processing fails
        }
      }

      if (profile.isApproved) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.approvalStatus);
      }
    } catch (_) {
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBase, // Warm ink background
      body: Stack(
        children: [
          // Subtle ambient glow in the center
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGradient.colors[0].withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGradient.colors[1].withOpacity(0.06),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mascots floating side-by-side (representing the connection / high-five)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Animate(
                      child: const GhostMascot(
                        expression: GhostExpression.floating,
                        size: 88,
                      ),
                    )
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),
                    const SizedBox(width: 16),
                    Animate(
                      child: const FrogMascot(
                        expression: FrogExpression.happy,
                        size: 88,
                      ),
                    )
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),
                  ],
                ),
                const SizedBox(height: 24),
                // Subtitle "entangl" lowercase, whispered spacing
                Text(
                  'entangl',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 16,
                    letterSpacing: 16 * 0.3, // 0.3em
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .moveY(begin: 10, end: 0, duration: 400.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
