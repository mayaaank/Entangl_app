import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/utils/auth_errors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../profile/providers/profile_provider.dart';

Future<bool> showChangeEmailSheet(BuildContext context) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChangeEmailSheet(),
  );
  return ok == true;
}

class ChangeEmailSheet extends ConsumerStatefulWidget {
  const ChangeEmailSheet({super.key});

  @override
  ConsumerState<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends ConsumerState<ChangeEmailSheet> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(usersRepositoryProvider)
          .requestEmailChange(_email.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = humaniseAuthError(e);
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
              Text('Request email change', style: AppTextStyles.title1),
              const SizedBox(height: 6),
              Text(
                'An admin has to approve this before your login email updates.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || !v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'New email'),
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
                label: 'Submit request',
                isLoading: _busy,
                onTap: _busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
