import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// In-memory cache of resolved width/height ratios so feed scroll
/// does not re-decode headers for every rebuild.
final Map<String, double> _aspectCache = {};

/// Displays a post image at its **natural aspect ratio**.
///
/// - Landscape stays wide and short
/// - Portrait stays tall (clamped so it never dominates the feed)
/// - Square stays square
/// - Uses [BoxFit.contain] so nothing is cropped awkwardly
///
/// Clamps ratio (width/height) to [minAspect]…[maxAspect]:
/// - min 0.72 ≈ tall 4:5.5 portrait
/// - max 2.2  ≈ very wide panorama
class DynamicPostImage extends StatefulWidget {
  final String? networkUrl;
  final File? file;
  final BorderRadius borderRadius;
  final double minAspect;
  final double maxAspect;
  final double placeholderAspect;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const DynamicPostImage({
    super.key,
    this.networkUrl,
    this.file,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.minAspect = 0.72,
    this.maxAspect = 2.2,
    this.placeholderAspect = 4 / 3,
    this.border,
    this.onTap,
  }) : assert(
          networkUrl != null || file != null,
          'Provide networkUrl or file',
        );

  @override
  State<DynamicPostImage> createState() => _DynamicPostImageState();
}

class _DynamicPostImageState extends State<DynamicPostImage> {
  double? _aspect;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  String get _cacheKey =>
      widget.file?.path ?? widget.networkUrl ?? 'unknown';

  @override
  void initState() {
    super.initState();
    final cached = _aspectCache[_cacheKey];
    if (cached != null) {
      _aspect = cached;
    } else {
      _resolveAspect();
    }
  }

  @override
  void didUpdateWidget(covariant DynamicPostImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKey = oldWidget.file?.path ?? oldWidget.networkUrl;
    if (oldKey != _cacheKey) {
      _detach();
      final cached = _aspectCache[_cacheKey];
      if (cached != null) {
        _aspect = cached;
      } else {
        _aspect = null;
        _resolveAspect();
      }
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _detach() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _resolveAspect() {
    final ImageProvider provider;
    if (widget.file != null) {
      provider = FileImage(widget.file!);
    } else {
      provider = CachedNetworkImageProvider(widget.networkUrl!);
    }

    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (w <= 0 || h <= 0) return;
        final raw = w / h;
        final clamped = raw.clamp(widget.minAspect, widget.maxAspect);
        _aspectCache[_cacheKey] = clamped;
        if (mounted && _aspect != clamped) {
          setState(() => _aspect = clamped);
        }
        stream.removeListener(listener);
      },
      onError: (_, __) {
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspect ?? widget.placeholderAspect;

    Widget image;
    if (widget.file != null) {
      image = Image.file(
        widget.file!,
        width: double.infinity,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _errorBox(),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: widget.networkUrl!,
        width: double.infinity,
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 220),
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: 1080,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _errorBox(),
      );
    }

    // Soft paper fill behind letterboxing when clamped ratio differs
    // slightly from true pixels (e.g. ultra-wide capped to maxAspect).
    final framed = ColoredBox(
      color: AppColors.paperGrid,
      child: image,
    );

    final child = AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: aspect,
        child: framed,
      ),
    );

    final decorated = Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: widget.border,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    if (widget.onTap == null) return decorated;
    return GestureDetector(onTap: widget.onTap, child: decorated);
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.inkWarm,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.cream100,
        ),
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      color: AppColors.inkWarm,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textTertiary,
        size: 32,
      ),
    );
  }
}

/// Local file preview for create-post — same natural sizing rules.
class DynamicFileImage extends StatelessWidget {
  final File file;
  final BorderRadius borderRadius;
  final VoidCallback? onClear;

  const DynamicFileImage({
    super.key,
    required this.file,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DynamicPostImage(
          file: file,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.borderCard, width: 1.5),
          placeholderAspect: 4 / 3,
        ),
        if (onClear != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.inkMid,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderCard,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
