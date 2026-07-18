import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/lines/models/bearing_reference.dart';
import 'package:wayfinder_flutter/features/map/utils/magnetic_declination.dart';

void main() {
  test('true/magnetic conversion round-trips with east declination', () {
    const trueBearing = 90.0;
    const declination = 12.0;
    final magnetic = trueBearingToMagnetic(
      trueBearingDegrees: trueBearing,
      declinationDegrees: declination,
    );
    expect(magnetic, 78.0);
    expect(
      magneticBearingToTrue(
        magneticBearingDegrees: magnetic,
        declinationDegrees: declination,
      ),
      trueBearing,
    );
  });

  test('formatNavigationBearing uses °T or °M', () {
    expect(
      formatNavigationBearing(
        trueBearingDegrees: 45,
        reference: BearingReference.trueNorth,
        declinationDegrees: 10,
      ),
      '045°T',
    );
    expect(
      formatNavigationBearing(
        trueBearingDegrees: 45,
        reference: BearingReference.magnetic,
        declinationDegrees: 10,
      ),
      '035°M',
    );
  });

  test('formatMagneticDeclination labels east and west', () {
    expect(formatMagneticDeclination(12.4), 'Var 12°E');
    expect(formatMagneticDeclination(-3.2), 'Var 3°W');
    expect(formatMagneticDeclination(0.2), 'Var 0°');
  });

  test('WMM2025 declination is west near Washington DC in 2026', () {
    final dec = magneticDeclinationDegrees(
      location: const LatLng(38.9, -77.0),
      at: DateTime.utc(2026, 7, 1),
    );
    // Mid-Atlantic US is currently west of true north (~10–12°W).
    expect(dec, lessThan(-8));
    expect(dec, greaterThan(-14));
  });
}
