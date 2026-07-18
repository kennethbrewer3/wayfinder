import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/models/bearing_reference.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/utils/line_distance.dart';
import '../presentation/map_cursor_coordinates.dart';
import '../providers/selected_map_object_provider.dart';
import 'magnetic_declination.dart';

/// Position line for the GPS HUD (MGRS when [showMgrs] is true).
String formatDeviceLocationPosition({
  required LatLng location,
  required bool showMgrs,
  required double zoom,
}) {
  return formatMapCursorReadout(
    location,
    showMgrs: showMgrs,
    zoom: zoom,
  );
}

/// Distance and bearing from [from] to [to], for the GPS HUD.
String formatDeviceLocationRange({
  required LatLng from,
  required LatLng to,
  required MeasurementUnits units,
  required BearingReference bearingReference,
  double? declinationDegrees,
}) {
  final meters = lineLengthMeters(from, to);
  final trueBearing = lineGeodesicCalculator.bearing(from, to);
  final declination =
      declinationDegrees ?? magneticDeclinationDegrees(location: from);
  return '${formatLineDistance(meters, units)} · ${formatNavigationBearing(
    trueBearingDegrees: trueBearing,
    reference: bearingReference,
    declinationDegrees: declination,
  )}';
}

/// Selected marker used as a GPS navigation target, if any.
MapMarker? selectedMarkerTarget({
  required SelectedMapObject? selection,
  required List<MapMarker> markers,
}) {
  final id = selection.selectedMarkerId;
  if (id == null) {
    return null;
  }
  final target = id.toString().toLowerCase();
  for (final marker in markers) {
    if (marker.id.toString().toLowerCase() == target) {
      return marker;
    }
  }
  return null;
}
