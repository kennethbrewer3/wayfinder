import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/lines/models/line_geometry.dart';
import 'package:wayfinder_flutter/features/lines/utils/co_located_line_endpoints.dart';

MapZone _lineZone({
  required UuidValue id,
  required List<LatLng> points,
  bool visible = true,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return MapZone(
    id: id,
    name: 'line',
    type: lineZoneType,
    color: '#ff0000',
    borderColor: '#ff0000',
    borderPattern: 'solid',
    fillColor: '#00000000',
    visible: visible,
    geometryJson: LineGeometry(
      points: points,
      showArrows: false,
    ).encode(),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final junction = const LatLng(40.0, -75.0);
  final elsewhere = const LatLng(41.0, -74.0);
  final selectedId = UuidValue.fromString(
    '00000000-0000-4000-8000-000000000001',
  );
  final otherId = UuidValue.fromString(
    '00000000-0000-4000-8000-000000000002',
  );
  final thirdId = UuidValue.fromString(
    '00000000-0000-4000-8000-000000000003',
  );

  group('findCoLocatedLineEndpoints', () {
    test('finds other line endpoints at the same coordinates', () {
      final zones = [
        _lineZone(
          id: selectedId,
          points: [junction, elsewhere],
        ),
        _lineZone(
          id: otherId,
          points: [junction, const LatLng(39.0, -76.0)],
        ),
        _lineZone(
          id: thirdId,
          points: [const LatLng(38.0, -77.0), junction],
        ),
      ];

      final matches = findCoLocatedLineEndpoints(
        point: junction,
        excludeZoneId: selectedId,
        zones: zones,
      );

      expect(matches, hasLength(2));
      expect(
        matches,
        containsAll([
          isA<CoLocatedLineEndpoint>()
              .having((m) => m.zoneId, 'zoneId', otherId)
              .having((m) => m.controlPointIndex, 'index', 0),
          isA<CoLocatedLineEndpoint>()
              .having((m) => m.zoneId, 'zoneId', thirdId)
              .having((m) => m.controlPointIndex, 'index', 1),
        ]),
      );
    });

    test('ignores mid-points and hidden lines', () {
      final zones = [
        _lineZone(
          id: otherId,
          points: [
            elsewhere,
            junction,
            const LatLng(39.0, -76.0),
          ],
        ),
        _lineZone(
          id: thirdId,
          points: [junction, elsewhere],
          visible: false,
        ),
      ];

      final matches = findCoLocatedLineEndpoints(
        point: junction,
        excludeZoneId: selectedId,
        zones: zones,
      );

      expect(matches, isEmpty);
    });
  });
}
