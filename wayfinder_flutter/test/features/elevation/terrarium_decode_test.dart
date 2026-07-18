import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wayfinder_flutter/features/elevation/utils/elevation_dem_detect.dart';
import 'package:wayfinder_flutter/features/elevation/utils/terrarium_decode.dart';

void main() {
  test('looksLikeElevationDemArchive matches common names', () {
    expect(looksLikeElevationDemArchive('virginia-terrarium.pmtiles'), isTrue);
    expect(looksLikeElevationDemArchive('midatlantic_dem.pmtiles'), isTrue);
    expect(looksLikeElevationDemArchive('terrain-rgb-east.pmtiles'), isTrue);
    expect(looksLikeElevationDemArchive('roads.pmtiles'), isFalse);
  });

  test('decodeTerrariumMeters matches Mapzen formula', () {
    // R=128, G=0, B=0 → 128*256 - 32768 = 0
    expect(decodeTerrariumMeters(128, 0, 0), closeTo(0, 1e-9));
    // 100 m: 128*256 + 100 - 32768 = 100
    expect(decodeTerrariumMeters(128, 100, 0), closeTo(100, 1e-9));
  });

  test('decodeDemTilePng samples terrarium PNG', () {
    final image = img.Image(width: 2, height: 2);
    // Encode ~50 m Terrarium: value = R*256 + G + B/256 - 32768
    // 50 = 128*256 + 50 + 0 - 32768
    for (var y = 0; y < 2; y++) {
      for (var x = 0; x < 2; x++) {
        image.setPixelRgba(x, y, 128, 50, 0, 255);
      }
    }
    final bytes = Uint8List.fromList(img.encodePng(image));
    final tile = decodeDemTilePng(bytes);
    expect(tile, isNotNull);
    expect(tile!.sample(0.5, 0.5), closeTo(50, 0.5));
  });
}
