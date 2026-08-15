import 'masonry_config.dart';

class MasonryColumn<T> {
  MasonryColumn();
  final List<T> items = [];
  double height = 0;
}

/// Shortest-column waterfall. Content-agnostic: callers supply [heightOf].
class MasonryEngine {
  const MasonryEngine({this.config = MasonryConfig.scraps});

  final MasonryConfig config;

  List<MasonryColumn<T>> place<T>({
    required List<T> items,
    required int columns,
    required double Function(T item) heightOf,
  }) {
    final cols = List<MasonryColumn<T>>.generate(
      columns.clamp(1, 12),
      (_) => MasonryColumn<T>(),
    );
    for (final item in items) {
      var shortest = cols.first;
      for (final col in cols) {
        if (col.height < shortest.height) shortest = col;
      }
      shortest.items.add(item);
      shortest.height += heightOf(item) + config.gap;
    }
    return cols;
  }
}
