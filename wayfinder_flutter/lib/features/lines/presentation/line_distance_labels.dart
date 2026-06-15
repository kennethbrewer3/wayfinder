import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/line_geometry.dart';
import '../models/measurement_units.dart';
import '../utils/line_distance.dart';

const _labelMaxWidth = 128.0;
const _singleRowHeight = 22.0;
const _rowSpacing = 2.0;

class LineMapLabelContent {
  const LineMapLabelContent({
    required this.id,
    required this.point,
    required this.color,
    this.name,
    this.distance,
  });

  final String id;
  final LatLng point;
  final Color color;
  final String? name;
  final String? distance;

  Size get size {
    final rowCount = (name != null ? 1 : 0) + (distance != null ? 1 : 0);
    final height = rowCount * _singleRowHeight + (rowCount - 1) * _rowSpacing;
    return Size(_labelMaxWidth, height);
  }
}

List<LineMapLabelContent> collectSavedLineMapLabelContents(
  List<MapZone> zones,
  MeasurementUnits units,
) {
  final contents = <LineMapLabelContent>[];
  for (final zone in zones) {
    if (!zone.visible || zone.type != lineZoneType) {
      continue;
    }
    final content = lineMapLabelContentForZone(zone, units);
    if (content != null) {
      contents.add(content);
    }
  }
  return contents;
}

LineMapLabelContent? lineMapLabelContentForZone(
  MapZone zone,
  MeasurementUnits units,
) {
  final geometry = LineGeometry.fromZone(zone);
  if (geometry == null || !geometry.isValid) {
    return null;
  }

  final name = geometry.showNameLabel ? zone.name : null;
  final distance = geometry.showDistanceLabel
      ? formatLineDistance(
          lineLengthMeters(geometry.start!, geometry.end!),
          units,
        )
      : null;
  if (name == null && distance == null) {
    return null;
  }

  return LineMapLabelContent(
    id: zone.id.uuid,
    point: lineSegmentMidpoint(geometry.start!, geometry.end!),
    color: parseMarkerColor(zone.color),
    name: name,
    distance: distance,
  );
}

LineMapLabelContent? previewLineMapLabelContent({
  required LatLng start,
  required LatLng? previewEnd,
  required Color color,
  required MeasurementUnits units,
}) {
  if (previewEnd == null) {
    return null;
  }
  if (lineLengthMeters(start, previewEnd) < 1) {
    return null;
  }

  return LineMapLabelContent(
    id: 'preview-line-label',
    point: lineSegmentMidpoint(start, previewEnd),
    color: color,
    distance: formatLineDistance(lineLengthMeters(start, previewEnd), units),
  );
}

/// Renders line labels in screen space instead of [MarkerLayer].
///
/// [MarkerLayer] repeats markers across wrapped worlds with duplicate keys,
/// which causes label widgets to jump between lines when toggling visibility.
class LineMapLabelsOverlay extends StatefulWidget {
  const LineMapLabelsOverlay({
    super.key,
    required this.zones,
    required this.units,
    required this.mapController,
    this.previewStart,
    this.previewEnd,
    this.previewColor,
  });

  final List<MapZone> zones;
  final MeasurementUnits units;
  final MapController mapController;
  final LatLng? previewStart;
  final LatLng? previewEnd;
  final Color? previewColor;

  @override
  State<LineMapLabelsOverlay> createState() => _LineMapLabelsOverlayState();
}

class _LineMapLabelsOverlayState extends State<LineMapLabelsOverlay> {
  StreamSubscription<MapEvent>? _mapEvents;

  @override
  void initState() {
    super.initState();
    _mapEvents = widget.mapController.mapEventStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant LineMapLabelsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _mapEvents?.cancel();
      _mapEvents = widget.mapController.mapEventStream.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _mapEvents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.mapController.camera;
    final mapSize = camera.size;
    final labels = collectSavedLineMapLabelContents(widget.zones, widget.units);

    if (widget.previewStart case final start? when widget.previewColor != null) {
      final preview = previewLineMapLabelContent(
        start: start,
        previewEnd: widget.previewEnd,
        color: widget.previewColor!,
        units: widget.units,
      );
      if (preview != null) {
        labels.add(preview);
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final label in labels)
          if (_screenPositionForLabel(label, camera, mapSize)
              case final screen?)
            Positioned(
              key: ValueKey<String>(
                'line-label-${label.id}-${label.name ?? ''}-${label.distance ?? ''}',
              ),
              left: screen.dx,
              top: screen.dy,
              width: label.size.width,
              height: label.size.height,
              child: LineMapLabelStack(
                name: label.name,
                distance: label.distance,
                color: label.color,
              ),
            ),
      ],
    );
  }

  Offset? _screenPositionForLabel(
    LineMapLabelContent label,
    MapCamera camera,
    Size mapSize,
  ) {
    final screen = camera.latLngToScreenOffset(label.point);
    final halfWidth = label.size.width / 2;
    final halfHeight = label.size.height / 2;
    final left = screen.dx - halfWidth;
    final top = screen.dy - halfHeight;

    if (left > mapSize.width ||
        top > mapSize.height ||
        left + label.size.width < 0 ||
        top + label.size.height < 0) {
      return null;
    }

    return Offset(left, top);
  }
}

class LineMapLabelStack extends StatelessWidget {
  const LineMapLabelStack({
    super.key,
    this.name,
    this.distance,
    required this.color,
  });

  final String? name;
  final String? distance;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (name case final value?)
          LineMapLabelChip(
            text: value,
            color: color,
            emphasized: true,
          ),
        if (name != null && distance != null) SizedBox(height: _rowSpacing),
        if (distance case final value?)
          LineMapLabelChip(
            text: value,
            color: color,
          ),
      ],
    );
  }
}

class LineMapLabelChip extends StatelessWidget {
  const LineMapLabelChip({
    super.key,
    required this.text,
    required this.color,
    this.emphasized = false,
  });

  final String text;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.85)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            color: color.withValues(alpha: 0.95),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
