import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/presentation/map_marker_pin_color_mapper.dart';

void main() {
  group('MapMarkerPinColorMapper', () {
    const mapper = MapMarkerPinColorMapper(
      markerColor: Colors.red,
      iconBackgroundColor: Colors.blue,
    );

    test('maps marker body fills to marker color', () {
      expect(
        mapper.substitute('marker-head', 'circle', 'fill', Colors.black),
        Colors.red,
      );
      expect(
        mapper.substitute('marker-tail', 'path', 'fill', Colors.black),
        Colors.red,
      );
    });

    test('maps icon background to icon background color', () {
      expect(
        mapper.substitute('icon-background', 'circle', 'fill', Colors.white),
        Colors.blue,
      );
    });

    test('hides icon placeholder elements', () {
      expect(
        mapper.substitute(
          'icon-placeholder-label',
          'text',
          'fill',
          Colors.grey,
        ),
        Colors.transparent,
      );
    });
  });
}
