import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../map/providers/home_location_provider.dart';
import 'tide_tables_dialog.dart';

Future<void> showTideTablesAtPoint({
  required BuildContext context,
  required WidgetRef ref,
  MapMarker? selectedMarker,
  LatLng? mapPoint,
  DateTime? initialDate,
}) {
  final home = ref.read(homeLocationProvider);
  return showTideTablesDialog(
    context: context,
    selectedMarkerCenter: selectedMarker == null
        ? null
        : LatLng(selectedMarker.latitude, selectedMarker.longitude),
    selectedMarkerName: selectedMarker?.name,
    homeCenter: home.center,
    mapPoint: mapPoint,
    initialDate: initialDate,
  );
}
