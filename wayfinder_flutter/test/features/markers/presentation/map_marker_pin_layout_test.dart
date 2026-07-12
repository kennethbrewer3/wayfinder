import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/presentation/map_marker_pin_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parseMapMarkerPinLayout reads icon slot from SVG ids', () {
    const svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 44 44">
  <circle id="icon-background" cx="22" cy="16" r="11.84" fill="#FFFFFF"/>
  <circle id="icon-placeholder-glyph" cx="22" cy="16" r="10.656"/>
</svg>
''';

    final layout = parseMapMarkerPinLayout(svg);

    expect(layout.viewBoxWidth, 44);
    expect(layout.viewBoxHeight, 44);
    expect(layout.iconCenterX, 22);
    expect(layout.iconCenterY, 16);
    expect(layout.iconSlotRadius, 11.84);
    expect(layout.iconGlyphRadius, 10.656);

    final slot = layout.iconSlotRect(44, 44);
    expect(slot.width, closeTo(23.68, 0.01));
    expect(slot.height, closeTo(23.68, 0.01));
    expect(slot.left, closeTo(10.16, 0.01));
    expect(slot.top, closeTo(4.16, 0.01));
    expect(layout.iconGlyphSize(44, 44), closeTo(21.312, 0.01));
  });

  test(
    'parseMapMarkerPinLayout derives glyph radius from slot when placeholder missing',
    () {
      const svg = '''
<svg viewBox="0 0 44 44">
  <circle id="icon-background" cx="24" cy="18" r="13" fill="#FFFFFF"/>
</svg>
''';

      final layout = parseMapMarkerPinLayout(svg);

      expect(layout.iconCenterX, 24);
      expect(layout.iconCenterY, 18);
      expect(layout.iconSlotRadius, 13);
      expect(layout.iconGlyphRadius, closeTo(13 * 0.9, 0.001));

      final slot = layout.iconSlotRect(44, 44);
      expect(slot.left, closeTo(11, 0.01));
      expect(slot.top, closeTo(5, 0.01));
      expect(slot.width, closeTo(26, 0.01));
    },
  );

  test('parseMapMarkerPinLayout reads bundled marker_pin.svg asset', () async {
    final svg = await rootBundle.loadString('assets/markers/marker_pin.svg');
    final layout = parseMapMarkerPinLayout(svg);

    expect(layout.iconSlotRadius, 11.84);
    expect(layout.iconGlyphRadius, 10.656);
  });
}
