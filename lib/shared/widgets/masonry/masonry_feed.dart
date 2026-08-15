import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/layout/masonry_config.dart';

/// Reusable waterfall. Placement is shortest-column (package + [MasonryEngine]).
/// Cards never set a fixed height — they receive [cardWidth] and reserve space.
class MasonryFeed<T> extends StatelessWidget {
  final List<T> items;
  final MasonryConfig config;
  final Widget Function(BuildContext context, T item, double cardWidth)
      itemBuilder;
  final bool hasMore;
  final VoidCallback? onPrefetch;
  final Future<void> Function()? onRefresh;
  final EdgeInsets? padding;
  final Widget? empty;
  final Widget? footer;

  const MasonryFeed({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.config = MasonryConfig.scraps,
    this.hasMore = false,
    this.onPrefetch,
    this.onRefresh,
    this.padding,
    this.empty,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final blank = empty ?? const SizedBox.shrink();
      if (onRefresh == null) return blank;
      return RefreshIndicator(onRefresh: onRefresh!, child: blank);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = config.columnsForWidth(width);
        final cardWidth = config.cardWidth(width);
        final insets = padding ??
            EdgeInsets.fromLTRB(
              config.padding,
              12,
              config.padding,
              140,
            );

        Widget grid = NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (onPrefetch == null || !hasMore) return false;
            if (n.metrics.maxScrollExtent <= 0) return false;
            final progress =
                n.metrics.pixels / n.metrics.maxScrollExtent;
            if (progress >= config.prefetchThreshold) onPrefetch!();
            return false;
          },
          child: MasonryGridView.count(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: insets,
            crossAxisCount: columns,
            mainAxisSpacing: config.gap,
            crossAxisSpacing: config.gap,
            cacheExtent: 800,
            itemCount: items.length + (footer != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (footer != null && index == items.length) return footer!;
              return itemBuilder(context, items[index], cardWidth);
            },
          ),
        );

        if (onRefresh != null) {
          grid = RefreshIndicator(
            onRefresh: onRefresh!,
            child: grid,
          );
        }
        return grid;
      },
    );
  }
}
