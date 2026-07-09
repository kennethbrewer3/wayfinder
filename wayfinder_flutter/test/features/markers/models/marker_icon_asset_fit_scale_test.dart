import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_asset_fit_scale.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_asset_fit_scales.g.dart';
import 'package:wayfinder_flutter/features/markers/models/marker_icon_registry.dart';

void main() {
  test('every built-in icon has a bundled asset fit scale', () {
    for (final option in markerIconOptions) {
      expect(
        markerIconAssetFitScales.containsKey(option.key),
        isTrue,
        reason: option.key,
      );
      final scale = markerIconAssetFitScales[option.key]!;
      expect(scale, inInclusiveRange(0.5, 5.0), reason: option.key);
    }
  });

  test('markerIconDisplayScale combines user glyph scale with asset fit', () {
    expect(
      markerIconDisplayScale(iconName: 'horse', glyphScale: 1.0),
      bundledMarkerIconAssetFitScale('horse'),
    );
    expect(
      markerIconDisplayScale(iconName: 'custom_missing', glyphScale: 1.2),
      1.2,
    );
    expect(
      markerIconDisplayScale(iconName: 'my_location', glyphScale: 0.5),
      closeTo(0.5 * bundledMarkerIconAssetFitScale('my_location'), 0.001),
    );
  });
}
