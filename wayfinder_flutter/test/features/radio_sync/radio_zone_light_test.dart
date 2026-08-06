import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/circles/models/circle_geometry.dart';
import 'package:wayfinder_flutter/features/lines/models/line_geometry.dart';
import 'package:wayfinder_flutter/features/polygons/models/polygon_geometry.dart';
import 'package:wayfinder_flutter/features/radio_sync/radio_sync.dart';

void main() {
  const mapper = RadioEntityMapper();
  const codec = RadioEventCodec();
  final now = DateTime.utc(2026, 8, 6);

  test('line ZoneUpsertLight round-trips via codec', () {
    final geometry = LineGeometry(
      points: const [
        LatLng(35.0, -106.0),
        LatLng(35.1, -106.1),
        LatLng(35.2, -106.0),
      ],
      showArrows: true,
    );
    final zone = MapZone(
      id: const Uuid().v4obj(),
      name: 'Ridge line',
      type: lineZoneType,
      color: '#112233',
      borderColor: '#112233',
      borderPattern: 'solid',
      fillColor: '#112233',
      visible: true,
      geometryJson: geometry.encode(),
      createdAt: now,
      updatedAt: now,
    );
    final event = mapper.zoneUpsertLightFrom(zone)! as ZoneUpsertLightEvent;
    final decoded = codec.decode(codec.encode(event)) as ZoneUpsertLightEvent;
    final rebuilt = mapper.zoneFromUpsertLight(decoded)!;
    final line = LineGeometry.fromZone(rebuilt)!;
    expect(line.points.length, 3);
    expect(line.points.first.latitude, closeTo(35.0, 1e-6));
  });

  test('polygon ZoneUpsertLight caps at 16 points', () {
    final points = List.generate(
      20,
      (i) => LatLng(35 + i * 0.01, -106 - i * 0.01),
    );
    final geometry = PolygonGeometry(points: points);
    final zone = MapZone(
      id: const Uuid().v4obj(),
      name: 'Big poly',
      type: polygonZoneType,
      color: '#010203',
      borderColor: '#010203',
      borderPattern: 'solid',
      fillColor: '#040506',
      visible: true,
      geometryJson: geometry.encode(),
      createdAt: now,
      updatedAt: now,
    );
    final event = mapper.zoneUpsertLightFrom(zone)! as ZoneUpsertLightEvent;
    final rebuilt = mapper.zoneFromUpsertLight(event)!;
    expect(
      PolygonGeometry.fromZone(rebuilt)!.points.length,
      radioZoneMaxAirPoints,
    );
  });

  test('circle still maps', () {
    final zone = MapZone(
      id: const Uuid().v4obj(),
      name: 'Ring',
      type: circleZoneType,
      color: '#AABBCC',
      borderColor: '#AABBCC',
      borderPattern: 'solid',
      fillColor: '#DDEEFF',
      visible: true,
      geometryJson: const CircleGeometry(
        center: LatLng(1, 2),
        radiusMeters: 50,
      ).encode(),
      createdAt: now,
      updatedAt: now,
    );
    expect(mapper.zoneUpsertLightFrom(zone), isNotNull);
  });
}
