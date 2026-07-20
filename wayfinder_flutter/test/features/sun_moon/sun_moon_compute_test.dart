import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/sun_moon/models/sun_moon_result.dart';
import 'package:wayfinder_flutter/features/sun_moon/utils/sun_moon_compute.dart';

void main() {
  const charlottesville = LatLng(38.03, -78.48);

  test('summer sunrise/sunset around Charlottesville are sane UTC times', () {
    final result = computeSunMoon(
      location: charlottesville,
      date: DateTime(2024, 6, 21),
    );

    expect(result.sunrise, isNotNull);
    expect(result.sunset, isNotNull);
    expect(result.solarNoon, isNotNull);
    expect(result.sunrise!.isBefore(result.solarNoon!), isTrue);
    expect(result.solarNoon!.isBefore(result.sunset!), isTrue);

    // ~09:50 UTC sunrise, ~00:40 UTC next day sunset, ~17:15 UTC noon.
    expect(result.sunrise!.hour, inInclusiveRange(9, 10));
    expect(result.solarNoon!.hour, inInclusiveRange(16, 18));
    expect(result.sunset!.day, 22);
  });

  test('twilight brackets sunrise and sunset', () {
    final result = computeSunMoon(
      location: charlottesville,
      date: DateTime(2024, 6, 21),
    );

    expect(result.astronomicalDawn!.isBefore(result.nauticalDawn!), isTrue);
    expect(result.nauticalDawn!.isBefore(result.civilDawn!), isTrue);
    expect(result.civilDawn!.isBefore(result.sunrise!), isTrue);
    expect(result.sunset!.isBefore(result.civilDusk!), isTrue);
    expect(result.civilDusk!.isBefore(result.nauticalDusk!), isTrue);
    expect(result.nauticalDusk!.isBefore(result.astronomicalDusk!), isTrue);
  });

  test('night ops window is nautical dusk to next nautical dawn', () {
    final result = computeSunMoon(
      location: charlottesville,
      date: DateTime(2024, 6, 21),
    );

    expect(result.nightOpsStart, result.nauticalDusk);
    expect(result.nightOpsEnd, isNotNull);
    expect(result.nightOpsStart!.isBefore(result.nightOpsEnd!), isTrue);
    expect(
      result.nightOpsEnd!.difference(result.nauticalDawn!).inHours,
      24,
    );
  });

  test('moon phase and illumination are populated', () {
    final result = computeSunMoon(
      location: charlottesville,
      date: DateTime(2024, 6, 21),
    );

    expect(result.moonIllumination, inInclusiveRange(0.0, 1.0));
    expect(result.moonAgeDays, inInclusiveRange(0.0, 30.0));
    expect(result.moonPhase, isA<MoonPhaseName>());
  });

  test('near-full moon around 2024-06-22', () {
    final result = computeSunMoon(
      location: charlottesville,
      date: DateTime(2024, 6, 22),
    );

    expect(result.moonIllumination, greaterThan(0.9));
    expect(result.moonAgeDays, inInclusiveRange(13.0, 17.0));
    expect(
      result.moonPhase,
      anyOf(
        MoonPhaseName.fullMoon,
        MoonPhaseName.waxingGibbous,
        MoonPhaseName.waningGibbous,
      ),
    );
  });
}
