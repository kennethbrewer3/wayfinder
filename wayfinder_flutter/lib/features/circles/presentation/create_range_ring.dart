import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/home_location_provider.dart';
import 'create_circle_dialog.dart';
import 'range_ring_dialog.dart';

Future<bool> createRangeRing({
  required BuildContext context,
  required WidgetRef ref,
  MapMarker? selectedMarker,
  LatLng? mapPoint,
}) async {
  final home = ref.read(homeLocationProvider);
  final result = await showRangeRingDialog(
    context: context,
    measurementUnits: ref.read(measurementUnitsProvider),
    selectedMarkerCenter: selectedMarker == null
        ? null
        : LatLng(selectedMarker.latitude, selectedMarker.longitude),
    selectedMarkerId: selectedMarker?.id.toString(),
    selectedMarkerName: selectedMarker?.name,
    homeCenter: home.center,
    mapPoint: mapPoint,
  );
  if (result == null || !context.mounted) {
    return false;
  }

  return createCircleAtCenter(
    context: context,
    ref: ref,
    center: result.center,
    radiusMeters: result.radiusMeters,
    defaultName: result.suggestedName,
    rangeRing: result.spec,
  );
}
