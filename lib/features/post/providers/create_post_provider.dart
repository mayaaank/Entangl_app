import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../feed/providers/feed_provider.dart';

const _maxChars = 500;
const _kDraftContent = 'entangl_post_draft_content_v1';
const _kDraftImage = 'entangl_post_draft_image_v1';

class CreatePostState {
  final String content;
  final File? imageFile;
  final bool isSubmitting;
  final String? error;
  final bool submitted;
  final bool draftLoaded;
  final bool hasRestoredDraft;

  const CreatePostState({
    this.content = '',
    this.imageFile,
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
    this.draftLoaded = false,
    this.hasRestoredDraft = false,
  });

  bool get canSubmit =>
      (content.trim().isNotEmpty || imageFile != null) &&
      content.length <= _maxChars &&
      !isSubmitting;

  CreatePostState copyWith({
    String? content,
    File? imageFile,
    bool? clearImage,
    bool? isSubmitting,
    String? error,
    bool? submitted,
    bool? draftLoaded,
    bool? hasRestoredDraft,
  }) =>
      CreatePostState(
        content: content ?? this.content,
        imageFile: clearImage == true ? null : imageFile ?? this.imageFile,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        submitted: submitted ?? this.submitted,
        draftLoaded: draftLoaded ?? this.draftLoaded,
        hasRestoredDraft: hasRestoredDraft ?? this.hasRestoredDraft,
      );
}

class CreatePostNotifier extends Notifier<CreatePostState> {
  @override
  CreatePostState build() => const CreatePostState();

  Future<void> loadDraft() async {
    if (state.draftLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString(_kDraftContent) ?? '';
    final imagePath = prefs.getString(_kDraftImage);
    File? image;
    if (imagePath != null && imagePath.isNotEmpty) {
      final f = File(imagePath);
      if (await f.exists()) image = f;
    }
    final has = content.trim().isNotEmpty || image != null;
    state = state.copyWith(
      content: content,
      imageFile: image,
      draftLoaded: true,
      hasRestoredDraft: has,
    );
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final c = state.content;
    if (c.trim().isEmpty && state.imageFile == null) {
      await prefs.remove(_kDraftContent);
      await prefs.remove(_kDraftImage);
      return;
    }
    await prefs.setString(_kDraftContent, c);
    if (state.imageFile != null) {
      await prefs.setString(_kDraftImage, state.imageFile!.path);
    } else {
      await prefs.remove(_kDraftImage);
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDraftContent);
    await prefs.remove(_kDraftImage);
  }

  void setContent(String v) {
    state = state.copyWith(content: v, hasRestoredDraft: false);
    _persistDraft();
  }

  void setImage(File f) {
    state = state.copyWith(imageFile: f, hasRestoredDraft: false);
    _persistDraft();
  }

  void clearImage() {
    state = state.copyWith(clearImage: true, hasRestoredDraft: false);
    _persistDraft();
  }

  Future<void> discardDraft() async {
    await clearDraft();
    state = const CreatePostState(draftLoaded: true);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await ref.read(postsRepositoryProvider).createPost(
            content: state.content.trim(),
            imageFile: state.imageFile,
          );
      await clearDraft();
      state = state.copyWith(isSubmitting: false, submitted: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(
        CreatePostNotifier.new);
