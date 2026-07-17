import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/create_post_provider.dart';

const _maxChars = 500;

class CreatePostForm extends ConsumerStatefulWidget {
  const CreatePostForm({super.key});

  @override
  ConsumerState<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends ConsumerState<CreatePostForm> {
  final _ctrl = TextEditingController();
  bool _draftHydrated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(createPostProvider.notifier).loadDraft();
      if (!mounted) return;
      final s = ref.read(createPostProvider);
      if (s.content.isNotEmpty && _ctrl.text != s.content) {
        _ctrl.text = s.content;
        _ctrl.selection =
            TextSelection.collapsed(offset: s.content.length);
      }
      setState(() => _draftHydrated = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    final currentText = _ctrl.text;
    final selection = _ctrl.selection;

    int start = selection.start;
    int end = selection.end;
    if (start < 0 || end < 0) {
      start = currentText.length;
      end = currentText.length;
    }

    final newText = currentText.replaceRange(start, end, text);
    _ctrl.text = newText;
    _ctrl.selection = TextSelection.collapsed(offset: start + text.length);
    ref.read(createPostProvider.notifier).setContent(newText);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      ref.read(createPostProvider.notifier).setImage(File(picked.path));
    }
  }

  Widget _buildStickerBubble(String emoji) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _insertText(emoji);
      },
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inkWarm,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPostProvider);
    final profile = ref.watch(ownProfileProvider).valueOrNull;
    final remaining = _maxChars - state.content.length;
    final isNearLimit = remaining <= 50;
    final isOverLimit = remaining < 0;

    return GestureDetector(
      // Dismiss keyboard when tapping outside input
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.hasRestoredDraft && _draftHydrated) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.inkWarm,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.borderSubtle, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: AppColors.cream100, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Draft restored',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(createPostProvider.notifier)
                            .discardDraft();
                        _ctrl.clear();
                      },
                      child: Text(
                        'Discard',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.dislike,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarWidget(imageUrl: profile?.avatarUrl, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: (v) => ref.read(createPostProvider.notifier).setContent(v),
                    maxLines: null,
                    maxLength: _maxChars,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                        null, // Hide default counter — we draw our own
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            // ── Character counter ──────────────────────────
            if (state.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 56, top: 4, bottom: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    // Circular progress indicator
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        value: state.content.length / _maxChars,
                        strokeWidth: 2.5,
                        backgroundColor: AppColors.borderSubtle,
                        valueColor: AlwaysStoppedAnimation(
                          isOverLimit
                              ? AppColors.dislike
                              : isNearLimit
                                  ? const Color(0xFFFF8C42)
                                  : AppColors.cream100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$remaining',
                      style: TextStyle(
                        color: isOverLimit
                            ? AppColors.dislike
                            : isNearLimit
                                ? const Color(0xFFFF8C42)
                                : AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 13,
                        fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Image preview ──────────────────────────────
            if (state.imageFile != null)
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 56, top: 8, bottom: 8),
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(state.imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => ref.read(createPostProvider.notifier).clearImage(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Sticker Toolbar
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOOD STICKERS',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStickerBubble('🌟'),
                        const SizedBox(width: 10),
                        _buildStickerBubble('⚡️'),
                        const SizedBox(width: 10),
                        _buildStickerBubble('❤️'),
                        const SizedBox(width: 10),
                        _buildStickerBubble('✨'),
                        const SizedBox(width: 10),
                        _buildStickerBubble('🐸'),
                        const SizedBox(width: 10),
                        _buildStickerBubble('👻'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Add photo button
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inkWarm,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.cream100,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add photo to post',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
