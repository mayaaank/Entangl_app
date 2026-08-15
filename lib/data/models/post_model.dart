import '../../core/theme/post_format.dart';
import '../../domain/scrap/scrap_content.dart';
import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final ScrapContent content;
  final String caption;
  final String createdAt;
  final UserModel? author;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final bool isLiked;
  final bool isDisliked;

  const PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.caption = '',
    required this.createdAt,
    this.author,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
  });

  /// Classification for compose / legacy frames. Photo height uses
  /// [PhotoContent.dimensions], not this.
  PostFormat get format => switch (content) {
        TextContent() => PostFormat.text,
        CollageContent() => PostFormat.collage,
        PhotoContent photo => photo.hasStoredSize
            ? PostFormat.fromPixelSize(
                photo.dimensions.width,
                photo.dimensions.height,
              )
            : PostFormat.fromImageUrl(photo.url),
      };

  factory PostModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // profiles can come back as a Map or a List depending on Supabase version
    final profileData = json['profiles'];
    UserModel? author;
    if (profileData is Map<String, dynamic>) {
      author = UserModel.fromJson(profileData);
    } else if (profileData is List && profileData.isNotEmpty) {
      author = UserModel.fromJson(
          Map<String, dynamic>.from(profileData.first as Map));
    }

    final likes = (json['likes'] as List?) ?? [];
    final dislikes = (json['dislikes'] as List?) ?? [];
    final comments = (json['comments'] as List?) ?? [];
    final storedText = json['content'] as String? ?? '';
    final imageUrl = json['image_url'] as String?;
    final content = ScrapContent.fromStored(
      text: storedText,
      imageUrl: imageUrl,
      originalWidth: _asInt(json['original_width']),
      originalHeight: _asInt(json['original_height']),
    );

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: content,
      caption: switch (content) {
        TextContent() => '',
        PhotoContent() || CollageContent() => storedText,
      },
      createdAt: json['created_at'] as String,
      author: author,
      likeCount: likes.length,
      dislikeCount: dislikes.length,
      commentCount: comments.length,
      isLiked: currentUserId != null &&
          likes.any((l) => (l as Map)['user_id'] == currentUserId),
      isDisliked: currentUserId != null &&
          dislikes.any((d) => (d as Map)['user_id'] == currentUserId),
    );
  }

  PostModel copyWith({
    int? likeCount,
    int? dislikeCount,
    int? commentCount,
    bool? isLiked,
    bool? isDisliked,
  }) =>
      PostModel(
        id: id,
        userId: userId,
        content: content,
        caption: caption,
        createdAt: createdAt,
        author: author,
        likeCount: likeCount ?? this.likeCount,
        dislikeCount: dislikeCount ?? this.dislikeCount,
        commentCount: commentCount ?? this.commentCount,
        isLiked: isLiked ?? this.isLiked,
        isDisliked: isDisliked ?? this.isDisliked,
      );
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
