import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../polygons/models/polygon_geometry.dart';
import '../../polygons/utils/polygon_hit_test.dart';
import '../providers/seasonal_overlays_provider.dart';

UuidValue? hitTestSeasonalOverlayAtPoint({
  required LatLng point,
  required List<SeasonalOverlay> overlays,
  required MapCamera camera,
  required bool showInactive,
  DateTime? on,
}) {
  final tapScreen = camera.latLngToScreenOffset(point);
  UuidValue? hitId;
  var smallestArea = double.infinity;

  for (final overlay in overlays) {
    if (!shouldRenderSeasonalOverlay(
      overlay: overlay,
      showInactive: showInactive,
      on: on,
    )) {
      continue;
    }
    final geometry = PolygonGeometry.fromJsonString(overlay.geometryJson);
    if (geometry == null || !geometry.isValid) {
      continue;
    }

    final polygon = geometry.points
        .map(camera.latLngToScreenOffset)
        .toList(growable: false);
    if (!pointInPolygonScreen(tapScreen, polygon)) {
      continue;
    }

    final area = polygonAreaProxy(geometry.points);
    if (area < smallestArea) {
      smallestArea = area;
      hitId = overlay.id;
    }
  }

  return hitId;
}
