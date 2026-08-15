import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/providers/auth_provider.dart';

Future<bool> showChangePasswordSheet(BuildContext context) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChangePasswordSheet(),
  );
  return changed == true;
}

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    await ref.read(authNotifierProvider.notifier).changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state is AsyncError) {
      setState(() => _error = humaniseAuthError(state.error));
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final busy = ref.watch(authNotifierProvider) is AsyncLoading;
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surfaceLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: palette.outline, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Change password', style: AppTextStyles.title1),
              const SizedBox(height: 6),
              Text(
                'Use at least 6 characters. You’ll stay signed in on this device.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _PasswordField(
                controller: _current,
                label: 'Current password',
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your current password' : null,
              ),
              const SizedBox(height: 14),
              _PasswordField(
                controller: _next,
                label: 'New password',
                obscure: _obscure,
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _PasswordField(
                controller: _confirm,
                label: 'Confirm new password',
                obscure: _obscure,
                validator: (v) =>
                    v != _next.text ? 'Passwords do not match.' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: AppTextStyles.bodySmall.copyWith(color: palette.error),
                ),
              ],
              const SizedBox(height: 20),
              GradientButton(
                label: 'Update password',
                isLoading: busy,
                onTap: busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback? onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(color: palette.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: palette.onSurfaceVariant,
        ),
        suffixIcon: onToggle == null
            ? null
            : IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: palette.outline,
                  size: 20,
                ),
              ),
      ),
    );
  }
}
