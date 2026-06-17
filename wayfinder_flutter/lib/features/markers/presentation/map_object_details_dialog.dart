import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../circles/models/circle_geometry.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/presentation/create_circle_dialog.dart';
import '../../circles/utils/circle_distance.dart';
import '../../layers/presentation/layer_assignment_row.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/presentation/map_line_layer.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../lines/utils/line_path.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/presentation/map_object_markdown.dart';
import '../../markers/providers/markers_provider.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../rectangles/presentation/create_rectangle_dialog.dart';
import '../../rectangles/utils/rectangle_dimensions.dart';

Future<void> showMapObjectDetailsDialog({
  required BuildContext context,
  required WidgetRef ref,
  required SelectedMapObject selection,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return _MapObjectDetailsDialog(
        selection: selection,
        onEdit: () async {
          Navigator.of(dialogContext).pop();
          await _editSelectedObject(
            context: context,
            ref: ref,
            selection: selection,
          );
        },
      );
    },
  );
}

Future<void> _editSelectedObject({
  required BuildContext context,
  required WidgetRef ref,
  required SelectedMapObject selection,
}) async {
  switch (selection.kind) {
    case SelectedMapObjectKind.marker:
      final markers = ref.read(markersProvider).valueOrNull;
      final marker = markers == null
          ? null
          : _findMarkerById(markers, selection.id);
      if (marker == null) {
        return;
      }
      await updateMarkerFromForm(context: context, ref: ref, marker: marker);
    case SelectedMapObjectKind.zone:
      final zone = ref.read(zonesProvider.notifier).zoneById(selection.id);
      if (zone == null) {
        return;
      }
      switch (zone.type) {
        case lineZoneType:
          await updateLineFromForm(context: context, ref: ref, zone: zone);
        case circleZoneType:
          await updateCircleFromForm(context: context, ref: ref, zone: zone);
        case rectangleZoneType:
          await updateRectangleFromForm(
            context: context,
            ref: ref,
            zone: zone,
          );
        default:
          return;
      }
  }
}

MapMarker? _findMarkerById(List<MapMarker> markers, UuidValue id) {
  for (final marker in markers) {
    if (marker.id == id) {
      return marker;
    }
  }
  return null;
}

class _MapObjectDetailsDialog extends ConsumerWidget {
  const _MapObjectDetailsDialog({
    required this.selection,
    required this.onEdit,
  });

  final SelectedMapObject selection;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final measurementUnits = ref.watch(measurementUnitsProvider);

