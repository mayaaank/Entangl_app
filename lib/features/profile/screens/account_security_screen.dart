import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../shared/widgets/gradient_button.dart';

/// Password + email change only (split from Edit Profile).
class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _newEmail = TextEditingController();

  bool _loading = true;
  bool _passwordLoading = false;
  bool _emailLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _passwordMessage;
  bool _passwordSuccess = false;
  String? _emailMessage;
  bool _emailSuccess = false;
  String _profileStatus = 'approved';
  String _currentEmail = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await UsersRepository().getOwnProfile();
      _currentEmail = AuthRepository().currentEmail ?? '';
      _profileStatus = profile?.status ?? 'approved';
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    _newEmail.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _passwordMessage = null;
      _passwordSuccess = false;
    });
    if (_newPassword.text.length < 6) {
      setState(() {
        _passwordMessage = 'Password must be at least 6 characters';
      });
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      setState(() => _passwordMessage = 'Passwords do not match');
      return;
    }
    setState(() => _passwordLoading = true);
    try {
      await AuthRepository().updatePassword(_newPassword.text);
      _newPassword.clear();
      _confirmPassword.clear();
      setState(() {
        _passwordMessage = 'Password changed successfully!';
        _passwordSuccess = true;
      });
    } catch (e) {
      setState(() => _passwordMessage = e.toString());
    } finally {
      if (mounted) setState(() => _passwordLoading = false);
    }
  }

  Future<void> _requestEmailChange() async {
    setState(() {
      _emailMessage = null;
      _emailSuccess = false;
    });
    final email = _newEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailMessage = 'Please enter a valid email address');
      return;
    }
    if (email == _currentEmail) {
      setState(() =>
          _emailMessage = 'New email must be different from your current email');
      return;
    }
    setState(() => _emailLoading = true);
    try {
      await UsersRepository().requestEmailChange(email);
      setState(() {
        _profileStatus = 'email_change_pending:$email';
        _emailMessage =
            'Email change request submitted! Awaiting admin approval.';
        _emailSuccess = true;
      });
      _newEmail.clear();
    } catch (e) {
      setState(() => _emailMessage = e.toString());
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  Future<void> _cancelEmailChange() async {
    setState(() {
      _emailLoading = true;
      _emailMessage = null;
    });
    try {
      await UsersRepository().cancelEmailChange();
      setState(() {
        _profileStatus = 'approved';
        _emailMessage = 'Email change request cancelled.';
        _emailSuccess = true;
      });
    } catch (e) {
      setState(() => _emailMessage = e.toString());
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _profileStatus.startsWith('email_change_pending:');
    final pendingEmail = isPending
        ? _profileStatus.replaceFirst('email_change_pending:', '')
        : '';

    return Scaffold(
      backgroundColor: AppColors.inkBase,
      appBar: AppBar(
        backgroundColor: AppColors.inkBase,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
        ),
        title: Text(
          'Account & Security',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.cream100))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Password',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Must be at least 6 characters.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),
                if (_passwordMessage != null) ...[
                  _MessageBanner(
                    text: _passwordMessage!,
                    success: _passwordSuccess,
                  ),
                  const SizedBox(height: 12),
                ],
                _field(
                  label: 'New password',
                  controller: _newPassword,
                  obscure: _obscureNew,
                  onToggle: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'Confirm password',
                  controller: _confirmPassword,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: _passwordLoading ? 'Saving…' : 'Update password',
                  isLoading: _passwordLoading,
                  onTap: _passwordLoading ? null : _changePassword,
                ),
                const SizedBox(height: 36),
                Divider(color: AppColors.borderSubtle),
                const SizedBox(height: 28),
                Text(
                  'Email',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.inkWarm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _currentEmail.isEmpty
                        ? 'No email on file'
                        : _currentEmail,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_emailMessage != null) ...[
                  _MessageBanner(
                    text: _emailMessage!,
                    success: _emailSuccess,
                  ),
                  const SizedBox(height: 12),
                ],
                if (isPending) ...[
                  Text(
                    'Pending change to $pendingEmail — awaiting admin approval.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _emailLoading ? null : _cancelEmailChange,
                    child: Text(
                      _emailLoading ? 'Cancelling…' : 'Cancel request',
                      style: const TextStyle(color: AppColors.dislike),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Email changes require platform owner approval.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: 'New email',
                    controller: _newEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: _emailLoading
                        ? 'Submitting…'
                        : 'Request email change',
                    isLoading: _emailLoading,
                    onTap: _emailLoading ? null : _requestEmailChange,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onToggle == null
            ? null
            : IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String text;
  final bool success;
  const _MessageBanner({required this.text, required this.success});

  @override
  Widget build(BuildContext context) {
    final c = success ? const Color(0xFF10B981) : AppColors.dislike;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: c,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
