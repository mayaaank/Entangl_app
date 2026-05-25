import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class AvatarViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const AvatarViewerScreen({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  static void show(
    BuildContext context, {
    required String imageUrl,
    required String heroTag,
  }) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => AvatarViewerScreen(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  State<AvatarViewerScreen> createState() => _AvatarViewerScreenState();
}

class _AvatarViewerScreenState extends State<AvatarViewerScreen>
    with SingleTickerProviderStateMixin {
  final _transformController = TransformationController();
  late AnimationController _resetCtrl;
  Animation<Matrix4>? _resetAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_resetAnimation != null) {
          _transformController.value = _resetAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformController.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    if (_isZoomed) {
      _resetAnimation = Matrix4Tween(
        begin: _transformController.value,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(parent: _resetCtrl, curve: Curves.easeOut));
      _resetCtrl.forward(from: 0);
      setState(() => _isZoomed = false);
    } else {
      final pos = details.localPosition;
      final x = -pos.dx * 1.5;
      final y = -pos.dy * 1.5;
      final zoomed = Matrix4.identity()
        ..translate(x, y)
        ..scale(2.5);
      _resetAnimation = Matrix4Tween(
        begin: _transformController.value,
        end: zoomed,
      ).animate(CurvedAnimation(parent: _resetCtrl, curve: Curves.easeOut));
      _resetCtrl.forward(from: 0);
      setState(() => _isZoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {},
        onTap: _isZoomed ? null : () => Navigator.of(context).pop(),
        child: SizedBox.expand(
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.8,
            maxScale: 5.0,
            onInteractionEnd: (details) {
              final scale =
                  _transformController.value.getMaxScaleOnAxis();
              setState(() => _isZoomed = scale > 1.05);
            },
            child: Center(
              child: Hero(
                tag: widget.heroTag,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.person_rounded,
                    color: Colors.white38,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}