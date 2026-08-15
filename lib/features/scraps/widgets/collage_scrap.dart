import 'package:flutter/material.dart';
import '../../../domain/scrap/scrap_content.dart';
import '../../../shared/widgets/collage_frame.dart';

class CollageScrap extends StatelessWidget {
  final CollageContent content;

  const CollageScrap({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: content.aspectRatio,
      child: CollageFrame(
        layout: content.layout,
        urls: content.urls,
        borderRadius: BorderRadius.zero,
        aspectRatio: content.aspectRatio,
      ),
    );
  }
}
