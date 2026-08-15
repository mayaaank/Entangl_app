/// Four universal post sizes used everywhere a post is composed or shown.
enum PostFormat {
  square,
  portrait,
  landscape,
  text,
  collage;

  String get storageKey => name;

  String get label {
    switch (this) {
      case PostFormat.square:
        return 'Square';
      case PostFormat.portrait:
        return 'Portrait';
      case PostFormat.landscape:
        return 'Wide';
      case PostFormat.text:
        return 'Text';
      case PostFormat.collage:
        return 'Collage';
    }
  }

  /// Width / height for media frames.
  double get aspectRatio {
    switch (this) {
      case PostFormat.square:
        return 1;
      case PostFormat.portrait:
        return 4 / 5;
      case PostFormat.landscape:
        return 16 / 9;
      case PostFormat.text:
        return 1;
      case PostFormat.collage:
        return 1;
    }
  }

  bool get isMedia => this != PostFormat.text;

  static const mediaFormats = [
    PostFormat.square,
    PostFormat.portrait,
    PostFormat.landscape,
  ];

  static PostFormat fromImageUrl(String? url) {
    if (url == null || url.isEmpty) return PostFormat.text;
    if (url.trim().startsWith('{') && url.contains('collage')) {
      return PostFormat.collage;
    }
    final path = Uri.tryParse(url)?.path ?? url;
    if (path.contains('_portrait.')) return PostFormat.portrait;
    if (path.contains('_landscape.')) return PostFormat.landscape;
    if (path.contains('_collage.')) return PostFormat.collage;
    if (path.contains('_square.')) return PostFormat.square;
    return PostFormat.square;
  }

  static PostFormat fromPixelSize(int width, int height) {
    if (width <= 0 || height <= 0) return PostFormat.square;
    final ratio = width / height;
    const square = 1.0;
    const portrait = 4 / 5;
    const landscape = 16 / 9;
    final dSquare = (ratio - square).abs();
    final dPortrait = (ratio - portrait).abs();
    final dLandscape = (ratio - landscape).abs();
    if (dLandscape <= dSquare && dLandscape <= dPortrait) {
      return PostFormat.landscape;
    }
    if (dPortrait <= dSquare) return PostFormat.portrait;
    return PostFormat.square;
  }
}
