import 'package:latlong2/latlong.dart';

enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

/// Offline sun / moon / twilight readout for a place and calendar date.
class SunMoonResult {
  const SunMoonResult({
    required this.location,
    required this.date,
    required this.sunrise,
    required this.solarNoon,
    required this.sunset,
    required this.civilDawn,
    required this.civilDusk,
    required this.nauticalDawn,
    required this.nauticalDusk,
    required this.astronomicalDawn,
    required this.astronomicalDusk,
    required this.nightOpsStart,
    required this.nightOpsEnd,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonIllumination,
    required this.moonAgeDays,
    required this.polarDay,
    required this.polarNight,
  });

  final LatLng location;

  /// Calendar date used for the computation (date-only, local midnight).
  final DateTime date;

  final DateTime? sunrise;
  final DateTime? solarNoon;
  final DateTime? sunset;

  final DateTime? civilDawn;
  final DateTime? civilDusk;
  final DateTime? nauticalDawn;
  final DateTime? nauticalDusk;
  final DateTime? astronomicalDawn;
  final DateTime? astronomicalDusk;

  /// Nautical dusk → next nautical dawn (darker night-ops window).
  final DateTime? nightOpsStart;
  final DateTime? nightOpsEnd;

  final DateTime? moonrise;
  final DateTime? moonset;

  final MoonPhaseName moonPhase;
  final double moonIllumination;
  final double moonAgeDays;

  final bool polarDay;
  final bool polarNight;
}
