import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../access/providers/access_session_provider.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../../layers/providers/layers_provider.dart';
import '../../layers/utils/map_layer_utils.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../offline_packs/providers/offline_pack_controller.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';

class LayerAssignmentRow extends ConsumerWidget {
  const LayerAssignmentRow({
    super.key,
    required this.layerId,
    required this.onChanged,
  });

  final UuidValue? layerId;
  final ValueChanged<UuidValue?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layersAsync = ref.watch(layersProvider);
    final l10n = AppLocalizations.of(context)!;
    final mutationsLocked =
        ref.watch(kioskModeActiveProvider) ||
        ref.watch(offlineModeActiveProvider) ||
        ref.watch(mapEditsLockedByRoleProvider);

    return layersAsync.when(
      loading: () => ListTile(
        dense: true,
        title: Text(l10n.layerLabel),
        subtitle: Text(l10n.statusLoading),
      ),
      error: (_, _) => ListTile(
        dense: true,
        title: Text(l10n.layerLabel),
        subtitle: Text(
          layerNameForObject(
            layerId: layerId,
            layersById: const {},
            l10n: l10n,
          ),
        ),
      ),
      data: (layers) {
        final selectedId = resolveSelectedLayerId(
          selectedLayerId: layerId,
          layers: layers,
        );

        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.layerLabel),
          trailing: DropdownButton<UuidValue>(
            value: selectedId,
            underline: const SizedBox.shrink(),
            items: [
              for (final layer in sortedMapLayers(layers))
                DropdownMenuItem(
                  value: layer.id,
                  child: Text(layer.name),
                ),
            ],
            onChanged: mutationsLocked ? null : (value) => onChanged(value),
          ),
        );
      },
    );
  }
}

Future<void> updateMarkerLayer(
  WidgetRef ref, {
  required MapMarker marker,
  required UuidValue? layerId,
}) async {
  final updated = marker.copyWith(
    layerId: layerId,
    updatedAt: DateTime.now().toUtc(),
  );
  if (ref.read(offlineModeActiveProvider)) {
    await ref.read(offlinePackControllerProvider).updateMarkerOffline(updated);
    return;
  }
  final client = ref.read(serverClientProvider);
  await client.mapMarker.updateMarker(updated);
  ref.invalidate(markersProvider);
}

Future<void> updateZoneLayer(
  WidgetRef ref, {
  required MapZone zone,
  required UuidValue? layerId,
}) async {
  final client = ref.read(serverClientProvider);
  await client.mapZone.updateZone(
    zone.copyWith(
      layerId: layerId,
      updatedAt: DateTime.now().toUtc(),
    ),
  );
  ref.read(zonesProvider.notifier).reload();
}
