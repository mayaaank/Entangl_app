import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../../../shared/widgets/doodle_widget.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  FrogExpression _frogExpression = FrogExpression.sitting;

  @override
  void initState() {
    super.initState();
    _username.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _username.removeListener(_onUsernameChanged);
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _username.text.trim();
    if (text.isEmpty) {
      setState(() => _frogExpression = FrogExpression.sitting);
    } else if (text.length < 3) {
      setState(() => _frogExpression = FrogExpression.confused);
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(text)) {
      setState(() => _frogExpression = FrogExpression.sad);
    } else {
      setState(() => _frogExpression = FrogExpression.happy);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _frogExpression = FrogExpression.sad);
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() => _frogExpression = FrogExpression.jumping);

    await ref.read(authNotifierProvider.notifier).signUp(
          email: _email.text.trim(),
          password: _password.text,
          fullName: _name.text.trim(),
          username: _username.text.trim().toLowerCase(),
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState is AsyncError) {
      setState(() => _frogExpression = FrogExpression.confused);
      _showError(humaniseAuthError(authState.error!));
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppColors.dislike,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider) is AsyncLoading;

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
          Positioned(
            top: 80,
            right: 40,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.star, size: 28, opacity: 0.3),
            )
                .fade(duration: 800.ms)
                .scale(delay: 200.ms),
          ),
          Positioned(
            bottom: 80,
            left: 40,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.sparkle, size: 24, opacity: 0.25),
            )
                .fade(duration: 800.ms),
          ),
          Positioned(
            top: 180,
            left: 30,
            child: Animate(
              child: const DoodleWidget(type: DoodleType.lightning, size: 22, opacity: 0.3),
            )
                .fade(duration: 800.ms),
          ),
          // Scrollable layout containing the card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 40),
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
                      color: AppColors.surfaceLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.onSurface,
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
                              'Create Account',
                              style: AppTextStyles.displayLg,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join Entangl today',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthField(
                            label: 'Full Name',
                            controller: _name,
                            hint: 'Your name',
                            validator: (v) =>
                                (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 20),
                          AuthField(
                            label: 'Username',
                            controller: _username,
                            hint: 'e.g. janedoe',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Username is required';
                              }
                              if (v.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                                return 'Only letters, numbers and underscores';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthField(
                            label: 'Email',
                            controller: _email,
                            hint: 'you@example.com',
                            type: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthField(
                            label: 'Password',
                            controller: _password,
                            hint: 'Min 6 characters',
                            obscure: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'At least 6 characters required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            label: 'Create Account',
                            onTap: isLoading ? null : _submit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.login),
                                child: Text(
                                  'Sign in',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
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

                  // Peeking Frog mascot overlapping top edge of card
                  Positioned(
                    top: -42,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FrogMascot(
                        key: ValueKey(_frogExpression),
                        expression: _frogExpression,
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
