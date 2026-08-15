/// Single source of truth for media pixel size and aspect ratio.
///
/// `width / height` lives here — not on PostModel, MasonryEngine, or widgets.
class MediaDimensions {
  final int width;
  final int height;

  const MediaDimensions({
    required this.width,
    required this.height,
  });

  bool get isValid => width > 0 && height > 0;

  /// Width / height. 1080×1350 → 0.8
  double get aspectRatio {
    if (!isValid) return 1;
    return width / height;
  }

  double heightFor(double boxWidth) {
    final ratio = aspectRatio;
    if (ratio <= 0) return boxWidth;
    return boxWidth / ratio;
  }

  /// Used only when the upload path has no stored pixels.
  factory MediaDimensions.fallback(double aspectRatio) {
    const width = 1080;
    final ratio = aspectRatio <= 0 ? 1.0 : aspectRatio;
    final height = (width / ratio).round().clamp(1, 100000);
    return MediaDimensions(width: width, height: height);
  }
}
