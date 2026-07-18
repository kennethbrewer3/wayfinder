import 'package:geomag/geomag.dart';
import 'package:latlong2/latlong.dart' hide normalizeBearing;

import '../../lines/models/bearing_reference.dart';
import '../../lines/utils/bearing_utils.dart';

final GeoMag _geoMag = GeoMag();

/// Magnetic declination in degrees east of true north (WMM2025).
double magneticDeclinationDegrees({
  required LatLng location,
  DateTime? at,
  double elevationMeters = 0,
}) {
  final heightFeet = elevationMeters * 3.280839895;
  return _geoMag
      .calculate(
        location.latitude,
        location.longitude,
        heightFeet,
        at ?? DateTime.now().toUtc(),
      )
      .dec;
}

/// True bearing → magnetic bearing (declination east is positive).
double trueBearingToMagnetic({
  required double trueBearingDegrees,
  required double declinationDegrees,
}) {
  return normalizeBearing(trueBearingDegrees - declinationDegrees);
}

/// Magnetic bearing → true bearing.
double magneticBearingToTrue({
  required double magneticBearingDegrees,
  required double declinationDegrees,
}) {
  return normalizeBearing(magneticBearingDegrees + declinationDegrees);
}

double displayBearingFromTrue({
  required double trueBearingDegrees,
  required BearingReference reference,
  required double declinationDegrees,
}) {
  return switch (reference) {
    BearingReference.trueNorth => normalizeBearing(trueBearingDegrees),
    BearingReference.magnetic => trueBearingToMagnetic(
      trueBearingDegrees: trueBearingDegrees,
      declinationDegrees: declinationDegrees,
    ),
  };
}

String formatNavigationBearing({
  required double trueBearingDegrees,
  required BearingReference reference,
  required double declinationDegrees,
}) {
  final display = displayBearingFromTrue(
    trueBearingDegrees: trueBearingDegrees,
    reference: reference,
    declinationDegrees: declinationDegrees,
  );
  final suffix = switch (reference) {
    BearingReference.trueNorth => 'T',
    BearingReference.magnetic => 'M',
  };
  return '${display.round().toString().padLeft(3, '0')}°$suffix';
}

/// Formats declination for HUD/compass, e.g. `Var 12°E` or `Var 3°W`.
String formatMagneticDeclination(double declinationDegrees) {
  final rounded = declinationDegrees.round();
  if (rounded == 0) {
    return 'Var 0°';
  }
  final direction = rounded > 0 ? 'E' : 'W';
  return 'Var ${rounded.abs()}°$direction';
}
