import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/dynamic_post_image.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/create_post_provider.dart';

const _maxChars = 500;

/// Create-post form matching Stitch: grid canvas, ghost prompt,
/// pastel swatches, tool row (photo / camera / stickers).
class CreatePostForm extends ConsumerStatefulWidget {
  const CreatePostForm({super.key});

  @override
  ConsumerState<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends ConsumerState<CreatePostForm> {
  final _ctrl = TextEditingController();
  bool _draftHydrated = false;
  int _selectedSwatch = 0;

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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      ref.read(createPostProvider.notifier).setImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPostProvider);
    final remaining = _maxChars - state.content.length;
    final isNearLimit = remaining <= 50;
    final isOverLimit = remaining < 0;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.hasRestoredDraft && _draftHydrated) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.paperWarm,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.borderCard, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_rounded,
                              color: AppColors.textPrimary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Draft restored',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Grid paper canvas
                  Container(
                    constraints: const BoxConstraints(minHeight: 280),
                    decoration: BoxDecoration(
                      color: AppColors.paperGrid,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.borderCard, width: 2),
                      boxShadow: AppColors.shadowDoodle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CustomPaint(
                        painter: _GridPainter(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (state.imageFile != null)
                                DynamicFileImage(
                                  file: state.imageFile!,
                                  onClear: () => ref
                                      .read(createPostProvider.notifier)
                                      .clearImage(),
                                )
                              else if (state.content.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 28),
                                  child: Column(
                                    children: [
                                      GhostMascot(
                                        expression:
                                            GhostExpression.waving,
                                        size: 88,
                                        animate: true,
                                      ),
                                      SizedBox(height: 12),
                                      _SpeechBubble(
                                        text: 'Doodle something',
                                      ),
                                    ],
                                  ),
                                ),
                              TextField(
                                controller: _ctrl,
                                onChanged: (v) => ref
                                    .read(createPostProvider.notifier)
                                    .setContent(v),
                                maxLines: null,
                                maxLength: _maxChars,
                                buildCounter: (_,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 17,
                                  height: 1.45,
                                ),
                                decoration: InputDecoration(
                                  hintText: state.imageFile != null
                                      ? 'Add a caption…'
                                      : 'What are you sketching today?',
                                  hintStyle:
                                      AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 17,
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (state.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$remaining',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isOverLimit
                              ? AppColors.dislike
                              : isNearLimit
                                  ? AppColors.cream80
                                  : AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Pastel color swatches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      AppColors.doodleSwatches.length,
                      (i) {
                        final c = AppColors.doodleSwatches[i];
                        final selected = _selectedSwatch == i;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedSwatch = i);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: selected ? 36 : 32,
                            height: selected ? 36 : 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.borderCard,
                                width: selected ? 2.5 : 1.5,
                              ),
                              boxShadow: selected
                                  ? AppColors.shadowDoodle
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tool row
        Container(
          padding: EdgeInsets.fromLTRB(8, 10, 8, 10 + bottom),
          decoration: const BoxDecoration(
            color: AppColors.inkBase,
            border: Border(
              top: BorderSide(color: AppColors.borderDefault, width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Tool(
                      icon: Icons.photo_outlined,
                      label: 'Photo',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  Expanded(
                    child: _Tool(
                      icon: Icons.videocam_outlined,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  Expanded(
                    child: _Tool(
                      icon: Icons.emoji_emotions_outlined,
                      label: 'Sticker',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _insertText('✨');
                      },
                    ),
                  ),
                  Expanded(
                    child: _Tool(
                      icon: Icons.edit_outlined,
                      label: 'Doodle',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _insertText('✏️');
                      },
                    ),
                  ),
                  Expanded(
                    child: _Tool(
                      icon: Icons.poll_outlined,
                      label: 'Poll',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Polls coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _Tool(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.public_rounded,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Anyone can reply',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inkMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTextStyles.doodleAccent.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Tool({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A1A1610)
      ..strokeWidth = 1;

    const step = 22.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
