import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/utils/marker_qr_export.dart';
import 'package:wayfinder_flutter/features/markers/utils/marker_share_url.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sanitizeMarkerQrFileStem cleans names', () {
    expect(sanitizeMarkerQrFileStem('Camp Site!'), 'Camp_Site');
    expect(sanitizeMarkerQrFileStem('   '), 'marker');
  });

  test('buildMarkerQrUrl uses absolute web base on non-web', () {
    final marker = MapMarker(
      id: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      name: 'Home',
      latitude: 1,
      longitude: 2,
      elevation: 0,
      color: '#ff0000',
      icon: 'home',
      visible: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    expect(
      buildMarkerQrUrl(
        marker: marker,
        webBaseUrl: 'http://atlas.example.com:9080/',
      ),
      'http://atlas.example.com:9080/maps?marker=${marker.id}',
    );
  });

  test('buildMarkerQrSvg embeds favicon and modules', () async {
    // Minimal valid 1x1 PNG
    final png = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x02,
      0x00,
      0x00,
      0x00,
      0x90,
      0x77,
      0x53,
      0xDE,
      0x00,
      0x00,
      0x00,
      0x0C,
      0x49,
      0x44,
      0x41,
      0x54,
      0x08,
      0xD7,
      0x63,
      0xF8,
      0xCF,
      0xC0,
      0x00,
      0x00,
      0x00,
      0x03,
      0x00,
      0x01,
      0x00,
      0x05,
      0xFE,
      0xD4,
      0xEF,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);

    final svg = await buildMarkerQrSvg(
      data: 'http://example.com/maps?marker=test',
      faviconPngBytes: png,
      size: 256,
    );

    expect(svg, contains('<svg'));
    expect(svg, contains('data:image/png;base64,'));
    expect(svg, contains('<rect'));
    expect(svg, contains('fill="#000000"'));
  });
}
