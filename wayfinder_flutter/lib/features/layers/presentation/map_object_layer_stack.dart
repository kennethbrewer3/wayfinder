import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../circles/presentation/map_circle_layer.dart';
import '../../tracks/presentation/map_track_layer.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/models/map_marker_size.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/utils/effective_marker_icon.dart';
import '../../rectangles/presentation/map_rectangle_layer.dart';
import '../utils/map_layer_utils.dart';

const _selectedMarkerScaleBoost = 1.28;

List<Widget> buildStackedMapLayerChildren({
  required List<MapLayer> layers,
  required List<MapMarker> markers,
  required List<MapZone> zones,
  required void Function(MapMarker marker) onMarkerTap,
  void Function(MapMarker marker)? onMarkerLongPress,
  required double mapMarkerSizeScale,
  UuidValue? selectedLineId,
  UuidValue? selectedMarkerId,
  Color? markerSelectionColor,
  Map<UuidValue, LineGeometry>? geometryOverrides,
}) {
  final widgets = <Widget>[];
  final knownLayerIds = layers.map((layer) => layer.id).toSet();
  final trackZones = trackZonesById(zones);

  void addLayerContent(List<MapMarker> layerMarkers, List<MapZone> layerZones) {
    if (layerMarkers.isEmpty && layerZones.isEmpty) {
      return;
    }

    if (layerMarkers.isNotEmpty) {
      final baseWidth = mapMarkerRenderWidth(mapMarkerSizeScale);
      final baseHeight = mapMarkerRenderHeight(mapMarkerSizeScale);
      // Paint selected marker last so its halo sits above neighbors.
      final ordered = [...layerMarkers]
        ..sort((a, b) {
          final aSelected = a.id == selectedMarkerId;
          final bSelected = b.id == selectedMarkerId;
          if (aSelected == bSelected) {
            return 0;
          }
          return aSelected ? 1 : -1;
        });
      widgets.add(
        MarkerLayer(
          markers: ordered.map((marker) {
            final isSelected = marker.id == selectedMarkerId;
            final markerWidth = isSelected
                ? baseWidth * _selectedMarkerScaleBoost
                : baseWidth;
            final markerHeight = isSelected
                ? baseHeight * _selectedMarkerScaleBoost
                : baseHeight;
            return Marker(
              point: LatLng(marker.latitude, marker.longitude),
              width: markerWidth,
              height: markerHeight,
              alignment: mapMarkerAnchorAlignment,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onMarkerTap(marker),
                onLongPress: onMarkerLongPress == null
                    ? null
                    : () => onMarkerLongPress(marker),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: MapMarkerIcon(
                    color: parseMarkerColor(marker.color),
                    iconName: effectiveMarkerIconName(
                      marker: marker,
                      trackZonesById: trackZones,
                    ),
                    width: markerWidth,
                    height: markerHeight,
                    isSelected: isSelected,
                    selectionColor: markerSelectionColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    if (layerZones.isEmpty) {
      return;
    }

    widgets.add(
      PolygonLayer(
        polygons: [
          ...buildSavedCirclePolygons(layerZones),
          ...buildSavedRectanglePolygons(layerZones),
        ],
      ),
    );
    widgets.add(
      PolylineLayer(
        polylines: [
          ...buildSavedCircleRadiusLines(layerZones),
          ...buildSavedTrackPolylines(layerZones),
        ],
      ),
    );
    widgets.add(
      MarkerLayer(
        markers: [
          ...buildSavedCircleCenterMarkers(layerZones),
          ...buildSavedRectangleCenterMarkers(layerZones),
        ],
      ),
    );
    widgets.add(
      PolylineLayer(
        polylines: buildSavedLinePolylines(
          layerZones,
          selectedLineId: selectedLineId,
          geometryOverrides: geometryOverrides,
        ),
      ),
    );
  }

  for (final layer in visibleMapLayersForRendering(layers)) {
    addLayerContent(
      markersForLayer(
        markers,
        layer.id,
      ).where((marker) => marker.visible).toList(),
      zonesForLayer(zones, layer.id).where((zone) => zone.visible).toList(),
    );
  }

  final orphanMarkers = markers
      .where(
        (marker) =>
            marker.visible &&
            (marker.layerId == null || !knownLayerIds.contains(marker.layerId)),
      )
      .toList();
  final orphanZones = zones
      .where(
        (zone) =>
            zone.visible &&
            (zone.layerId == null || !knownLayerIds.contains(zone.layerId)),
      )
      .toList();
  addLayerContent(orphanMarkers, orphanZones);

  return widgets;
}
