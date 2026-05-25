import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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

  @override
  void dispose() {
    _name.dispose(); _username.dispose(); _bio.dispose();
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
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
          Text('Tap to change photo',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 36),
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
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.onChanged,
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(hintText: label),
          ),
        ],
      );
}