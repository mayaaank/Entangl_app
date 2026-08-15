import 'package:entangl_app/core/layout/media_dimensions.dart';
import 'package:entangl_app/core/layout/text_layout_calculator.dart';
import 'package:entangl_app/core/theme/collage_layout.dart';
import 'package:entangl_app/data/models/post_model.dart';
import 'package:entangl_app/domain/scrap/scrap_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScrapContent.fromStored', () {
    test('maps a photo url with stored pixels to PhotoContent', () {
      final content = ScrapContent.fromStored(
        text: 'caption',
        imageUrl: 'https://cdn/u/1_portrait_w1200_h1600.jpg',
      );
      expect(content, isA<PhotoContent>());
      final photo = content as PhotoContent;
      expect(photo.url, contains('w1200_h1600'));
      expect(photo.dimensions.width, 1200);
      expect(photo.dimensions.height, 1600);
      expect(photo.hasStoredSize, isTrue);
      expect(photo.aspectRatio, closeTo(0.75, 0.001));
    });

    test('maps collage json to CollageContent', () {
      final content = ScrapContent.fromStored(
        text: 'board',
        imageUrl:
            '{"kind":"collage","layout":"trioLeft","urls":["a","b","c"]}',
      );
      expect(content, isA<CollageContent>());
      final collage = content as CollageContent;
      expect(collage.layout, CollageLayout.trioLeft);
      expect(collage.urls, ['a', 'b', 'c']);
    });

    test('maps text-only rows to TextContent', () {
      final content = ScrapContent.fromStored(text: 'hello scrap');
      expect(content, isA<TextContent>());
      expect((content as TextContent).text, 'hello scrap');
    });
  });

  group('content height contract', () {
    test('photo height uses stored pixels, not a format frame', () {
      const photo = PhotoContent(
        url: 'https://cdn/x.jpg',
        dimensions: MediaDimensions(width: 1200, height: 1600),
      );
      expect(photo.heightFor(175), closeTo(175 / 0.75, 0.01));
    });

    test('collage height uses layout aspect ratio', () {
      const collage = CollageContent(
        layout: CollageLayout.quad,
        urls: ['a', 'b', 'c', 'd'],
      );
      expect(collage.heightFor(175), closeTo(175, 0.01));
    });

    test('text height clamps to the shared calculator', () {
      expect(
        const TextContent('Hi').heightFor(175),
        greaterThanOrEqualTo(TextLayoutCalculator.minHeight),
      );
      expect(
        TextContent('x' * 500).heightFor(175),
        lessThanOrEqualTo(TextLayoutCalculator.maxHeight),
      );
    });
  });

  group('PostModel', () {
    test('fromJson stores caption only on media scraps', () {
      final photo = PostModel.fromJson({
        'id': '1',
        'user_id': 'u',
        'content': 'a note',
        'image_url': 'https://cdn/u/1_square_w1080_h1080.jpg',
        'created_at': '',
      });
      expect(photo.content, isA<PhotoContent>());
      expect(photo.caption, 'a note');

      final text = PostModel.fromJson({
        'id': '2',
        'user_id': 'u',
        'content': 'just words',
        'image_url': null,
        'created_at': '',
      });
      expect(text.content, isA<TextContent>());
      expect(text.caption, isEmpty);
    });
  });
}
