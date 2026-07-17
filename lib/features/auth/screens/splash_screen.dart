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
    _boot();
  }

  /// Adaptive splash: short pause when a session already exists so launch
  /// does not feel artificially slow; slightly longer brand beat for cold start.
  Future<void> _boot() async {
    final sw = Stopwatch()..start();
    final hasSession =
        Supabase.instance.client.auth.currentSession != null;
    final minMs = hasSession ? 450 : 1400;

    final route = await _resolveRoute(hasSession);

    final remaining = minMs - sw.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
    if (!mounted) return;
    context.go(route);
  }

  Future<String> _resolveRoute(bool hasSession) async {
    if (!hasSession) return AppRoutes.login;

    try {
      final profile = await UsersRepository().getOwnProfile();
      if (profile == null) return AppRoutes.login;

      if (profile.status.startsWith('email_change_approved:')) {
        final newEmail =
            profile.status.replaceFirst('email_change_approved:', '');
        try {
          await AuthRepository().updateEmail(newEmail);
          await UsersRepository().processApprovedEmailChange(newEmail);
        } catch (_) {}
      }

      if (profile.isApproved) return AppRoutes.home;
      return AppRoutes.approvalStatus;
    } catch (_) {
      return AppRoutes.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBase,
      body: Stack(
        children: [
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
                Text(
                  'entangl',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 16,
                    letterSpacing: 16 * 0.3,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 500.ms)
                    .moveY(
                        begin: 10,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
