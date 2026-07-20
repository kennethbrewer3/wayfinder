import 'dart:math' as math;

import 'package:astronomia/astronomia.dart';
import 'package:astronomia/coord.dart' as coord;
import 'package:astronomia/deltat.dart' as deltat;
import 'package:astronomia/moonillum.dart' as moonillum;
import 'package:astronomia/moonphase.dart' as moonphase;
import 'package:astronomia/moonposition.dart' as moonposition;
import 'package:astronomia/nutation.dart' as nutation;
import 'package:astronomia/rise.dart' as rise;
import 'package:astronomia/sidereal.dart' as sidereal;
import 'package:astronomia/solar.dart' as solar;
import 'package:latlong2/latlong.dart';

import '../models/sun_moon_result.dart';

/// Offline sun / moon / twilight for [location] on the calendar [date].
///
/// [date] is interpreted as a civil calendar date (year/month/day); the
/// time-of-day and timezone on [date] are ignored. Event times are UTC.
SunMoonResult computeSunMoon({
  required LatLng location,
  required DateTime date,
}) {
  final day = DateTime(date.year, date.month, date.day);
  final jd = calendarGregorianToJD(day.year, day.month, day.day.toDouble());
  final lat = toRad(location.latitude);
  // Astronomia / Meeus use west-positive longitude.
  final lon = toRad(-location.longitude);
  final th0 = sidereal.apparent0UT(jd);
  final deltaT = _deltaTSeconds(day.year + (day.month - 0.5) / 12);
  final solarEq = [
    for (final offset in const [-1.0, 0.0, 1.0])
      solar.apparentEquatorial(jd + offset),
  ];
  final alpha = [solarEq[0].ra, solarEq[1].ra, solarEq[2].ra];
  final delta = [solarEq[0].dec, solarEq[1].dec, solarEq[2].dec];

  final sun = _solarEvents(
    jd: jd,
    lat: lat,
    lon: lon,
    deltaT: deltaT,
    th0: th0,
    alpha: alpha,
    delta: delta,
    h0: rise.stdh0Solar,
  );
  final civil = _solarEvents(
    jd: jd,
    lat: lat,
    lon: lon,
    deltaT: deltaT,
    th0: th0,
    alpha: alpha,
    delta: delta,
    h0: toRad(-6),
  );
  final nautical = _solarEvents(
    jd: jd,
    lat: lat,
    lon: lon,
    deltaT: deltaT,
    th0: th0,
    alpha: alpha,
    delta: delta,
    h0: toRad(-12),
  );
  final astronomical = _solarEvents(
    jd: jd,
    lat: lat,
    lon: lon,
    deltaT: deltaT,
    th0: th0,
    alpha: alpha,
    delta: delta,
    h0: toRad(-18),
  );

  final moon = _moonEvents(
    jd: jd,
    lat: lat,
    lon: lon,
    deltaT: deltaT,
    th0: th0,
  );
  final phase = _moonPhaseAt(jd + 0.5);

  final polarDay = sun.rise == null && sun.set == null && _sunAlwaysUp(lat, jd);
  final polarNight =
      sun.rise == null && sun.set == null && !polarDay;

  final nauticalDusk = _ensureAfter(nautical.set, nautical.rise);
  final nightOpsStart = nauticalDusk;
  final nightOpsEnd = nautical.rise?.add(const Duration(days: 1));

  return SunMoonResult(
    location: location,
    date: day,
    sunrise: sun.rise,
    solarNoon: sun.transit,
    sunset: _ensureAfter(sun.set, sun.rise),
    civilDawn: civil.rise,
    civilDusk: _ensureAfter(civil.set, civil.rise),
    nauticalDawn: nautical.rise,
    nauticalDusk: nauticalDusk,
    astronomicalDawn: astronomical.rise,
    astronomicalDusk: _ensureAfter(astronomical.set, astronomical.rise),
    nightOpsStart: nightOpsStart,
    nightOpsEnd: nightOpsEnd,
    moonrise: moon.rise,
    moonset: _ensureAfter(moon.set, moon.rise),
    moonPhase: phase.name,
    moonIllumination: phase.illumination,
    moonAgeDays: phase.ageDays,
    polarDay: polarDay,
    polarNight: polarNight,
  );
}

