import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/sun_moon/models/sun_moon_timezone.dart';
import 'package:wayfinder_flutter/features/sun_moon/utils/sun_moon_timezone.dart';

void main() {
  setUpAll(ensureSunMoonTimeZonesInitialized);

  test('Etc/GMT from longitude uses POSIX inverted signs', () {
    expect(etcGmtFromLongitude(-78.48), 'Etc/GMT+5');
    expect(etcGmtFromLongitude(0), 'UTC');
    expect(etcGmtFromLongitude(139.69), 'Etc/GMT-9');
  });

  test('New York auto uses EDT in June and EST in January', () {
    final location = locationForZoneId(zoneId: 'America/New_York');
    final summer = convertUtcToZone(
      utc: DateTime.utc(2024, 6, 21, 12),
      location: location,
      dstMode: SunMoonDstMode.auto,
    );
    final winter = convertUtcToZone(
      utc: DateTime.utc(2024, 1, 15, 12),
      location: location,
      dstMode: SunMoonDstMode.auto,
    );

    expect(summer.isDst, isTrue);
    expect(summer.offset, const Duration(hours: -4));
    expect(winter.isDst, isFalse);
    expect(winter.offset, const Duration(hours: -5));
  });

  test('forcing standard in June keeps EST offset', () {
    final location = locationForZoneId(zoneId: 'America/New_York');
    final forced = convertUtcToZone(
      utc: DateTime.utc(2024, 6, 21, 16), // 12:00 EDT wall under auto
      location: location,
      dstMode: SunMoonDstMode.standard,
    );

    expect(forced.offset, const Duration(hours: -5));
    expect(forced.isDst, isFalse);
    expect(forced.forced, isTrue);
    expect(forced.wallClock.hour, 11);
  });

  test('forcing daylight in January uses EDT offset', () {
    final location = locationForZoneId(zoneId: 'America/New_York');
    final forced = convertUtcToZone(
      utc: DateTime.utc(2024, 1, 15, 17), // 12:00 EST wall under auto
      location: location,
      dstMode: SunMoonDstMode.daylight,
    );

    expect(forced.offset, const Duration(hours: -4));
    expect(forced.isDst, isTrue);
    expect(forced.forced, isTrue);
    expect(forced.wallClock.hour, 13);
  });

  test('longitude zone resolves for Charlottesville', () {
    final name = resolveZoneIanaName(
      zoneId: sunMoonLongitudeZoneId,
      location: const LatLng(38.03, -78.48),
    );
    expect(name, 'Etc/GMT+5');
    final location = locationForZoneId(
      zoneId: sunMoonLongitudeZoneId,
      location: const LatLng(38.03, -78.48),
    );
    final offsets = zoneOffsetsForYear(location, 2024);
    expect(offsets.observesDst, isFalse);
    expect(offsets.standard, const Duration(hours: -5));

    final daylight = convertUtcToZone(
      utc: DateTime.utc(2024, 6, 21, 17),
      location: location,
      dstMode: SunMoonDstMode.daylight,
    );
    expect(daylight.offset, const Duration(hours: -4));
  });

  test('formatUtcOffset uses minus sign for west', () {
    expect(formatUtcOffset(const Duration(hours: -5)), 'UTC−5');
    expect(formatUtcOffset(const Duration(hours: 2)), 'UTC+2');
    expect(formatUtcOffset(const Duration(hours: 5, minutes: 30)), 'UTC+5:30');
  });
}
