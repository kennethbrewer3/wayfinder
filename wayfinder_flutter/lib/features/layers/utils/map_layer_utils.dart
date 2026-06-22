import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

/// Default layer seeded by the layers migration.
final defaultMapLayerId =
    UuidValue.fromString('00000000-0000-4000-8000-000000000001');

List<MapLayer> sortedMapLayers(List<MapLayer> layers) {
  return [...layers]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

/// Layers ordered for the sidebar (top of stack first).
List<MapLayer> mapLayersForSidebar(List<MapLayer> layers) {
  return sortedMapLayers(layers).reversed.toList();
}

Map<UuidValue, MapLayer> mapLayersById(List<MapLayer> layers) {
  return {for (final layer in layers) layer.id: layer};
}

bool isMarkerShownOnMap(
  MapMarker marker,
  Map<UuidValue, MapLayer> layersById,
) {
  if (!marker.visible) {
    return false;
  }
  final layerId = marker.layerId;
  if (layerId == null) {
    return true;
  }
  return layersById[layerId]?.visible ?? true;
}

bool isZoneShownOnMap(
  MapZone zone,
  Map<UuidValue, MapLayer> layersById,
) {
  if (!zone.visible) {
    return false;
  }
  final layerId = zone.layerId;
  if (layerId == null) {
    return true;
  }
  return layersById[layerId]?.visible ?? true;
}

List<MapMarker> filterMarkersForMap(
  List<MapMarker> markers,
  Map<UuidValue, MapLayer> layersById,
) {
  return markers
      .where((marker) => isMarkerShownOnMap(marker, layersById))
      .toList();
}

List<MapZone> filterZonesForMap(
  List<MapZone> zones,
  Map<UuidValue, MapLayer> layersById,
) {
  return zones.where((zone) => isZoneShownOnMap(zone, layersById)).toList();
}

List<MapLayer> visibleMapLayersForRendering(List<MapLayer> layers) {
  return sortedMapLayers(layers).where((layer) => layer.visible).toList();
}

UuidValue? resolveSelectedLayerId({
  required UuidValue? selectedLayerId,
  required List<MapLayer> layers,
}) {
  if (selectedLayerId != null &&
      layers.any((layer) => layer.id == selectedLayerId)) {
    return selectedLayerId;
  }
  if (layers.isEmpty) {
    return null;
  }
  return sortedMapLayers(layers).last.id;
}

String layerNameForObject({
  required UuidValue? layerId,
  required Map<UuidValue, MapLayer> layersById,
  required AppLocalizations l10n,
}) {
  if (layerId == null) {
    return l10n.layerUnassigned;
  }
  return layersById[layerId]?.name ?? l10n.layerUnknown;
}

List<MapMarker> markersForLayer(
  List<MapMarker> markers,
  UuidValue? layerId,
) {
  return markers.where((marker) => objectBelongsToLayer(marker.layerId, layerId)).toList();
}

List<MapZone> zonesForLayer(
  List<MapZone> zones,
  UuidValue? layerId,
) {
  return zones.where((zone) => objectBelongsToLayer(zone.layerId, layerId)).toList();
}

bool objectBelongsToLayer(UuidValue? objectLayerId, UuidValue? layerId) {
  if (layerId == null) {
    return objectLayerId == null;
  }
  if (objectLayerId == layerId) {
    return true;
  }
  return objectLayerId == null && layerId == defaultMapLayerId;
}

bool isLayerExpandedInSidebar({
  required UuidValue? layerId,
  required Set<UuidValue>? expandedLayerIds,
}) {
  if (layerId == null) {
    return false;
  }
  if (expandedLayerIds == null) {
    return true;
  }
  return expandedLayerIds.contains(layerId);
}

List<MapLayer> applyLayerOrder(
  List<MapLayer> layers,
  int fromIndex,
  int toIndex,
) {
  final ordered = mapLayersForSidebar(layers);
  if (fromIndex < 0 ||
      toIndex < 0 ||
      fromIndex >= ordered.length ||
      toIndex >= ordered.length ||
      fromIndex == toIndex) {
    return ordered;
  }

  final moved = ordered.removeAt(fromIndex);
  ordered.insert(toIndex, moved);

  final now = DateTime.now().toUtc();
  final count = ordered.length;
  return [
    for (var i = 0; i < count; i++)
      ordered[i].copyWith(
        sortOrder: count - 1 - i,
        updatedAt: now,
      ),
  ];
}
