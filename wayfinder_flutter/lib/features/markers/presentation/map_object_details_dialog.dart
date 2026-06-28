import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/copy_coordinates.dart';
import '../../markers/utils/marker_share_url.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final measurementUnits = ref.watch(measurementUnitsProvider);

    return switch (selection.kind) {
      SelectedMapObjectKind.marker => _buildMarkerDialog(
          context,
          ref,
          theme,
          l10n,
        ),
      SelectedMapObjectKind.zone => _buildZoneDialog(
          context,
          ref,
          theme,
          l10n,
          measurementUnits,
        ),
    };
  }

  Widget _buildMarkerDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final markersAsync = ref.watch(markersProvider);
    final marker = markersAsync.valueOrNull == null
        ? null
        : _findMarkerById(markersAsync.valueOrNull!, selection.id);

    if (marker == null) {
      return _loadingOrMissingDialog(
        context: context,
        theme: theme,
        l10n: l10n,
        loading: markersAsync.isLoading,
        onEdit: onEdit,
      );
    }

    final notes = marker.notes?.trim();
    final shareUrl = buildMarkerShareUrl(marker: marker);
    void copyShareUrl() => copyTextWithFeedback(
          context,
          text: shareUrl,
          copiedMessage: l10n.mapMarkerUrlCopied,
        );

    return _DetailsDialogShell(
      title: marker.name,
      leading: MapMarkerIcon(
        color: parseMarkerColor(marker.color),
        iconName: marker.icon,
        width: 28,
        height: 34,
      ),
      onEdit: onEdit,
      l10n: l10n,
      shareUrl: shareUrl,
      onCopyShareUrl: copyShareUrl,
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: l10n.mapObjectTypeMarker,
        ),
        _DetailRow(
          label: l10n.mapMarkerIdLabel,
          value: marker.id.toString(),
          onCopy: () => copyTextWithFeedback(
            context,
            text: marker.id.toString(),
            copiedMessage: l10n.mapMarkerIdCopied,
          ),
          copyTooltip: l10n.mapMarkerCopyIdTooltip,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailCoordinates,
          value: formatCoordinates(marker.latitude, marker.longitude),
          onCopy: () => copyCoordinatesToClipboard(
            context,
            LatLng(marker.latitude, marker.longitude),
          ),
          copyTooltip: l10n.mapRadialCopyCoordinates,
        ),
        _MarkerShareLinkSection(
          label: l10n.mapMarkerShareUrlLabel,
          url: shareUrl,
          copyLabel: l10n.mapMarkerCopyUrlTooltip,
          onCopy: copyShareUrl,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailElevation,
          value: _formatElevation(marker.elevation),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: marker.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
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
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _buildZoneDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
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
        l10n: l10n,
        loading: zonesAsync.isLoading,
        onEdit: onEdit,
      );
    }

    return switch (zone.type) {
      lineZoneType => _lineDetails(
          ref: ref,
          zone: zone,
          l10n: l10n,
          measurementUnits: measurementUnits,
        ),
      circleZoneType => _circleDetails(
          ref: ref,
          zone: zone,
          l10n: l10n,
          measurementUnits: measurementUnits,
        ),
      rectangleZoneType => _rectangleDetails(
          ref: ref,
          zone: zone,
          l10n: l10n,
          measurementUnits: measurementUnits,
        ),
      _ => _genericZoneDetails(ref: ref, zone: zone, l10n: l10n),
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
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
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
      l10n: l10n,
      children: [
        _DetailRow(label: l10n.mapObjectDetailType, value: l10n.mapObjectTypeLine),
        _DetailRow(label: l10n.mapObjectDetailLength, value: distance),
        _DetailRow(
          label: l10n.mapObjectDetailStart,
          value: _formatLatLng(geometry.start!),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailEnd,
          value: _formatLatLng(geometry.end!),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _circleDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = CircleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
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
      l10n: l10n,
      children: [
        _DetailRow(label: l10n.mapObjectDetailType, value: l10n.mapObjectTypeCircle),
        _DetailRow(label: l10n.mapObjectDetailRadius, value: radius),
        _DetailRow(label: l10n.mapObjectDetailDiameter, value: diameter),
        _DetailRow(
          label: l10n.mapObjectDetailCenter,
          value: _formatLatLng(geometry.center),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailMapLabel,
          value: mapLabel ?? l10n.mapObjectMapLabelNone,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _rectangleDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
    required MeasurementUnits measurementUnits,
  }) {
    final geometry = RectangleGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return _genericZoneDetails(ref: ref, zone: zone, l10n: l10n);
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
      l10n: l10n,
      children: [
        _DetailRow(
          label: l10n.mapObjectDetailType,
          value: switch (geometry.creationMode) {
            RectangleCreationMode.centerExtent => l10n.rectangleModeCenter,
            RectangleCreationMode.corners => l10n.rectangleModeCorners,
          },
        ),
        _DetailRow(label: l10n.mapObjectDetailDimensions, value: dimensions),
        _DetailRow(label: l10n.mapObjectDetailArea, value: area),
        _DetailRow(
          label: l10n.mapObjectDetailCenter,
          value: _formatLatLng(geometry.bounds.center),
        ),
        _DetailRow(
          label: l10n.mapObjectDetailMapLabel,
          value: mapLabel ?? l10n.mapObjectMapLabelNone,
        ),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
        if (notes != null && notes.isNotEmpty)
          _NotesSection(l10n: l10n, markdown: notes),
      ],
    );
  }

  Widget _genericZoneDetails({
    required WidgetRef ref,
    required MapZone zone,
    required AppLocalizations l10n,
  }) {
    return _DetailsDialogShell(
      title: zone.name,
      leading: _ZoneTypeAvatar(
        color: parseMarkerColor(zone.color),
        icon: Icons.layers,
      ),
      onEdit: onEdit,
      l10n: l10n,
      children: [
        _DetailRow(label: l10n.mapObjectDetailType, value: zone.type),
        _DetailRow(
          label: l10n.mapObjectDetailVisibility,
          value: zone.visible
              ? l10n.mapObjectVisibilityVisible
              : l10n.mapObjectVisibilityHidden,
        ),
        _zoneLayerAssignment(ref, zone),
      ],
    );
  }

  Widget _loadingOrMissingDialog({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required bool loading,
    required VoidCallback onEdit,
  }) {
    return AlertDialog(
      title: Text(l10n.mapObjectDetailsTitle),
      content: Text(
        loading
            ? l10n.mapObjectDetailsLoading
            : l10n.mapObjectDetailsNotFound,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        if (!loading)
          TextButton(
            onPressed: onEdit,
            child: Text(l10n.actionEdit),
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
    required this.l10n,
    required this.children,
    this.shareUrl,
    this.onCopyShareUrl,
  });

  final String title;
  final Widget leading;
  final VoidCallback onEdit;
  final AppLocalizations l10n;
  final List<Widget> children;
  final String? shareUrl;
  final VoidCallback? onCopyShareUrl;

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
        if (shareUrl != null && onCopyShareUrl != null)
          TextButton.icon(
            onPressed: onCopyShareUrl,
            icon: const Icon(Icons.link),
            label: Text(l10n.mapMarkerCopyUrlTooltip),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        FilledButton(
          onPressed: onEdit,
          child: Text(l10n.actionEdit),
        ),
      ],
    );
  }
}

class _MarkerShareLinkSection extends StatelessWidget {
  const _MarkerShareLinkSection({
    required this.label,
    required this.url,
    required this.copyLabel,
    required this.onCopy,
  });

  final String label;
  final String url;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            url,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.link, size: 18),
              label: Text(copyLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.onCopy,
    this.copyTooltip,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;
  final String? copyTooltip;

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
            child: onCopy != null
                ? SelectableText(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          if (onCopy != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              tooltip: copyTooltip,
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
            ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.l10n, required this.markdown});

  final AppLocalizations l10n;
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
            l10n.formNotesLabel,
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

String _formatElevation(double elevation) {
  if (elevation == elevation.roundToDouble()) {
    return '${elevation.toInt()} m';
  }
  return '${elevation.toStringAsFixed(1)} m';
}

String _formatLatLng(LatLng point) {
  return formatLatLng(point);
}
