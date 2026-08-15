import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../shared/widgets/gradient_button.dart';
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
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = humaniseAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        child: _sent ? _sentBody(palette) : _formBody(palette),
      ),
    );
  }

  Widget _formBody(EntanglColors palette) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.login),
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: palette.onSurfaceVariant,
              ),
              label: Text(
                'Back to login',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Forgot password?', style: AppTextStyles.pageTitle),
            const SizedBox(height: 8),
            Text(
              'Enter the email on your account. We’ll send a reset link.',
              style: AppTextStyles.bodyMedium.copyWith(
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
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: AppTextStyles.bodySmall.copyWith(color: palette.error),
              ),
            ],
            const SizedBox(height: 28),
            GradientButton(
              label: 'Send reset link',
              isLoading: _loading,
              onTap: _loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sentBody(EntanglColors palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 56, color: palette.primary),
          const SizedBox(height: 24),
          Text('Check your email', style: AppTextStyles.title1),
          const SizedBox(height: 10),
          Text(
            'We sent a reset link to ${_email.text.trim()}. Open it to choose a new password.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Back to login',
            onTap: () => context.go(AppRoutes.login),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() {
              _sent = false;
              _email.clear();
            }),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
