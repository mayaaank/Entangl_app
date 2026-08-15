/// Estimated scrap height for text. One rule for masonry and TextScrap.
///
/// Uses character-count estimation so the domain layer stays Flutter-free.
class TextLayoutCalculator {
  static const minHeight = 140.0;
  static const maxHeight = 360.0;
  static const charsPerLine = 18.0;
  static const lineHeight = 18.0;
  static const verticalPadding = 28.0;

  static double height({
    required String text,
    required double width,
  }) {
    final columns = width <= 0
        ? charsPerLine
        : (width / 8).clamp(10, 28);
    final lines = (text.length / columns).clamp(4, 20);
    return (verticalPadding + (lines * lineHeight))
        .clamp(minHeight, maxHeight)
        .toDouble();
  }
}
