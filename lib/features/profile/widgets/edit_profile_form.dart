import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/profile_provider.dart';
import '../screens/crop_avatar_screen.dart';

/// Pure form — reads EditProfileNotifier, calls its methods only.
class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key});
  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _name     = TextEditingController();
  final _username = TextEditingController();
  final _bio      = TextEditingController();
  bool _loaded    = false;

  // ── Password change ────────────────────────────────────────
  final _newPassword     = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _passwordLoading  = false;
  String? _passwordMessage;
  bool _passwordSuccess  = false;
  bool _obscureNew       = true;
  bool _obscureConfirm   = true;

  // ── Email change ───────────────────────────────────────────
  final _newEmail       = TextEditingController();
  bool _emailLoading    = false;
  String? _emailMessage;
  bool _emailSuccess    = false;
  String _profileStatus = 'approved';
  String _currentEmail  = '';

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  Future<void> _loadInitialValues() async {
    final profile =
        await ref.read(usersRepositoryProvider).getOwnProfile();
    if (profile != null && mounted) {
      ref.read(editProfileProvider.notifier).load(profile);
      _name.text     = profile.fullName;
      _username.text = profile.username;
      _bio.text      = profile.bio ?? '';
      _profileStatus = profile.status;
      _currentEmail  = AuthRepository().currentEmail ?? '';
      setState(() => _loaded = true);
    }
  }

  /// Pick → crop → set
  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90, // slightly higher quality before crop
    );
    if (picked == null || !mounted) return;

    // Push the crop screen and wait for the cropped File (or null if cancelled)
    final cropped = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CropAvatarScreen(imageFile: File(picked.path)),
      ),
    );

    if (cropped != null) {
      ref.read(editProfileProvider.notifier).setAvatar(cropped);
    }
  }

  // ── Password change handlers ───────────────────────────────

  Future<void> _changePassword() async {
    setState(() {
      _passwordMessage = null;
      _passwordSuccess = false;
    });

    if (_newPassword.text.length < 6) {
      setState(() {
        _passwordMessage = 'Password must be at least 6 characters';
        _passwordSuccess = false;
      });
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      setState(() {
        _passwordMessage = 'Passwords do not match';
        _passwordSuccess = false;
      });
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
      setState(() {
        _passwordMessage = e.toString();
        _passwordSuccess = false;
      });
    } finally {
      setState(() => _passwordLoading = false);
    }
  }

  // ── Email change handlers ──────────────────────────────────

  Future<void> _requestEmailChange() async {
    setState(() {
      _emailMessage = null;
      _emailSuccess = false;
    });

    final email = _newEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailMessage = 'Please enter a valid email address';
        _emailSuccess = false;
      });
      return;
    }
    if (email == _currentEmail) {
      setState(() {
        _emailMessage = 'New email must be different from your current email';
        _emailSuccess = false;
      });
      return;
    }

    setState(() => _emailLoading = true);
    try {
      await UsersRepository().requestEmailChange(email);
      setState(() {
        _profileStatus = 'email_change_pending:$email';
        _emailMessage  = 'Email change request submitted! Awaiting admin approval.';
        _emailSuccess  = true;
      });
      _newEmail.clear();
    } catch (e) {
      setState(() {
        _emailMessage = e.toString();
        _emailSuccess = false;
      });
    } finally {
      setState(() => _emailLoading = false);
    }
  }

  Future<void> _cancelEmailChange() async {
    setState(() {
      _emailLoading = true;
      _emailMessage = null;
      _emailSuccess = false;
    });
    try {
      await UsersRepository().cancelEmailChange();
      setState(() {
        _profileStatus = 'approved';
        _emailMessage  = 'Email change request cancelled.';
        _emailSuccess  = true;
      });
    } catch (e) {
      setState(() {
        _emailMessage = e.toString();
        _emailSuccess = false;
      });
    } finally {
      setState(() => _emailLoading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _username.dispose(); _bio.dispose();
    _newPassword.dispose(); _confirmPassword.dispose();
    _newEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.cream100));
    }

    final state    = ref.watch(editProfileProvider);
    final notifier = ref.read(editProfileProvider.notifier);
    final profile  = ref.watch(ownProfileProvider).valueOrNull;


    final isEmailChangePending =
        _profileStatus.startsWith('email_change_pending:');
    final pendingEmail = isEmailChangePending
        ? _profileStatus.replaceFirst('email_change_pending:', '')
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ─────────────────────────────────────────
          Center(
            child: Stack(
              children: [
                state.avatarFile != null
                    ? CircleAvatar(
                        radius: 52,
                        backgroundImage: FileImage(state.avatarFile!))
                    : AvatarWidget(
                        imageUrl: profile?.avatarUrl,
                        size: 104,
                        showRing: true),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.cream100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: AppColors.textOnCream, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Tap to change photo',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 36),

          // ── Profile fields ─────────────────────────────────
          _LabeledField(label: 'Full Name', controller: _name,
              onChanged: notifier.setFullName),
          const SizedBox(height: 16),
          _LabeledField(label: 'Username', controller: _username,
              onChanged: notifier.setUsername),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bio'.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: _bio,
                maxLines: 4, maxLength: 160,
                onChanged: notifier.setBio,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                    hintText: 'Tell us about yourself...'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Save Changes',
            isLoading: state.isSaving,
            onTap: state.isSaving ? null : notifier.save,
          ),

          // ── Divider ────────────────────────────────────────
          const SizedBox(height: 32),
          Divider(color: AppColors.outlineVariant.withOpacity(0.2)),
          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════
          // CHANGE PASSWORD
          // ══════════════════════════════════════════════════
          Row(children: [
            Icon(Icons.lock_outline_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Change Password',
                style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.onSurfaceDark, fontSize: 20)),
          ]),
          const SizedBox(height: 6),
          Text('Update your account password. Must be at least 6 characters.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.outlineVariant)),
          const SizedBox(height: 20),

          if (_passwordMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _passwordSuccess
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _passwordSuccess
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Text(_passwordMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: _passwordSuccess
                          ? const Color(0xFF10B981)
                          : AppColors.error,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
          ],

          _LabeledField(
            label: 'New Password',
            controller: _newPassword,
            onChanged: (_) {},
            obscure: _obscureNew,
            onToggleObscure: () =>
                setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: 'Confirm New Password',
            controller: _confirmPassword,
            onChanged: (_) {},
            obscure: _obscureConfirm,
            onToggleObscure: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 20),

          _SmallActionButton(
            label:     _passwordLoading ? 'Changing...' : 'Change Password',
            icon:      Icons.lock_outline_rounded,
            isLoading: _passwordLoading,
            onTap:     (_passwordLoading ||
                       _newPassword.text.isEmpty ||
                       _confirmPassword.text.isEmpty)
                ? null
                : _changePassword,
          ),

          // ── Divider ────────────────────────────────────────
          const SizedBox(height: 32),
          Divider(color: AppColors.outlineVariant.withOpacity(0.2)),
          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════
          // CHANGE EMAIL
          // ══════════════════════════════════════════════════
          Row(children: [
            Icon(Icons.mail_outline_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Change Email',
                style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.onSurfaceDark, fontSize: 20)),
          ]),
          const SizedBox(height: 12),

          // Current email display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Text('Current email: ',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantDark)),
              Expanded(
                child: Text(_currentEmail,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceDark,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          if (_emailMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _emailSuccess
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _emailSuccess
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Text(_emailMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: _emailSuccess
                          ? const Color(0xFF10B981)
                          : AppColors.error,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
          ],

          if (isEmailChangePending) ...[
            _InfoCard(
              icon:       Icons.schedule_rounded,
              iconColor:  const Color(0xFFF59E0B),
              title:      'Email Change Pending',
              subtitle:
                  'Your request to change email to $pendingEmail '
                  'is awaiting admin approval.',
            ),
            const SizedBox(height: 12),
            _SmallActionButton(
              label:     _emailLoading ? 'Cancelling...' : 'Cancel Request',
              icon:      Icons.cancel_outlined,
              color:     AppColors.error,
              isLoading: _emailLoading,
              onTap:     _emailLoading ? null : _cancelEmailChange,
            ),
          ] else ...[
            Text(
              'You can change your email once. This requires approval from the platform owner.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.outlineVariant),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label:     'New Email Address',
              controller: _newEmail,
              onChanged: (_) {},
              hint:      'newemail@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _SmallActionButton(
              label:     _emailLoading
                  ? 'Submitting...'
                  : 'Request Email Change',
              icon:      Icons.mail_outline_rounded,
              isLoading: _emailLoading,
              onTap:     (_emailLoading || _newEmail.text.isEmpty)
                  ? null
                  : _requestEmailChange,
            ),
          ],

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// ── Helper widgets ───────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? hint;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.obscure        = false,
    this.onToggleObscure,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint ?? label,
              suffixIcon: onToggleObscure != null
                  ? IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      );
}

class _SmallActionButton extends StatelessWidget {
  final String      label;
  final IconData    icon;
  final Color       color;
  final bool        isLoading;
  final VoidCallback? onTap;

  const _SmallActionButton({
    required this.label,
    required this.icon,
    this.color     = AppColors.primaryContainer,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: onTap != null ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (isLoading)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          else
            Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title;
  final String   subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceDark,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariantDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}