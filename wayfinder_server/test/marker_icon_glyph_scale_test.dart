import 'package:test/test.dart';

import 'package:wayfinder_server/src/markers/marker_icon_glyph_scale.dart';

void main() {
  group('parseMarkerIconGlyphScale', () {
    test('accepts values within range', () {
      expect(parseMarkerIconGlyphScale(0.5), 0.5);
      expect(parseMarkerIconGlyphScale(1.0), 1.0);
      expect(parseMarkerIconGlyphScale(5.0), 5.0);
    });

    test('rejects out-of-range values', () {
      expect(
        () => parseMarkerIconGlyphScale(0.4),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => parseMarkerIconGlyphScale(5.1),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
