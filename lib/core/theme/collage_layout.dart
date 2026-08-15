import 'dart:convert';

/// Predefined Instagram-style collage frames. Slot count is 2–4.
enum CollageLayout {
  split,
  stack,
  trioLeft,
  trioTop,
  quad,
  featured;

  String get label {
    switch (this) {
      case CollageLayout.split:
        return 'Split';
      case CollageLayout.stack:
        return 'Stack';
      case CollageLayout.trioLeft:
        return 'Trio';
      case CollageLayout.trioTop:
        return 'Banner';
      case CollageLayout.quad:
        return 'Grid';
      case CollageLayout.featured:
        return 'Featured';
    }
  }

  int get slotCount {
    switch (this) {
      case CollageLayout.split:
      case CollageLayout.stack:
        return 2;
      case CollageLayout.trioLeft:
      case CollageLayout.trioTop:
        return 3;
      case CollageLayout.quad:
      case CollageLayout.featured:
        return 4;
    }
  }

  double get aspectRatio {
    switch (this) {
      case CollageLayout.split:
      case CollageLayout.stack:
      case CollageLayout.trioTop:
      case CollageLayout.featured:
        return 4 / 5;
      case CollageLayout.trioLeft:
      case CollageLayout.quad:
        return 1;
    }
  }

  static CollageLayout fromName(String? name) {
    return CollageLayout.values.firstWhere(
      (l) => l.name == name,
      orElse: () => CollageLayout.quad,
    );
  }
}

class CollagePayload {
  final CollageLayout layout;
  final List<String> urls;

  const CollagePayload({required this.layout, required this.urls});

  Map<String, dynamic> toJson() => {
        'kind': 'collage',
        'layout': layout.name,
        'urls': urls,
      };

  String encode() => jsonEncode(toJson());

  static CollagePayload? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final trimmed = raw.trim();
    if (!trimmed.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return null;
      if (decoded['kind'] != 'collage') return null;
      final urls = (decoded['urls'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const <String>[];
      if (urls.isEmpty) return null;
      return CollagePayload(
        layout: CollageLayout.fromName(decoded['layout'] as String?),
        urls: urls,
      );
    } catch (_) {
      return null;
    }
  }
}
