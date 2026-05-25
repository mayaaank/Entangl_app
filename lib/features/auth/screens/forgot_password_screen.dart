import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _email   = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sent      = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withOpacity(0.15),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF10B981), size: 44),
                  ),
                  const SizedBox(height: 28),
                  Text('Check Your Email',
                      style: AppTextStyles.sectionTitle
                          .copyWith(color: AppColors.onSurfaceDark)),
                  const SizedBox(height: 12),
                  Text(
                    'We\'ve sent a password reset link to ${_email.text.trim()}. '
                    'Click the link in the email to reset your password.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariantDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Didn\'t receive the email? Check your spam folder or try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.outlineVariant),
                  ),
                  const SizedBox(height: 36),
                  GradientButton(
                    label: 'Back to Login',
                    onTap: () => context.go(AppRoutes.login),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() {
                      _sent = false;
                      _email.clear();
                    }),
                    child: Text('Try Again',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(children: [
        Positioned(
          top: -80, left: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gradientStart.withOpacity(0.05),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Row(children: [
                      const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.onSurfaceVariantDark,
                          size: 16),
                      const SizedBox(width: 8),
                      Text('Back to Login',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariantDark)),
                    ]),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.mail_outline_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 24),

                  GradientText('Forgot\nPassword?',
                      style: AppTextStyles.heroTitle),
                  const SizedBox(height: 8),
                  Text(
                    'No worries! Enter your email and we\'ll send you a reset link.',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariantDark),
                  ),
                  const SizedBox(height: 40),

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
                  const SizedBox(height: 36),

                  GradientButton(
                    label: 'Send Reset Link',
                    onTap: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
