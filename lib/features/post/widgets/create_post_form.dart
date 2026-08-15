import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/collage_layout.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../core/theme/post_format.dart';
import '../../../shared/widgets/collage_frame.dart';
import '../../../shared/widgets/emoji_text.dart';
import '../../../shared/widgets/mascot_widgets.dart';
import '../providers/create_post_provider.dart';

const _maxChars = 500;

class CreatePostForm extends ConsumerStatefulWidget {
  const CreatePostForm({super.key});

  @override
  ConsumerState<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends ConsumerState<CreatePostForm> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _showStickers = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
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
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    var guessed = PostFormat.square;
    int? width;
    int? height;
    try {
      final bytes = await file.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      width = decoded.width;
      height = decoded.height;
      guessed = PostFormat.fromPixelSize(decoded.width, decoded.height);
    } catch (_) {}
    ref.read(createPostProvider.notifier).setImage(
          file,
          format: guessed,
          width: width,
          height: height,
        );
  }

  Future<void> _startCollage() async {
    final palette = context.palette;
    var layout = ref.read(createPostProvider).collageLayout;
    final chosen = await showModalBottomSheet<CollageLayout>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Choose a layout', style: AppTextStyles.title2),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: CollageLayout.values
                        .map(
                          (l) => CollageLayoutPreview(
                            layout: l,
                            selected: layout == l,
                            onTap: () => setSheet(() => layout = l),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, layout),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: palette.onPrimary,
                      ),
                      child: Text('Pick ${layout.slotCount} photos'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (chosen == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85, limit: chosen.slotCount);
    if (!mounted) return;
    if (picked.isEmpty) return;
    if (picked.length < chosen.slotCount) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('This layout needs ${chosen.slotCount} photos.'),
      ));
      return;
    }
    ref.read(createPostProvider.notifier).setCollage(
          picked.take(chosen.slotCount).map((x) => File(x.path)).toList(),
          chosen,
        );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final state = ref.watch(createPostProvider);
    final remaining = _maxChars - state.content.length;
    final isNearLimit = remaining <= 50;
    final isOverLimit = remaining < 0;
    final showEmpty = state.content.isEmpty &&
        state.imageFile == null &&
        state.collageFiles.isEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (showEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GhostMascot(
                            expression: GhostExpression.floating,
                            size: 96,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            transform: Matrix4.rotationZ(-0.03),
                            decoration: BoxDecoration(
                              color: palette.surfaceLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: palette.onSurface,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "What's on your mind?",
                                  style: AppTextStyles.title2,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Doodle, snap, or collage something to tangle with the world.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: palette.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        onChanged: (v) =>
                            ref.read(createPostProvider.notifier).setContent(v),
                        maxLines: null,
                        maxLength: _maxChars,
                        buildCounter: (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) =>
                            null,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontFamilyFallback: AppTextStyles.emojiFallback,
                        ),
                        cursorColor: palette.primary,
                        decoration: InputDecoration(
                          hintText: showEmpty ? '' : "What's on your mind?",
                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                            color: palette.outline,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                      if (state.imageFile != null) ...[
                        const SizedBox(height: 8),
                        _FormatChips(
                          selected: state.format,
                          onSelect: (f) => ref
                              .read(createPostProvider.notifier)
                              .setFormat(f),
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: state.format.isMedia
                                  ? state.format.aspectRatio
                                  : 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: palette.onSurface,
                                    width: 1.5,
                                  ),
                                  image: DecorationImage(
                                    image: FileImage(state.imageFile!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(createPostProvider.notifier)
                                    .clearImage(),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: palette.surfaceLowest,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.onSurface,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(Icons.close, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (state.collageFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: CollageLayout.values.map((l) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CollageLayoutPreview(
                                  layout: l,
                                  selected: state.collageLayout == l,
                                  onTap: () {
                                    if (state.collageFiles.length < l.slotCount) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${l.label} needs ${l.slotCount} photos.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    ref
                                        .read(createPostProvider.notifier)
                                        .setCollageLayout(l);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: palette.onSurface,
                                  width: 1.5,
                                ),
                              ),
                              child: CollageFrame(
                                layout: state.collageLayout,
                                files: state.collageFiles
                                    .take(state.collageLayout.slotCount)
                                    .toList(),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(createPostProvider.notifier)
                                    .clearCollage(),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: palette.surfaceLowest,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.onSurface,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(Icons.close, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (state.content.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '$remaining',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isOverLimit
                                    ? palette.error
                                    : isNearLimit
                                        ? palette.onSurfaceVariant
                                        : palette.outline,
                              ),
                            ),
                          ),
                        ),
                      if (_showStickers) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          children: ['🌟', '⚡️', '❤️', '✨', '🐸', '👻']
                              .map(
                                (e) => GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _insertText(e);
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: palette.toolFill,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: palette.onSurface,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: EmojiText(
                                      e,
                                      style: AppTextStyles.emojiOnly(size: 22),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: palette.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.onSurface, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Tool(
                      icon: Icons.image_rounded,
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    _Tool(
                      icon: Icons.photo_camera_rounded,
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _Tool(
                      icon: Icons.grid_view_rounded,
                      onTap: _startCollage,
                    ),
                    _Tool(
                      icon: Icons.mood_rounded,
                      onTap: () =>
                          setState(() => _showStickers = !_showStickers),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatChips extends StatelessWidget {
  final PostFormat selected;
  final ValueChanged<PostFormat> onSelect;

  const _FormatChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: PostFormat.mediaFormats.map((f) {
        final active = selected == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? palette.navActive : palette.surfaceLowest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: palette.onSurface, width: 1.5),
              ),
              child: Text(f.label, style: AppTextStyles.labelSmall),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Tool({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: palette.toolFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.onSurface, width: 1.5),
        ),
        child: Icon(icon, color: palette.onSurface, size: 22),
      ),
    );
  }
}
