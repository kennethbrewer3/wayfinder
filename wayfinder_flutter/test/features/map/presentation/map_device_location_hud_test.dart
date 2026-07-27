import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/map/presentation/map_device_location_hud.dart';
import 'package:wayfinder_flutter/features/map/providers/device_location_provider.dart';

import '../../../helpers/ui_test_harness.dart';

class _StubDeviceLocationNotifier extends DeviceLocationNotifier {
  _StubDeviceLocationNotifier(DeviceLocationState initial) {
    state = initial;
  }
}

void main() {
  testWidgets('GPS HUD lays out in landscape Stack corner without throwing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceLocationProvider.overrideWith(
            (ref) => _StubDeviceLocationNotifier(
              const DeviceLocationState(
                position: LatLng(38.0293, -78.4767),
                accuracyMeters: 12,
                tracking: true,
                following: true,
              ),
            ),
          ),
        ],
        child: wrapForUiTest(
          const Stack(
            children: [
              Positioned(
                left: 12,
                bottom: 12,
                child: MapDeviceLocationHud(zoom: 14),
              ),
            ],
          ),
          surfaceSize: const Size(844, 390),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(MapDeviceLocationHud), findsOneWidget);
  });

  testWidgets('GPS HUD lays out in narrow portrait without throwing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceLocationProvider.overrideWith(
            (ref) => _StubDeviceLocationNotifier(
              const DeviceLocationState(
                position: LatLng(38.0293, -78.4767),
                accuracyMeters: 12,
                tracking: true,
                following: true,
              ),
            ),
          ),
        ],
        child: wrapForUiTest(
          const Stack(
            children: [
              Positioned(
                left: 12,
                bottom: 12,
                child: MapDeviceLocationHud(zoom: 14),
              ),
            ],
          ),
          surfaceSize: const Size(320, 568),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
