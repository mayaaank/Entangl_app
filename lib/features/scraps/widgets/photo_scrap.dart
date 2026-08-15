import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/entangl_colors.dart';
import '../../../domain/scrap/scrap_content.dart';

class PhotoScrap extends StatefulWidget {
  final PhotoContent content;
  final bool liked;

  const PhotoScrap({
    super.key,
    required this.content,
    this.liked = false,
  });

  @override
  State<PhotoScrap> createState() => _PhotoScrapState();
}

class _PhotoScrapState extends State<PhotoScrap> {
  late double _aspect;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _aspect = widget.content.aspectRatio;
    if (!widget.content.hasStoredSize) _listenForPixels();
  }

  @override
  void didUpdateWidget(covariant PhotoScrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.url != widget.content.url) {
      _detach();
      _aspect = widget.content.aspectRatio;
      if (!widget.content.hasStoredSize) _listenForPixels();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _listenForPixels() {
    final stream = CachedNetworkImageProvider(widget.content.url)
        .resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      _detach();
      final w = info.image.width;
      final h = info.image.height;
      if (!mounted || w <= 0 || h <= 0) return;
      final next = w / h;
      if ((next - _aspect).abs() < 0.001) return;
      setState(() => _aspect = next);
    }, onError: (_, __) => _detach());
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  void _detach() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _stream = null;
    _listener = null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AspectRatio(
      aspectRatio: _aspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: palette.surfaceHigh),
          CachedNetworkImage(
            imageUrl: widget.content.url,
            width: double.infinity,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 180),
            placeholder: (_, __) => ColoredBox(color: palette.surfaceHigh),
            errorWidget: (_, __, ___) => Icon(
              Icons.broken_image_outlined,
              color: palette.outline,
            ),
          ),
          if (widget.liked)
            const Positioned(
              right: 8,
              bottom: 8,
              child: Icon(Icons.favorite_rounded, size: 16),
            ),
        ],
      ),
    );
  }
}
