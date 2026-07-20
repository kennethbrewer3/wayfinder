import '../../circles/models/range_ring.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/utils/line_path.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../models/evac_kit_geometry.dart';

/// Modes shown for evac ETA chips (aligned with range-ring travel modes).
const evacKitEtaModes = rangeRingModes;

/// Planning speed (km/h) for ETA. Reuses range-ring defaults where defined.
double evacPlanningSpeedKmh(TrackTransportationMode mode) {
  return switch (mode) {
    TrackTransportationMode.onFoot => 5,
    TrackTransportationMode.horse => 8,
    TrackTransportationMode.bike => 16,
    TrackTransportationMode.motorcycle => 90,
    TrackTransportationMode.atv => 45,
    TrackTransportationMode.landVehicle ||
    TrackTransportationMode.truck ||
    TrackTransportationMode.bus ||
    TrackTransportationMode.rv ||
    TrackTransportationMode.ambulance ||
    TrackTransportationMode.fireTruck ||
    TrackTransportationMode.farmVehicle => 90,
    TrackTransportationMode.train => 80,
    TrackTransportationMode.canoe ||
    TrackTransportationMode.watercraft => 6,
    TrackTransportationMode.sailboat => 10,
    TrackTransportationMode.aircraft => 200,
    TrackTransportationMode.helicopter => 150,
    TrackTransportationMode.glider => 80,
    TrackTransportationMode.balloon => 15,
  };
}

double evacRouteLengthMeters(EvacRoute route) {
  return linePathLengthMeters(
    LineGeometry(
      points: route.pathPoints,
      showArrows: false,
      pathMode: route.pathMode,
    ),
  );
}

Duration evacRouteDuration({
  required double lengthMeters,
  required TrackTransportationMode mode,
  double? speedKmh,
}) {
  final speed = speedKmh ?? evacPlanningSpeedKmh(mode);
  if (lengthMeters <= 0 || speed <= 0) {
    return Duration.zero;
  }
  final hours = (lengthMeters / 1000) / speed;
  final seconds = (hours * 3600).round();
  return Duration(seconds: seconds < 1 ? 1 : seconds);
}

String formatEvacDuration(Duration duration) {
  if (duration.inSeconds <= 0) {
    return '—';
  }
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours <= 0) {
    return '${minutes}m';
  }
  if (minutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${minutes}m';
}
