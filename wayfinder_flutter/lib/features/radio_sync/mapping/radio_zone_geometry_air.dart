import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

import '../codec/radio_binary_io.dart';

/// Compact geometry kinds inside [ZoneUpsertLightEvent.geometryBytes].
abstract final class RadioZoneGeometryKind {
  static const int circle = 1;
  static const int polyline = 2; // line or open path
  static const int polygon = 3;
}

/// Air cap for line/polygon vertices (Phase F lock).
const radioZoneMaxAirPoints = 16;

/// Encode a circle for `ZoneUpsertLight`.
Uint8List encodeCircleGeometryAir({
  required int latE7,
  required int lonE7,
  required int radiusMeters,
}) {
  final w = RadioBinaryWriter(13)
    ..u8(RadioZoneGeometryKind.circle)
    ..i32(latE7)
    ..i32(lonE7)
    ..u32(radiusMeters.clamp(0, 0xffffffff));
  return w.toBytes();
}

/// Encode a polyline or polygon point list (≤ [radioZoneMaxAirPoints]).
Uint8List encodePointsGeometryAir({
  required int kind,
  required List<({int latE7, int lonE7})> points,
}) {
  if (kind != RadioZoneGeometryKind.polyline &&
      kind != RadioZoneGeometryKind.polygon) {
    throw ArgumentError('Invalid points geometry kind: $kind');
  }
  if (points.isEmpty || points.length > radioZoneMaxAirPoints) {
    throw ArgumentError(
      'Point count must be 1..$radioZoneMaxAirPoints, got ${points.length}',
    );
  }
  final w = RadioBinaryWriter(2 + points.length * 8)
    ..u8(kind)
    ..u8(points.length);
  for (final p in points) {
    w.i32(p.latE7);
    w.i32(p.lonE7);
  }
  return w.toBytes();
}

class DecodedCircleGeometryAir {
  const DecodedCircleGeometryAir({
    required this.latE7,
    required this.lonE7,
    required this.radiusMeters,
  });

  final int latE7;
  final int lonE7;
  final int radiusMeters;
}

class DecodedPointsGeometryAir {
  const DecodedPointsGeometryAir({
    required this.kind,
    required this.points,
  });

  final int kind;
  final List<({int latE7, int lonE7})> points;
}

DecodedCircleGeometryAir? decodeCircleGeometryAir(List<int> bytes) {
  final decoded = decodeZoneGeometryAir(bytes);
  return decoded is DecodedCircleGeometryAir ? decoded : null;
}

/// Decode light-zone geometry bytes (circle or point list).
Object? decodeZoneGeometryAir(List<int> bytes) {
  if (bytes.isEmpty) {
    return null;
  }
  try {
    final r = RadioBinaryReader(Uint8List.fromList(bytes));
    final kind = r.u8();
    switch (kind) {
      case RadioZoneGeometryKind.circle:
        return DecodedCircleGeometryAir(
          latE7: r.i32(),
          lonE7: r.i32(),
          radiusMeters: r.u32(),
        );
      case RadioZoneGeometryKind.polyline:
      case RadioZoneGeometryKind.polygon:
        final count = r.u8();
        if (count == 0 || count > radioZoneMaxAirPoints) {
          return null;
        }
        final points = <({int latE7, int lonE7})>[];
        for (var i = 0; i < count; i++) {
          points.add((latE7: r.i32(), lonE7: r.i32()));
        }
        return DecodedPointsGeometryAir(kind: kind, points: points);
      default:
        return null;
    }
  } on FormatException {
    return null;
  }
}

List<({int latE7, int lonE7})> latLngsToAirPoints(List<LatLng> points) {
  final capped = points.length > radioZoneMaxAirPoints
      ? points.sublist(0, radioZoneMaxAirPoints)
      : points;
  return [
    for (final p in capped)
      (latE7: (p.latitude * 1e7).round(), lonE7: (p.longitude * 1e7).round()),
  ];
}

List<LatLng> airPointsToLatLngs(List<({int latE7, int lonE7})> points) => [
  for (final p in points) LatLng(p.latE7 / 1e7, p.lonE7 / 1e7),
];

/// Wire codes for [MapZone.type] in light zone events.
abstract final class RadioZoneTypeAir {
  static const int unknown = 0;
  static const int circle = 1;
  static const int line = 2;
  static const int polygon = 3;
  static const int rectangle = 4;
  static const int track = 5;

  static int fromZoneType(String type) => switch (type) {
    'circle' => circle,
    'line' => line,
    'polygon' => polygon,
    'rectangle' => rectangle,
    'track' => track,
    _ => unknown,
  };

  static String toZoneType(int code) => switch (code) {
    circle => 'circle',
    line => 'line',
    polygon => 'polygon',
    rectangle => 'rectangle',
    track => 'track',
    _ => 'circle',
  };
}
