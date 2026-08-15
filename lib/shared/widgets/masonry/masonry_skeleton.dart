import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/layout/masonry_config.dart';
import '../../../core/theme/entangl_colors.dart';

class MasonrySkeleton extends StatelessWidget {
  final MasonryConfig config;
  const MasonrySkeleton({super.key, this.config = MasonryConfig.scraps});

  static const _ratios = [0.8, 1.15, 1.0, 0.72, 1.3, 0.9];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = config.columnsForWidth(constraints.maxWidth);
        final cardWidth = config.cardWidth(constraints.maxWidth);
        return MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(config.padding, 12, config.padding, 24),
          crossAxisCount: columns,
          mainAxisSpacing: config.gap,
          crossAxisSpacing: config.gap,
          itemCount: _ratios.length,
          itemBuilder: (_, i) {
            final h = cardWidth / _ratios[i];
            return Container(
              height: h,
              decoration: BoxDecoration(
                color: palette.surfaceHigh,
                borderRadius: BorderRadius.circular(config.cardRadius),
              ),
            );
          },
        );
      },
    );
  }
}