({DateTime? rise, DateTime? transit, DateTime? set}) _solarEvents({
  required double jd,
  required double lat,
  required double lon,
  required double deltaT,
  required double th0,
  required List<double> alpha,
  required List<double> delta,
  required double h0,
}) {
  final times = rise.times(lat, lon, deltaT, h0, th0, alpha, delta);
  if (times == null) {
    return (rise: null, transit: _jdToUtc(jd + 0.5 + lon / (2 * math.pi)), set: null);
  }
  return (
    rise: _secondsToUtc(jd, times.rise),
    transit: _secondsToUtc(jd, times.transit),
    set: _secondsToUtc(jd, times.set),
  );
}

({DateTime? rise, DateTime? set}) _moonEvents({
  required double jd,
  required double lat,
  required double lon,
  required double deltaT,
  required double th0,
}) {
  final eps = nutation.meanObliquity(jd);
  final sEps = math.sin(eps);
  final cEps = math.cos(eps);
  final times = rise.moonTimes(jd, lat, lon, deltaT, th0, (jde) {
    final pos = moonposition.position(jde);
    final eq = coord.eclToEq(pos.lon, pos.lat, sEps, cEps);
    return (
      ra: eq.ra,
      dec: eq.dec,
      parallax: moonposition.parallax(pos.delta),
    );
  });
  if (times == null) {
    return (rise: null, set: null);
  }
  return (
    rise: _secondsToUtc(jd, times.rise),
    set: _secondsToUtc(jd, times.set),
  );
}

({MoonPhaseName name, double illumination, double ageDays}) _moonPhaseAt(
  double jde,
) {
  final phaseAngle = moonillum.phaseAngle3(jde);
  final illumination = moonillum.illuminated(phaseAngle).clamp(0.0, 1.0);
  final ageDays = _moonAgeDays(jde);
  final cycle = ageDays / 29.530588861;
  final t = cycle - cycle.floorToDouble();

  final MoonPhaseName name;
  if (t < 0.03 || t >= 0.97) {
    name = MoonPhaseName.newMoon;
  } else if (t < 0.22) {
    name = MoonPhaseName.waxingCrescent;
  } else if (t < 0.28) {
    name = MoonPhaseName.firstQuarter;
  } else if (t < 0.47) {
    name = MoonPhaseName.waxingGibbous;
  } else if (t < 0.53) {
    name = MoonPhaseName.fullMoon;
  } else if (t < 0.72) {
    name = MoonPhaseName.waningGibbous;
  } else if (t < 0.78) {
    name = MoonPhaseName.lastQuarter;
  } else {
    name = MoonPhaseName.waningCrescent;
  }

  return (name: name, illumination: illumination, ageDays: ageDays);
}

double _moonAgeDays(double jde) {
  final cal = jdToCalendar(jde);
  final day = cal.day.round().clamp(1, 31);
  final baseYear =
      cal.year + dayOfYear(cal.year, cal.month, day) / 365.25;
  double? previous;
  for (var step = -4; step <= 4; step++) {
    final newMoonJd = moonphase.newMoon(baseYear + step / 12.0);
    if (newMoonJd <= jde &&
        (previous == null || newMoonJd > previous)) {
      previous = newMoonJd;
    }
  }
  previous ??= moonphase.newMoon(baseYear - 1);
  return (jde - previous).clamp(0.0, 29.530588861);
}

bool _sunAlwaysUp(double latRad, double jd) {
  final eq = solar.apparentEquatorial(jd);
  // Rough: sun never sets when |lat| + dec have the same sign and sum > 90° - h0.
  final h0 = rise.stdh0Solar;
  final cosH = (math.sin(h0) - math.sin(latRad) * math.sin(eq.dec)) /
      (math.cos(latRad) * math.cos(eq.dec));
  return cosH < -1;
}

double _deltaTSeconds(double year) {
  if (year >= 2005) {
    return deltat.polyAfter2000(year);
  }
  if (year >= 1900) {
    return deltat.interp10A(calendarGregorianToJD(year.floor(), 7, 1));
  }
  return 69;
}

DateTime _secondsToUtc(double jd0, double seconds) {
  return _jdToUtc(jd0 + seconds / 86400.0);
}

DateTime _jdToUtc(double jd) {
  final cal = jdToCalendar(jd);
  final dayInt = cal.day.floor();
  final frac = cal.day - dayInt;
  final ms = (frac * 86400000).round();
  return DateTime.utc(cal.year, cal.month, dayInt).add(
    Duration(milliseconds: ms),
  );
}

DateTime? _ensureAfter(DateTime? later, DateTime? earlier) {
  if (later == null || earlier == null) {
    return later;
  }
  if (later.isBefore(earlier) || later.isAtSameMomentAs(earlier)) {
    return later.add(const Duration(days: 1));
  }
  return later;
}
