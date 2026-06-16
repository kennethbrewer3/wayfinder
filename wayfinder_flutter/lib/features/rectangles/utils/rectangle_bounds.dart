import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_distance.dart';

class RectangleBounds {
  const RectangleBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  final double north;
  final double south;
  final double east;
  final double west;

  bool get isValid {
    if (north <= south || east <= west) {
      return false;
    }
    final nw = LatLng(north, west);
    final ne = LatLng(north, east);
    final sw = LatLng(south, west);
    return lineLengthMeters(nw, ne) >= 1 && lineLengthMeters(nw, sw) >= 1;
  }

  LatLng get center => LatLng(
        (north + south) / 2,
        (east + west) / 2,
      );

  Map<String, dynamic> toJson() {
    return {
      'north': north,
      'south': south,
      'east': east,
      'west': west,
    };
  }

  static RectangleBounds? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final north = value['north'];
    final south = value['south'];
    final east = value['east'];
    final west = value['west'];
    if (north is! num ||
        south is! num ||
        east is! num ||
        west is! num) {
      return null;
    }
    return RectangleBounds(
      north: north.toDouble(),
      south: south.toDouble(),
      east: east.toDouble(),
      west: west.toDouble(),
    );
  }
}

RectangleBounds boundsFromCenterExtent(LatLng center, LatLng extentPoint) {
  final latDelta = (extentPoint.latitude - center.latitude).abs();
  final lngDelta = (extentPoint.longitude - center.longitude).abs();
  return RectangleBounds(
    north: center.latitude + latDelta,
    south: center.latitude - latDelta,
    east: center.longitude + lngDelta,
    west: center.longitude - lngDelta,
  );
}

RectangleBounds boundsFromCorners(LatLng cornerA, LatLng cornerB) {
  return RectangleBounds(
    north: math.max(cornerA.latitude, cornerB.latitude),
    south: math.min(cornerA.latitude, cornerB.latitude),
    east: math.max(cornerA.longitude, cornerB.longitude),
    west: math.min(cornerA.longitude, cornerB.longitude),
  );
}

List<LatLng> rectanglePolygonPoints(RectangleBounds bounds) {
  return [
    LatLng(bounds.north, bounds.west),
    LatLng(bounds.north, bounds.east),
    LatLng(bounds.south, bounds.east),
    LatLng(bounds.south, bounds.west),
  ];
}

LatLng? parseLatLng(Object? value) {
  if (value is! Map) {
    return null;
  }
  final lat = value['lat'];
  final lng = value['lng'];
  if (lat is! num || lng is! num) {
    return null;
  }
  return LatLng(lat.toDouble(), lng.toDouble());
}

Map<String, dynamic> latLngToJson(LatLng point) {
  return {
    'lat': point.latitude,
    'lng': point.longitude,
  };
}
