import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/collage_layout.dart';
import '../../../core/theme/post_format.dart';
import '../../feed/providers/feed_provider.dart';

const _maxChars = 500;

class CreatePostState {
  final String content;
  final File? imageFile;
  final PostFormat format;
  final List<File> collageFiles;
  final CollageLayout collageLayout;
  final int? imageWidth;
  final int? imageHeight;
  final bool isSubmitting;
  final String? error;
  final bool submitted;

  const CreatePostState({
    this.content = '',
    this.imageFile,
    this.format = PostFormat.text,
    this.collageFiles = const [],
    this.collageLayout = CollageLayout.quad,
    this.imageWidth,
    this.imageHeight,
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  bool get canSubmit {
    final hasText = content.trim().isNotEmpty;
    final hasImage = imageFile != null && format.isMedia && format != PostFormat.collage;
    final hasCollage = format == PostFormat.collage &&
        collageFiles.length >= collageLayout.slotCount;
    return (hasText || hasImage || hasCollage) &&
        content.length <= _maxChars &&
        !isSubmitting;
  }

  CreatePostState copyWith({
    String? content,
    File? imageFile,
    PostFormat? format,
    List<File>? collageFiles,
    CollageLayout? collageLayout,
    int? imageWidth,
    int? imageHeight,
    bool? clearImage,
    bool? clearCollage,
    bool? isSubmitting,
    String? error,
    bool? submitted,
  }) =>
      CreatePostState(
        content: content ?? this.content,
        imageFile: clearImage == true ? null : imageFile ?? this.imageFile,
        format: format ??
            (clearImage == true &&
                    this.format.isMedia &&
                    this.format != PostFormat.collage
                ? PostFormat.text
                : this.format),
        collageFiles:
            clearCollage == true ? const [] : collageFiles ?? this.collageFiles,
        collageLayout: collageLayout ?? this.collageLayout,
        imageWidth: clearImage == true ? null : imageWidth ?? this.imageWidth,
        imageHeight: clearImage == true ? null : imageHeight ?? this.imageHeight,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        submitted: submitted ?? this.submitted,
      );
}

class CreatePostNotifier extends Notifier<CreatePostState> {
  @override
  CreatePostState build() => const CreatePostState();

  void setContent(String v) => state = state.copyWith(content: v);

  void setImage(
    File f, {
    PostFormat? format,
    int? width,
    int? height,
  }) =>
      state = state.copyWith(
        imageFile: f,
        clearCollage: true,
        imageWidth: width,
        imageHeight: height,
        format: format ??
            (state.format.isMedia && state.format != PostFormat.collage
                ? state.format
                : PostFormat.square),
      );

  void setFormat(PostFormat format) {
    if (format == PostFormat.text) {
      state = state.copyWith(
        format: PostFormat.text,
        clearImage: true,
        clearCollage: true,
      );
    } else if (format == PostFormat.collage) {
      state = state.copyWith(format: PostFormat.collage, clearImage: true);
    } else {
      state = state.copyWith(format: format, clearCollage: true);
    }
  }

  void setCollage(List<File> files, CollageLayout layout) =>
      state = state.copyWith(
        format: PostFormat.collage,
        collageFiles: files,
        collageLayout: layout,
        clearImage: true,
      );

  void setCollageLayout(CollageLayout layout) =>
      state = state.copyWith(collageLayout: layout);

  void clearImage() => state = state.copyWith(clearImage: true);

  void clearCollage() =>
      state = state.copyWith(clearCollage: true, format: PostFormat.text);

  Future<void> submit() async {
    if (!state.canSubmit) return;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final isCollage = state.format == PostFormat.collage &&
          state.collageFiles.isNotEmpty;
      await ref.read(postsRepositoryProvider).createPost(
            content: state.content.trim(),
            imageFile: isCollage ? null : state.imageFile,
            format: isCollage
                ? PostFormat.collage
                : (state.imageFile == null ? PostFormat.text : state.format),
            collageFiles: isCollage ? state.collageFiles : null,
            collageLayout: isCollage ? state.collageLayout : null,
            imageWidth: isCollage ? null : state.imageWidth,
            imageHeight: isCollage ? null : state.imageHeight,
          );
      state = state.copyWith(isSubmitting: false, submitted: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(
        CreatePostNotifier.new);
