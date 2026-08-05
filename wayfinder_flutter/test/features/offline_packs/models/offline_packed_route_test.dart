import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/offline_packs/models/offline_packed_route.dart';
import 'package:wayfinder_flutter/features/routing/models/routing_models.dart';

void main() {
  test('OfflinePackedRoute round-trips through JSON', () {
    final route = OfflinePackedRoute(
      id: 'route-1',
      destinationLabel: 'Rally point',
      destinationMarkerId: 'marker-1',
      profile: RoutingProfile.bike,
      origin: const RoutingPoint(lat: 37.1, lon: -80.2),
      result: const RoutingResult(
        distanceMeters: 1200,
        timeMs: 300000,
        points: [
          RoutingPoint(lat: 37.1, lon: -80.2),
          RoutingPoint(lat: 37.11, lon: -80.21),
        ],
        instructions: [
          RoutingInstruction(
            text: 'Turn right onto Main St',
            streetName: 'Main St',
            distanceMeters: 200,
            timeMs: 40000,
            sign: 2,
            interval: [0, 1],
          ),
        ],
      ),
      preparedAt: DateTime.utc(2026, 8, 5, 15),
    );

    final decoded = OfflinePackedRoute.fromJson(route.toJson());
    expect(decoded.id, route.id);
    expect(decoded.destinationLabel, route.destinationLabel);
    expect(decoded.destinationMarkerId, route.destinationMarkerId);
    expect(decoded.profile, RoutingProfile.bike);
    expect(decoded.origin.lat, 37.1);
    expect(decoded.result.distanceMeters, 1200);
    expect(decoded.result.points, hasLength(2));
    expect(decoded.result.instructions.single.streetName, 'Main St');
    expect(decoded.preparedAt, DateTime.utc(2026, 8, 5, 15));
  });
}
