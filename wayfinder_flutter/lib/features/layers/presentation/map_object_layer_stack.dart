import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../circles/presentation/map_circle_layer.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../rectangles/presentation/map_rectangle_layer.dart';
import '../utils/map_layer_utils.dart';

List<Widget> buildStackedMapLayerChildren({
  required List<MapLayer> layers,
  required List<MapMarker> markers,
  required List<MapZone> zones,
  required void Function(MapMarker marker) onMarkerTap,
  UuidValue? selectedLineId,
  Map<UuidValue, LineGeometry>? geometryOverrides,
}) {
  final widgets = <Widget>[];
  final knownLayerIds = layers.map((layer) => layer.id).toSet();

  void addLayerContent(List<MapMarker> layerMarkers, List<MapZone> layerZones) {
    if (layerMarkers.isEmpty && layerZones.isEmpty) {
      return;
    }

    if (layerMarkers.isNotEmpty) {
      widgets.add(
        MarkerLayer(
          markers: layerMarkers
              .map(
                (marker) => Marker(
                  point: LatLng(marker.latitude, marker.longitude),
                  width: mapMarkerWidth,
                  height: mapMarkerHeight,
                  alignment: mapMarkerAnchorAlignment,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onMarkerTap(marker),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: MapMarkerIcon(
                        color: parseMarkerColor(marker.color),
                        iconName: marker.icon,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
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
        polylines: buildSavedCircleRadiusLines(layerZones),
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
    widgets.add(
      MarkerLayer(
        markers: buildSavedLineArrowMarkers(
          layerZones,
          geometryOverrides: geometryOverrides,
        ),
      ),
    );
  }

  for (final layer in visibleMapLayersForRendering(layers)) {
    addLayerContent(
      markersForLayer(markers, layer.id)
          .where((marker) => marker.visible)
          .toList(),
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
