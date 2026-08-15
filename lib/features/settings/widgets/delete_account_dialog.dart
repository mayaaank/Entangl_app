import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../auth/providers/auth_provider.dart';

Future<bool> confirmDeleteAccount(BuildContext context) async {
  final deleted = await showDialog<bool>(
    context: context,
    builder: (_) => const DeleteAccountDialog(),
  );
  return deleted == true;
}

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_confirm.text.trim() != 'DELETE') {
      setState(() => _error = 'Type DELETE to confirm.');
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }
    setState(() => _error = null);
    await ref
        .read(authNotifierProvider.notifier)
        .deleteAccount(password: _password.text);
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

    return AlertDialog(
      backgroundColor: palette.surfaceLowest,
      title: Text('Delete account?', style: AppTextStyles.title2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'This removes your scraps and signs you out. Type DELETE and enter your password.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirm,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Type DELETE',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(color: palette.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: busy ? null : _submit,
          child: Text(
            busy ? 'Deleting…' : 'Delete',
            style: AppTextStyles.labelLarge.copyWith(color: palette.error),
          ),
        ),
      ],
    );
  }
}
