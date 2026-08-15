import 'package:entangl_app/core/layout/masonry_config.dart';
import 'package:entangl_app/core/layout/masonry_engine.dart';
import 'package:entangl_app/core/layout/media_metrics.dart';
import 'package:entangl_app/core/theme/post_format.dart';
import 'package:entangl_app/domain/scrap/scrap_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = MasonryConfig.scraps;
  const engine = MasonryEngine();

  group('MasonryConfig', () {
    test('picks column count from width', () {
      expect(config.columnsForWidth(390), 2);
      expect(config.columnsForWidth(700), 3);
      expect(config.columnsForWidth(1000), 4);
      expect(config.columnsForWidth(1400), 5);
    });

    test('computes controlled card width', () {
      // 390 - 16 - 16 - 8 = 350 / 2 = 175
      expect(config.cardWidth(390), 175);
    });

    test('image height follows stored aspect', () {
      expect(config.imageHeight(175, 0.8), closeTo(218.75, 0.01));
      expect(config.imageHeight(175, 1), 175);
    });
  });

  group('MasonryEngine', () {
    test('places the next card in the shortest column', () {
      final cols = engine.place<int>(
        items: [1, 2, 3],
        columns: 2,
        heightOf: (i) => i == 1 ? 200 : 80,
      );
      expect(cols[0].items, [1]);
      expect(cols[1].items, [2, 3]);
    });

    test('asks each item for height and stays content-agnostic', () {
      final scraps = <ScrapContent>[
        ScrapContent.fromStored(
          text: '',
          imageUrl: 'https://cdn/x_w1200_h1600.jpg',
        ),
        const TextContent('Hi'),
      ];
      final cols = engine.place<ScrapContent>(
        items: scraps,
        columns: 2,
        heightOf: (item) => item.heightFor(175),
      );
      expect(cols[0].items.single, isA<PhotoContent>());
      expect(cols[1].items.single, isA<TextContent>());
      expect(cols[0].height, closeTo(175 / 0.75 + config.gap, 0.01));
    });
  });

  group('MediaMetrics', () {
    test('encodes and parses original pixels from the path', () {
      final name = MediaMetrics.fileName(
        uid: 'u1',
        formatKey: 'portrait',
        ext: 'jpg',
        width: 1080,
        height: 1350,
      );
      expect(name, contains('_w1080_h1350'));
      expect(MediaMetrics.parse(name)?.width, 1080);
      expect(MediaMetrics.parse(name)?.height, 1350);
      expect(MediaMetrics.aspectRatio(name), closeTo(0.8, 0.001));
    });
  });

  group('PostFormat', () {
    test('still classifies compose frames', () {
      expect(PostFormat.fromPixelSize(1200, 1600), PostFormat.portrait);
    });
  });
}