    return switch (selection.kind) {
      SelectedMapObjectKind.marker => _buildMarkerDialog(
          context,
          ref,
          theme,
        ),
      SelectedMapObjectKind.zone => _buildZoneDialog(
          context,
          ref,
          theme,
          measurementUnits,
        ),
    };
  }

  Widget _buildMarkerDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final markersAsync = ref.watch(markersProvider);
    final marker = markersAsync.valueOrNull == null
        ? null
        : _findMarkerById(markersAsync.valueOrNull!, selection.id);

    if (marker == null) {
      return _loadingOrMissingDialog(
        context: context,
        theme: theme,
        loading: markersAsync.isLoading,
        onEdit: onEdit,
      );
    }

    final notes = marker.notes?.trim();

    return _DetailsDialogShell(
      title: marker.name,
      leading: MapMarkerIcon(
        color: parseMarkerColor(marker.color),
        iconName: marker.icon,
        width: 28,
        height: 34,
      ),
      onEdit: onEdit,
      children: [
        _DetailRow(
          label: 'Type',
          value: 'Marker',
        ),
        _DetailRow(
          label: 'Coordinates',
          value: _formatCoordinates(marker.latitude, marker.longitude),
        ),
        _DetailRow(
          label: 'Elevation',
          value: _formatElevation(marker.elevation),
        ),
        _DetailRow(
          label: 'Visibility',
          value: marker.visible ? 'Visible' : 'Hidden',
        ),
        LayerAssignmentRow(
          layerId: marker.layerId,
          onChanged: (layerId) => updateMarkerLayer(
            ref,
            marker: marker,
            layerId: layerId,
          ),
        ),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(markdown: notes),
      ],
    );
  }

  Widget _buildZoneDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    MeasurementUnits measurementUnits,
  ) {
    final zonesAsync = ref.watch(zonesProvider);
    final zone = zonesAsync.valueOrNull == null
        ? null
        : findZoneById(zonesAsync.valueOrNull!, selection.id);

    if (zone == null) {
      return _loadingOrMissingDialog(
        context: context,
        theme: theme,
        loading: zonesAsync.isLoading,
        onEdit: onEdit,
      );
    }

    return switch (zone.type) {
      lineZoneType => _lineDetails(
          ref: ref,
          zone: zone,
          measurementUnits: measurementUnits,
        ),
      circleZoneType => _circleDetails(
          ref: ref,
          zone: zone,
          measurementUnits: measurementUnits,
        ),
      rectangleZoneType => _rectangleDetails(
          ref: ref,
          zone: zone,
          measurementUnits: measurementUnits,
        ),
      _ => _genericZoneDetails(ref: ref, zone: zone),
    };
  }

  Widget _zoneLayerAssignment(WidgetRef ref, MapZone zone) {
    return LayerAssignmentRow(
      layerId: zone.layerId,
      onChanged: (layerId) => updateZoneLayer(
        ref,
        zone: zone,
        layerId: layerId,
      ),
    );
  }

  Widget _lineDetails({
    required WidgetRef ref,
    required MapZone zone,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone);
    }

    final notes = geometry.notes?.trim();
    final distance = formatLineDistance(
      geometry.pathLengthMeters,
      measurementUnits,
    );

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        icon: Icons.timeline,
      ),
      onEdit: onEdit,
      children: [
        const _DetailRow(label: 'Type', value: 'Line'),
        _DetailRow(label: 'Length', value: distance),
        _DetailRow(
          label: 'Start',
          value: _formatLatLng(geometry.start!),
        ),
        _DetailRow(
          label: 'End',
          value: _formatLatLng(geometry.end!),
        ),
        _DetailRow(
          label: 'Visibility',
          value: zone.visible ? 'Visible' : 'Hidden',
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(markdown: notes),
      ],
    );
  }

  Widget _circleDetails({
    required WidgetRef ref,
    required MapZone zone,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone);
    }

    final notes = geometry.notes?.trim();
    final radius = formatCircleSize(
      geometry.radiusMeters,
      measurementUnits,
      CircleSizeDisplay.radius,
    );
    final diameter = formatCircleSize(
      geometry.radiusMeters,
      measurementUnits,
      CircleSizeDisplay.diameter,
    );
    final mapLabel = formatCircleSizeForMapLabel(
      geometry.radiusMeters,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.borderColor),
        icon: Icons.radio_button_unchecked,
      ),
      onEdit: onEdit,
      children: [
        const _DetailRow(label: 'Type', value: 'Circle'),
        _DetailRow(label: 'Radius', value: radius),
        _DetailRow(label: 'Diameter', value: diameter),
        _DetailRow(
          label: 'Center',
          value: _formatLatLng(geometry.center),
        ),
        _DetailRow(
          label: 'Map label',
          value: mapLabel ?? 'None',
        ),
        _DetailRow(
          label: 'Visibility',
          value: zone.visible ? 'Visible' : 'Hidden',
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(markdown: notes),
      ],
    );
  }

  Widget _rectangleDetails({
    required WidgetRef ref,
    required MapZone zone,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = RectangleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone);
    }

    final notes = geometry.notes?.trim();
    final dimensions = formatRectangleDimensions(
      geometry.bounds,
      measurementUnits,
    );
    final area = formatRectangleArea(geometry.bounds, measurementUnits);
    final mapLabel = formatRectangleSizeForMapLabel(
      geometry.bounds,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.borderColor),
        icon: Icons.crop_square,
      ),
      onEdit: onEdit,
      children: [
        _DetailRow(label: 'Type', value: geometry.creationMode.label),
        _DetailRow(label: 'Dimensions', value: dimensions),
        _DetailRow(label: 'Area', value: area),
        _DetailRow(
          label: 'Center',
          value: _formatLatLng(geometry.bounds.center),
        ),
        _DetailRow(
          label: 'Map label',
          value: mapLabel ?? 'None',
        ),
        _DetailRow(
          label: 'Visibility',
          value: zone.visible ? 'Visible' : 'Hidden',
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(markdown: notes),
      ],
    );
  }

  Widget _genericZoneDetails({
    required WidgetRef ref,
    required MapZone zone,
  }) {
    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        icon: Icons.layers,
      ),
      onEdit: onEdit,
      children: [
        _DetailRow(label: 'Type', value: zone.type),
        _DetailRow(
          label: 'Visibility',
          value: zone.visible ? 'Visible' : 'Hidden',
        ),
        _zoneLayerAssignment(ref, zone),
      ],
    );
  }

  Widget _loadingOrMissingDialog({
    required BuildContext context,
    required ThemeData theme,
    required bool loading,
    required VoidCallback onEdit,
  }) {
    return AlertDialog(
      title: const Text('Map object'),
      content: Text(
        loading ? 'Loading details…' : 'This object could not be found.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (!loading)
          TextButton(
            onPressed: onEdit,
            child: const Text('Edit'),
          ),
      ],
    );
  }
}

class _DetailsDialogShell extends StatelessWidget {
  const _DetailsDialogShell({
    required this.title,
    required this.leading,
    required this.onEdit,
    required this.children,
  });

  final String title;
  final Widget leading;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: onEdit,
          child: const Text('Edit'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Notes',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: MapObjectMarkdownBody(markdown: markdown),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneTypeAvatar extends StatelessWidget {
  const _ZoneTypeAvatar({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 18,
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

String _formatCoordinates(double latitude, double longitude) {
  return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

String _formatElevation(double elevation) {
  if (elevation == elevation.roundToDouble()) {
    return '${elevation.toInt()} m';
  }
  return '${elevation.toStringAsFixed(1)} m';
}

String _formatLatLng(LatLng point) {
  return _formatCoordinates(point.latitude, point.longitude);
}
