import 'package:flutter/material.dart';
import '../../../domain/scrap/scrap_content.dart';
import 'collage_scrap.dart';
import 'photo_scrap.dart';
import 'text_scrap.dart';

/// Maps [ScrapContent] to a widget. The only exhaustive content switch in UI.
class ScrapContentView extends StatelessWidget {
  final ScrapContent content;
  final double width;
  final bool liked;

  const ScrapContentView({
    super.key,
    required this.content,
    required this.width,
    this.liked = false,
  });

  @override
  Widget build(BuildContext context) {
    return switch (content) {
      PhotoContent photo => PhotoScrap(
          content: photo,
          liked: liked,
        ),
      TextContent text => TextScrap(
          content: text,
          width: width,
        ),
      CollageContent collage => CollageScrap(content: collage),
    };
  }
}
