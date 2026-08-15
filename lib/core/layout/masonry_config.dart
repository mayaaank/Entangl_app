import 'text_layout_calculator.dart';

/// Shared masonry metrics. One source for columns, gaps, and card width.
class MasonryConfig {
  const MasonryConfig({
    this.padding = 16,
    this.gap = 8,
    this.cardRadius = 12,
    this.captionExtra = 36,
    this.textMinHeight = TextLayoutCalculator.minHeight,
    this.textMaxHeight = TextLayoutCalculator.maxHeight,
    this.pageSize = 20,
    this.prefetchThreshold = 0.8,
    this.breakpoints = const [
      (maxWidth: 600, columns: 2),
      (maxWidth: 900, columns: 3),
      (maxWidth: 1200, columns: 4),
    ],
    this.maxColumns = 5,
  });

  static const scraps = MasonryConfig();

  final double padding;
  final double gap;
  final double cardRadius;
  final double captionExtra;
  final double textMinHeight;
  final double textMaxHeight;
  final int pageSize;
  final double prefetchThreshold;
  final List<({double maxWidth, int columns})> breakpoints;
  final int maxColumns;

  int columnsForWidth(double width) {
    for (final b in breakpoints) {
      if (width < b.maxWidth) return b.columns;
    }
    return maxColumns;
  }

  /// Controlled width. Height stays dynamic.
  double cardWidth(double screenWidth) {
    final columns = columnsForWidth(screenWidth);
    final available = screenWidth - (padding * 2) - (gap * (columns - 1));
    if (available <= 0 || columns <= 0) return 0;
    return available / columns;
  }

  /// Image box height from stored width/height (width / height).
  double imageHeight(double cardWidth, double aspectRatio) {
    if (aspectRatio <= 0) return cardWidth;
    return cardWidth / aspectRatio;
  }
}
