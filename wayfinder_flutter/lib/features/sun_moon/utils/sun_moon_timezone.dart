import 'package:latlong2/latlong.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/sun_moon_timezone.dart';

bool _timeZonesReady = false;

void ensureSunMoonTimeZonesInitialized() {
  if (_timeZonesReady) {
    return;
  }
  tzdata.initializeTimeZones();
  _timeZonesReady = true;
}

/// POSIX `Etc/GMT±N` for the nominal solar timezone of [longitude] degrees east.
///
/// Signs are inverted vs civil UTC offsets: longitude −75° → `Etc/GMT+5` (UTC−5).
String etcGmtFromLongitude(double longitude) {
  final utcOffsetHours = (longitude / 15.0).round().clamp(-12, 14);
  if (utcOffsetHours == 0) {
    return 'UTC';
  }
  // Etc/GMT+5 means UTC−5.
  final sign = utcOffsetHours < 0 ? '+' : '-';
  return 'Etc/GMT$sign${utcOffsetHours.abs()}';
}

String resolveZoneIanaName({
  required String zoneId,
  LatLng? location,
}) {
  if (zoneId == sunMoonLongitudeZoneId) {
    final lon = location?.longitude ?? 0;
    return etcGmtFromLongitude(lon);
  }
  return zoneId;
}

tz.Location locationForZoneId({
  required String zoneId,
  LatLng? location,
}) {
  ensureSunMoonTimeZonesInitialized();
  final name = resolveZoneIanaName(zoneId: zoneId, location: location);
  return tz.getLocation(name);
}

/// Standard and daylight offsets for [location] in [year] (UTC year).
({Duration standard, Duration daylight, bool observesDst}) zoneOffsetsForYear(
  tz.Location location,
  int year,
) {
  ensureSunMoonTimeZonesInitialized();
  final january = tz.TZDateTime.from(DateTime.utc(year, 1, 15, 12), location);
  final july = tz.TZDateTime.from(DateTime.utc(year, 7, 15, 12), location);

  if (january.timeZone.isDst == july.timeZone.isDst) {
    return (
      standard: january.timeZoneOffset,
      daylight: january.timeZoneOffset,
      observesDst: false,
    );
  }
  if (january.timeZone.isDst) {
    return (
      standard: july.timeZoneOffset,
      daylight: january.timeZoneOffset,
      observesDst: true,
    );
  }
  return (
    standard: january.timeZoneOffset,
    daylight: july.timeZoneOffset,
    observesDst: true,
  );
}

class SunMoonZoneInstant {
  const SunMoonZoneInstant({
    required this.wallClock,
    required this.offset,
    required this.abbreviation,
    required this.isDst,
    required this.forced,
  });

  /// Civil wall-clock in the display zone (not a real absolute instant).
  final DateTime wallClock;
  final Duration offset;
  final String abbreviation;
  final bool isDst;

  /// True when [SunMoonDstMode.standard] or [SunMoonDstMode.daylight] overrode auto.
  final bool forced;
}

SunMoonZoneInstant convertUtcToZone({
  required DateTime utc,
  required tz.Location location,
  required SunMoonDstMode dstMode,
}) {
  ensureSunMoonTimeZonesInitialized();
  final instant = utc.toUtc();
  final auto = tz.TZDateTime.from(instant, location);
  final yearOffsets = zoneOffsetsForYear(location, instant.year);

  final Duration offset;
  final bool isDst;
  final bool forced;
  switch (dstMode) {
    case SunMoonDstMode.auto:
      offset = auto.timeZoneOffset;
      isDst = auto.timeZone.isDst;
      forced = false;
    case SunMoonDstMode.standard:
      offset = yearOffsets.standard;
      isDst = false;
      forced = yearOffsets.observesDst && auto.timeZone.isDst;
    case SunMoonDstMode.daylight:
      // Zones without IANA DST (e.g. Etc/GMT±N) still allow a +1h planning shift.
      offset = yearOffsets.observesDst
          ? yearOffsets.daylight
          : yearOffsets.standard + const Duration(hours: 1);
      isDst = true;
      forced = !auto.timeZone.isDst || !yearOffsets.observesDst;
  }

  final shifted = instant.add(offset);
  final wall = DateTime(
    shifted.year,
    shifted.month,
    shifted.day,
    shifted.hour,
    shifted.minute,
    shifted.second,
    shifted.millisecond,
    shifted.microsecond,
  );

  final abbreviation = _abbreviationFor(
    location: location,
    instant: instant,
    offset: offset,
    isDst: isDst,
    dstMode: dstMode,
    auto: auto,
  );

  return SunMoonZoneInstant(
    wallClock: wall,
    offset: offset,
    abbreviation: abbreviation,
    isDst: isDst,
    forced: forced,
  );
}

String formatUtcOffset(Duration offset) {
  final totalMinutes = offset.inMinutes;
  final sign = totalMinutes >= 0 ? '+' : '−';
  final abs = totalMinutes.abs();
  final hours = abs ~/ 60;
  final minutes = abs % 60;
  if (minutes == 0) {
    return 'UTC$sign$hours';
  }
  final mm = minutes.toString().padLeft(2, '0');
  return 'UTC$sign$hours:$mm';
}

String _abbreviationFor({
  required tz.Location location,
  required DateTime instant,
  required Duration offset,
  required bool isDst,
  required SunMoonDstMode dstMode,
  required tz.TZDateTime auto,
}) {
  if (dstMode == SunMoonDstMode.auto) {
    final name = auto.timeZone.abbreviation;
    if (name.isNotEmpty) {
      return name;
    }
  }

  // Prefer a matching seasonal abbreviation from the same year.
  final sample = isDst
      ? tz.TZDateTime.from(DateTime.utc(instant.year, 7, 15, 12), location)
      : tz.TZDateTime.from(DateTime.utc(instant.year, 1, 15, 12), location);
  if (sample.timeZoneOffset == offset &&
      sample.timeZone.abbreviation.isNotEmpty) {
    return sample.timeZone.abbreviation;
  }
  if (auto.timeZoneOffset == offset &&
      auto.timeZone.abbreviation.isNotEmpty) {
    return auto.timeZone.abbreviation;
  }
  return formatUtcOffset(offset);
}
