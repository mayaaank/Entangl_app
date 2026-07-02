import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feed/providers/feed_provider.dart';

const _maxChars = 500;

class CreatePostState {
  final String  content;
  final File?   imageFile;
  final bool    isSubmitting;
  final String? error;
  final bool    submitted;

  const CreatePostState({
    this.content      = '',
    this.imageFile,
    this.isSubmitting = false,
    this.error,
    this.submitted    = false,
  });

  bool get canSubmit =>
      content.trim().isNotEmpty &&
      content.length <= _maxChars &&
      !isSubmitting;

  CreatePostState copyWith({
    String?  content,
    File?    imageFile,
    bool?    clearImage,
    bool?    isSubmitting,
    String?  error,
    bool?    submitted,
  }) =>
      CreatePostState(
        content:      content      ?? this.content,
        imageFile:    clearImage == true ? null : imageFile ?? this.imageFile,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error:        error,
        submitted:    submitted    ?? this.submitted,
      );
}

class CreatePostNotifier extends Notifier<CreatePostState> {
  @override
  CreatePostState build() => const CreatePostState();

  void setContent(String v) => state = state.copyWith(content: v);
  void setImage(File f)     => state = state.copyWith(imageFile: f);
  void clearImage()         => state = state.copyWith(clearImage: true);

  Future<void> submit() async {
    if (!state.canSubmit) return;
    // Synchronous guard — prevents double-tap
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await ref.read(postsRepositoryProvider).createPost(
            content:   state.content.trim(),
            imageFile: state.imageFile,
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
