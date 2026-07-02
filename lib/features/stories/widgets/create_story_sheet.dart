import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/story_model.dart';
import '../providers/stories_provider.dart';

// 50 MB limit
const _maxBytes = 50 * 1024 * 1024;

class CreateStorySheet extends ConsumerStatefulWidget {
  const CreateStorySheet({super.key});

  @override
  ConsumerState<CreateStorySheet> createState() =>
      _CreateStorySheetState();
}

class _CreateStorySheetState
    extends ConsumerState<CreateStorySheet> {
  File?          _file;
  StoryMediaType _type = StoryMediaType.image;

  Future<void> _pick(ImageSource source, bool isVideo) async {
    final picker = ImagePicker();
    XFile? picked;

    if (isVideo) {
      picked = await picker.pickVideo(
          source:      source,
          maxDuration: const Duration(seconds: 30));
    } else {
      picked = await picker.pickImage(
          source:       source,
          imageQuality: 85);
    }

    if (picked == null) return;

    // ── File size check ──────────────────────────────────
    final bytes = await picked.length();
    if (bytes > _maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.warning_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isVideo
                      ? 'Video is too large. Max 50 MB — try trimming it.'
                      : 'Image is too large. Max 50 MB.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ]),
            backgroundColor: AppColors.dislike,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ));
      }
      return;
    }

    if (mounted) {
      setState(() {
        _file = File(picked!.path);
        _type = isVideo ? StoryMediaType.video : StoryMediaType.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(createStoryProvider);
    final notifier = ref.read(createStoryProvider.notifier);

    ref.listen<CreateStoryState>(createStoryProvider, (_, next) {
      if (next.uploaded) {
        ref.invalidate(createStoryProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Story posted! It expires in 24 hours.',
                  style: TextStyle(color: Colors.white)),
            ]),
            backgroundColor: const Color(0xFF1E5C3A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(next.error!,
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.dislike,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ));
      }
    });

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.inkMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 3,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Add to Story',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 6),
          Text(
            'Disappears after 24 hours · Max 50 MB',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Preview
          if (_file != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.inkWarm,
                image: _type == StoryMediaType.image
                    ? DecorationImage(
                        image: FileImage(_file!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _type == StoryMediaType.video
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_rounded,
                            color: AppColors.cream100, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          _file!.path.split('/').last,
                          style: TextStyle(
                            color: AppColors.textSecondary
                                .withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : null,
            ),

          // Pick options
          if (_file == null)
            Row(children: [
              Expanded(
                child: _PickOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Photo',
                  onTap: () => _pick(ImageSource.gallery, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickOption(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  onTap: () => _pick(ImageSource.gallery, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => _pick(ImageSource.camera, false),
                ),
              ),
            ]),

          if (_file != null)
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _file = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inkWarm,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Change',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: state.isUploading
                      ? null
                      : () {
                          notifier.setFile(_file!, _type);
                          notifier.upload();
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cream100,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.shadowCard,
                    ),
                    child: Center(
                      child: state.isUploading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.textOnCream))
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: AppColors.textOnCream, size: 16),
                                SizedBox(width: 6),
                                Text('Share Story',
                                    style: TextStyle(
                                      color: AppColors.textOnCream,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ]),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PickOption extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _PickOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.inkWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.cream100, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
