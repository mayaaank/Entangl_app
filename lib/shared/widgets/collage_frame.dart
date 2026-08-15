import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/collage_layout.dart';
import '../../core/theme/entangl_colors.dart';

/// Renders a predefined collage from network URLs or local files.
class CollageFrame extends StatelessWidget {
  final CollageLayout layout;
  final List<String> urls;
  final List<File> files;
  final double? aspectRatio;
  final BorderRadius borderRadius;

  const CollageFrame({
    super.key,
    required this.layout,
    this.urls = const [],
    this.files = const [],
    this.aspectRatio,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  int get _count => files.isNotEmpty ? files.length : urls.length;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio ?? layout.aspectRatio,
        child: ColoredBox(
          color: palette.surfaceHigh,
          child: _layout(context),
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, int index) {
    final palette = context.palette;
    if (index >= _count) {
      return ColoredBox(color: palette.surfaceHigh);
    }
    if (files.isNotEmpty) {
      return Image.file(files[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => ColoredBox(color: palette.surfaceHigh),
      errorWidget: (_, __, ___) => ColoredBox(
        color: palette.surfaceHigh,
        child: Icon(Icons.broken_image_outlined, color: palette.outline),
      ),
    );
  }

  Widget _gap() => const SizedBox(width: 2, height: 2);

  Widget _layout(BuildContext context) {
    switch (layout) {
      case CollageLayout.split:
        return Row(
          children: [
            Expanded(child: _cell(context, 0)),
            _gap(),
            Expanded(child: _cell(context, 1)),
          ],
        );
      case CollageLayout.stack:
        return Column(
          children: [
            Expanded(child: _cell(context, 0)),
            _gap(),
            Expanded(child: _cell(context, 1)),
          ],
        );
      case CollageLayout.trioLeft:
        return Row(
          children: [
            Expanded(flex: 3, child: _cell(context, 0)),
            _gap(),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _cell(context, 1)),
                  _gap(),
                  Expanded(child: _cell(context, 2)),
                ],
              ),
            ),
          ],
        );
      case CollageLayout.trioTop:
        return Column(
          children: [
            Expanded(flex: 3, child: _cell(context, 0)),
            _gap(),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _cell(context, 1)),
                  _gap(),
                  Expanded(child: _cell(context, 2)),
                ],
              ),
            ),
          ],
        );
      case CollageLayout.quad:
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _cell(context, 0)),
                  _gap(),
                  Expanded(child: _cell(context, 1)),
                ],
              ),
            ),
            _gap(),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _cell(context, 2)),
                  _gap(),
                  Expanded(child: _cell(context, 3)),
                ],
              ),
            ),
          ],
        );
      case CollageLayout.featured:
        return Column(
          children: [
            Expanded(flex: 3, child: _cell(context, 0)),
            _gap(),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _cell(context, 1)),
                  _gap(),
                  Expanded(child: _cell(context, 2)),
                  _gap(),
                  Expanded(child: _cell(context, 3)),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class CollageLayoutPreview extends StatelessWidget {
  final CollageLayout layout;
  final bool selected;
  final VoidCallback onTap;

  const CollageLayoutPreview({
    super.key,
    required this.layout,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selected ? palette.navActive : palette.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: palette.onSurface,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: CustomPaint(
              painter: _LayoutPainter(
                layout: layout,
                color: palette.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            layout.label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _LayoutPainter extends CustomPainter {
  final CollageLayout layout;
  final Color color;
  _LayoutPainter({required this.layout, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.drawRRect(r, p);

    void line(double x1, double y1, double x2, double y2) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }

    switch (layout) {
      case CollageLayout.split:
        line(size.width / 2, 0, size.width / 2, size.height);
      case CollageLayout.stack:
        line(0, size.height / 2, size.width, size.height / 2);
      case CollageLayout.trioLeft:
        line(size.width * 0.58, 0, size.width * 0.58, size.height);
        line(size.width * 0.58, size.height / 2, size.width, size.height / 2);
      case CollageLayout.trioTop:
        line(0, size.height * 0.55, size.width, size.height * 0.55);
        line(size.width / 2, size.height * 0.55, size.width / 2, size.height);
      case CollageLayout.quad:
        line(size.width / 2, 0, size.width / 2, size.height);
        line(0, size.height / 2, size.width, size.height / 2);
      case CollageLayout.featured:
        line(0, size.height * 0.58, size.width, size.height * 0.58);
        line(size.width / 3, size.height * 0.58, size.width / 3, size.height);
        line(
          size.width * 2 / 3,
          size.height * 0.58,
          size.width * 2 / 3,
          size.height,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _LayoutPainter old) =>
      old.layout != layout || old.color != color;
}
