import 'package:entangl_app/core/theme/collage_layout.dart';
import 'package:entangl_app/core/theme/post_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostFormat', () {
    test('encodes and reads four universal sizes from image urls', () {
      expect(PostFormat.fromImageUrl(null), PostFormat.text);
      expect(PostFormat.fromImageUrl(''), PostFormat.text);
      expect(
        PostFormat.fromImageUrl('https://cdn/x/1_square.jpg'),
        PostFormat.square,
      );
      expect(
        PostFormat.fromImageUrl('https://cdn/x/1_portrait.jpg'),
        PostFormat.portrait,
      );
      expect(
        PostFormat.fromImageUrl('https://cdn/x/1_landscape.png'),
        PostFormat.landscape,
      );
      expect(
        PostFormat.fromImageUrl('https://cdn/x/legacy.jpg'),
        PostFormat.square,
      );
    });

    test('snaps pixel sizes to the nearest media format', () {
      expect(PostFormat.fromPixelSize(1080, 1080), PostFormat.square);
      expect(PostFormat.fromPixelSize(1080, 1350), PostFormat.portrait);
      expect(PostFormat.fromPixelSize(1920, 1080), PostFormat.landscape);
    });

    test('detects collage payloads', () {
      expect(
        PostFormat.fromImageUrl(
          '{"kind":"collage","layout":"quad","urls":["a"]}',
        ),
        PostFormat.collage,
      );
      final payload = CollagePayload.tryParse(
        '{"kind":"collage","layout":"trioLeft","urls":["a","b","c"]}',
      );
      expect(payload?.layout, CollageLayout.trioLeft);
      expect(payload?.urls, ['a', 'b', 'c']);
    });

    test('aspect ratios are the four universal frames', () {
      expect(PostFormat.square.aspectRatio, 1);
      expect(PostFormat.portrait.aspectRatio, closeTo(0.8, 0.001));
      expect(PostFormat.landscape.aspectRatio, closeTo(16 / 9, 0.001));
    });
  });
}
