import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum DoodleType {
  star,
  lightning,
  heart,
  sparkle,
}

class DoodleWidget extends StatelessWidget {
  final DoodleType type;
  final double size;
  final double opacity;
  final bool animate;

  const DoodleWidget({
    super.key,
    required this.type,
    this.size = 24,
    this.opacity = 0.5,
    this.animate = false,
  });

  String get _assetPath {
    switch (type) {
      case DoodleType.star:
        return 'assets/icons/doodles/doodle_star.svg';
      case DoodleType.lightning:
        return 'assets/icons/doodles/doodle_lightning.svg';
      case DoodleType.heart:
        return 'assets/icons/doodles/doodle_heart.svg';
      case DoodleType.sparkle:
        return 'assets/icons/doodles/doodle_sparkle.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget svg = Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        _assetPath,
        width: size,
        height: size,
      ),
    );

    if (!animate) return svg;

    switch (type) {
      case DoodleType.star:
      case DoodleType.sparkle:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1),
                   duration: 1000.ms, curve: Curves.easeInOut)
            .rotate(begin: -0.05, end: 0.05, duration: 1200.ms, curve: Curves.easeInOut);
      case DoodleType.lightning:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -3, duration: 800.ms, curve: Curves.easeInOut);
      case DoodleType.heart:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05),
                   duration: 600.ms, curve: Curves.easeInOut);
    }
  }
}
