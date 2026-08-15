import '../../core/layout/media_dimensions.dart';
import '../../core/layout/media_metrics.dart';
import '../../core/layout/text_layout_calculator.dart';
import '../../core/theme/collage_layout.dart';
import '../../core/theme/post_format.dart';

/// Explicit scrap body. A post is one of these — never a mix of optional fields.
sealed class ScrapContent {
  const ScrapContent();

  /// Reserved masonry height for [width]. Caption chrome is not included.
  double heightFor(double width);

  /// Map the stored `content` + `image_url` row into one content type.
  factory ScrapContent.fromStored({
    required String text,
    String? imageUrl,
    int? originalWidth,
    int? originalHeight,
  }) {
    final collage = CollagePayload.tryParse(imageUrl);
    if (collage != null) {
      return CollageContent(
        layout: collage.layout,
        urls: collage.urls,
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      final encoded = MediaMetrics.parse(imageUrl);
      final hasColumnSize = originalWidth != null &&
          originalHeight != null &&
          originalWidth > 0 &&
          originalHeight > 0;
      final hasStoredSize = hasColumnSize || encoded != null;
      final dimensions = hasColumnSize
          ? MediaDimensions(width: originalWidth, height: originalHeight)
          : encoded ??
              MediaDimensions.fallback(
                PostFormat.fromImageUrl(imageUrl).aspectRatio,
              );
      return PhotoContent(
        url: imageUrl,
        dimensions: dimensions,
        hasStoredSize: hasStoredSize,
      );
    }

    return TextContent(text);
  }
}

final class PhotoContent extends ScrapContent {
  final String url;
  final MediaDimensions dimensions;
  final bool hasStoredSize;

  const PhotoContent({
    required this.url,
    required this.dimensions,
    this.hasStoredSize = true,
  });

  double get aspectRatio => dimensions.aspectRatio;

  @override
  double heightFor(double width) => dimensions.heightFor(width);
}

final class TextContent extends ScrapContent {
  final String text;

  const TextContent(this.text);

  @override
  double heightFor(double width) =>
      TextLayoutCalculator.height(text: text, width: width);
}

final class CollageContent extends ScrapContent {
  final CollageLayout layout;
  final List<String> urls;

  const CollageContent({
    required this.layout,
    required this.urls,
  });

  double get aspectRatio => layout.aspectRatio;

  @override
  double heightFor(double width) {
    final ratio = aspectRatio;
    if (ratio <= 0) return width;
    return width / ratio;
  }
}
