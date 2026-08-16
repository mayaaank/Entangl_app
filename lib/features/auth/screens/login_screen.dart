import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/doodle_widget.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_landing.dart';
import '../widgets/auth_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool _obscure   = true;
  bool _routing   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _routeIfSignedIn();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _routeIfSignedIn() async {
    if (_routing || SupabaseService.currentSession == null) return;
    _routing = true;
    try {
      final dest = await landingRouteAfterAuth();
      if (mounted) context.go(dest);
    } finally {
      _routing = false;
    }
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState is AsyncError) {
      _showError(humaniseAuthError(authState.error));
      return;
    }
    if (SupabaseService.currentSession != null) {
      await _routeIfSignedIn();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).signIn(
          email:    _email.text.trim(),
          password: _password.text,
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState is AsyncError) {
      _showError(humaniseAuthError(authState.error));
    } else {
      final dest = await landingRouteAfterAuth();
      if (mounted) context.go(dest);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white))),
        ]),
        backgroundColor: AppColors.dislike,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authNotifierProvider) is AsyncLoading;
    final palette = context.palette;

    ref.listen(authStateProvider, (prev, next) {
      final event = next.value?.event;
      if (event == AuthChangeEvent.signedIn) {
        _routeIfSignedIn();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background ambient subtle halo
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cream100.withOpacity(0.02),
              ),
            ),
          ),
          // Scattered doodles in background
          Positioned(
            top: 100,
            left: 50,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.star, size: 24, opacity: 0.3),
            )
                .fade(duration: 800.ms)
                .scale(delay: 200.ms),
          ),
          Positioned(
            bottom: 120,
            right: 40,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.star, size: 28, opacity: 0.3),
            )
                .fade(duration: 800.ms)
                .scale(delay: 300.ms),
          ),
          Positioned(
            bottom: 300,
            left: 30,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.star, size: 20, opacity: 0.25),
            )
                .fade(duration: 800.ms),
          ),
          Positioned(
            top: 120,
            right: 60,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.lightning, size: 32, opacity: 0.35),
            )
                .fade(duration: 800.ms)
                .slideY(begin: -10, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
          ),
          // Form card container
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 48,
                      bottom: 32,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surfaceLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: palette.onSurface,
                        width: 1.5,
                      ),
                      boxShadow: AppColors.shadowCard,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Welcome back',
                              style: AppTextStyles.displayLg.copyWith(
                                color: palette.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: palette.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthField(
                            label: 'Email',
                            controller: _email,
                            hint: 'you@example.com',
                            type: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthField(
                            label: 'Password',
                            controller: _password,
                            hint: '••••••••',
                            obscure: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            label: 'Sign In',
                            onTap: isLoading ? null : _submit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: palette.outlineVariant),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: palette.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: palette.outlineVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GradientButton(
                            label: 'Continue with Google',
                            outlined: true,
                            onTap: isLoading ? null : _google,
                            leadingIcon: Icon(
                              Icons.g_mobiledata_rounded,
                              color: palette.onSurface,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () =>
                                  context.push(AppRoutes.forgotPassword),
                              child: Text(
                                'Forgot password?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: palette.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: palette.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.register),
                                child: Text(
                                  'Sign up',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: palette.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.96, 0.96),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 350.ms),

                  // Peeking ghost mascot overlapping top edge of card
                  Positioned(
                    top: -42,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: GhostMascot(
                        expression: GhostExpression.peeking,
                        size: 80,
                        animate: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
