import 'media_dimensions.dart';

/// Encode/decode original pixels in the storage path so masonry
/// can reserve height before the image bytes arrive.
///
/// Path fragment: `_w1080_h1350`
class MediaMetrics {
  MediaMetrics._();

  static final _size = RegExp(r'_w(\d+)_h(\d+)');

  static String sizeToken(int width, int height) => '_w${width}_h$height';

  static MediaDimensions? parse(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = _size.firstMatch(url);
    if (match == null) return null;
    final w = int.tryParse(match.group(1)!);
    final h = int.tryParse(match.group(2)!);
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return MediaDimensions(width: w, height: h);
  }

  /// width / height — 1080×1350 → 0.8
  static double? aspectRatio(String? url) => parse(url)?.aspectRatio;

  static String fileName({
    required String uid,
    required String formatKey,
    required String ext,
    int? width,
    int? height,
  }) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final size = (width != null && height != null)
        ? sizeToken(width, height)
        : '';
    return '$uid/${stamp}_$formatKey$size.$ext';
  }
}
