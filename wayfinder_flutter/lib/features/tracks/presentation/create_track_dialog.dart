import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/models/marker_color.dart';
import '../models/track_geometry.dart';
import 'track_form_dialog.dart';

Future<bool> updateTrackFromForm({
  required BuildContext context,
  required WidgetRef ref,
  required MapZone zone,
}) async {
  final geometry = TrackGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return false;
  }

  final formData = await showTrackFormDialog(
    context: context,
    zone: zone,
    geometry: geometry,
  );
  if (formData == null || !context.mounted) {
    return false;
  }

  final colorHex = formatMarkerColorHex(formData.color);
  final updatedGeometry = geometry.copyWith(
    showFootsteps: formData.showFootsteps,
  );

  final client = ref.read(serverClientProvider);
  await client.mapZone.updateZone(
    zone.copyWith(
      name: formData.name,
      color: colorHex,
      borderColor: colorHex,
      fillColor: colorHex,
      geometryJson: updatedGeometry.encode(),
      layerId: formData.layerId,
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.read(zonesProvider.notifier).reload();
  return true;
}
