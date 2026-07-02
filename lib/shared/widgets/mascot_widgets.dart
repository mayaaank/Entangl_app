import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum GhostExpression {
  waving,
  thumbsup,
  sad,
  floating,
  peeking,
  dancing,
}

enum FrogExpression {
  sitting,
  happy,
  sad,
  waving,
  jumping,
  confused,
}

class GhostMascot extends StatelessWidget {
  final GhostExpression expression;
  final double size;
  final bool animate;

  const GhostMascot({
    super.key,
    required this.expression,
    this.size = 80,
    this.animate = true,
  });

  String get _assetPath {
    switch (expression) {
      case GhostExpression.waving:
        return 'assets/mascots/ghost_waving.svg';
      case GhostExpression.thumbsup:
        return 'assets/mascots/ghost_thumbsup.svg';
      case GhostExpression.sad:
        return 'assets/mascots/ghost_sad.svg';
      case GhostExpression.floating:
        return 'assets/mascots/ghost_floating.svg';
      case GhostExpression.peeking:
        return 'assets/mascots/ghost_peeking.svg';
      case GhostExpression.dancing:
        return 'assets/mascots/ghost_dancing.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget svg = SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
    );

    if (!animate) return svg;

    switch (expression) {
      case GhostExpression.waving:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -4, duration: 800.ms, curve: Curves.easeInOut);
      case GhostExpression.floating:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -6, duration: 1200.ms, curve: Curves.easeInOut);
      case GhostExpression.dancing:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -2, duration: 600.ms, curve: Curves.easeInOut)
            .then()
            .scaleXY(begin: 1.0, end: 1.04, duration: 300.ms);
      case GhostExpression.peeking:
        return svg.animate()
            .moveY(begin: 20, end: 0, duration: 500.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 300.ms);
      case GhostExpression.thumbsup:
        return svg.animate()
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0),
                   duration: 350.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 150.ms);
      case GhostExpression.sad:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.97, end: 1.0, duration: 1500.ms, curve: Curves.easeInOut);
    }
  }
}

class FrogMascot extends StatelessWidget {
  final FrogExpression expression;
  final double size;
  final bool animate;

  const FrogMascot({
    super.key,
    required this.expression,
    this.size = 80,
    this.animate = true,
  });

  String get _assetPath {
    switch (expression) {
      case FrogExpression.sitting:
        return 'assets/mascots/frog_sitting.svg';
      case FrogExpression.happy:
        return 'assets/mascots/frog_happy.svg';
      case FrogExpression.sad:
        return 'assets/mascots/frog_sad.svg';
      case FrogExpression.waving:
        return 'assets/mascots/frog_waving.svg';
      case FrogExpression.jumping:
        return 'assets/mascots/frog_jumping.svg';
      case FrogExpression.confused:
        return 'assets/mascots/frog_confused.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget svg = SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
    );

    if (!animate) return svg;

    switch (expression) {
      case FrogExpression.sitting:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.98, end: 1.02, duration: 1200.ms, curve: Curves.easeInOut);
      case FrogExpression.happy:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.95, end: 1.05, duration: 400.ms, curve: Curves.easeInOut);
      case FrogExpression.jumping:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -8, duration: 500.ms, curve: Curves.easeInOut);
      case FrogExpression.confused:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: -0.04, end: 0.04, duration: 800.ms, curve: Curves.easeInOut);
      case FrogExpression.waving:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -3, duration: 700.ms, curve: Curves.easeInOut);
      case FrogExpression.sad:
        return svg.animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.96, end: 1.0, duration: 1500.ms, curve: Curves.easeInOut);
    }
  }
}
