import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../evac_kits/utils/evac_kit_eta.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/map_providers.dart';
import '../../map/utils/pmtiles_viewport.dart';
import '../../markers/providers/markers_provider.dart';
import '../../routing/presentation/routing_profile_picker.dart';
import '../../routing/providers/routing_session_provider.dart';
import '../models/atlas_bounds.dart';
import '../utils/atlas_pdf_builder.dart';
import '../utils/atlas_tiler.dart';

Future<AtlasExportOptions?> showMapAtlasExportDialog({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final hasRoute = ref.read(routingSessionProvider).hasRoute;
  return showDialog<AtlasExportOptions>(
    context: context,
    builder: (context) => _MapAtlasExportDialog(hasActiveRoute: hasRoute),
  );
}

/// Resolves atlas coverage from dialog options and current app state.
AtlasBounds? resolveAtlasCoverage({
  required AtlasExportOptions options,
  required WidgetRef ref,
}) {
  switch (options.coverageMode) {
    case AtlasCoverageMode.fitMarkers:
      final markers = ref.read(markersProvider).valueOrNull ?? const [];
      return AtlasBounds.fromMarkers(markers);
    case AtlasCoverageMode.fitActiveRoute:
      final result = ref.read(routingSessionProvider).result;
      if (result == null || result.points.length < 2) {
        return null;
      }
      return AtlasBounds.fromLatLngs([
        for (final point in result.points) LatLng(point.lat, point.lon),
      ]);
    case AtlasCoverageMode.currentMapView:
      final viewport = ref.read(mapViewportProvider).valueOrNull;
      if (viewport == null) {
        return null;
      }
      final bounds = approximateVisibleBounds(
        viewport,
        mapSize: const Size(1200, 800),
      );
      return AtlasBounds(
        south: bounds.south,
        west: bounds.west,
        north: bounds.north,
        east: bounds.east,
      );
  }
}

/// Builds printable route overlay data from the active routing session.
AtlasRouteExport? buildAtlasRouteExport({
  required WidgetRef ref,
  required AppLocalizations l10n,
}) {
  final session = ref.read(routingSessionProvider);
  final result = session.result;
  if (result == null || result.points.length < 2) {
    return null;
  }
  final units = ref.read(measurementUnitsProvider);
  final profileText = routingProfileLabel(l10n, session.profile);
  final distance = formatLineDistance(result.distanceMeters, units);
  final duration = formatEvacDuration(
    Duration(milliseconds: result.timeMs),
  );
  return AtlasRouteExport(
    points: [
      for (final point in result.points) LatLng(point.lat, point.lon),
    ],
    steps: [
      for (final instruction in result.instructions)
        if (instruction.text.trim().isNotEmpty)
          AtlasDirectionStep(
            text: instruction.text.trim(),
            distanceLabel: formatLineDistance(
              instruction.distanceMeters,
              units,
            ),
          ),
    ],
    summaryLine: l10n.routingRouteSummaryWithProfile(
      profileText,
      distance,
      duration,
    ),
    destinationLabel: session.destinationLabel,
    directionsTitle: l10n.routingDirectionsTitle,
    stepColumnLabel: l10n.mapAtlasDirectionsStepColumn,
    instructionColumnLabel: l10n.mapAtlasDirectionsInstructionColumn,
    distanceColumnLabel: l10n.mapAtlasDirectionsDistanceColumn,
  );
}

class _MapAtlasExportDialog extends StatefulWidget {
  const _MapAtlasExportDialog({required this.hasActiveRoute});

  final bool hasActiveRoute;

  @override
  State<_MapAtlasExportDialog> createState() => _MapAtlasExportDialogState();
}

class _MapAtlasExportDialogState extends State<_MapAtlasExportDialog> {
  late final TextEditingController _titleController;
  late AtlasCoverageMode _coverageMode;
  var _gridIndex = 2; // 2×2
  var _pageSize = AtlasPageSize.letterLandscape;
  var _includeMarkerIndex = true;
  late bool _includeActiveRoute;
  late bool _includeDirectionsList;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Wayfinder Atlas');
    _coverageMode = widget.hasActiveRoute
        ? AtlasCoverageMode.fitActiveRoute
        : AtlasCoverageMode.currentMapView;
    _includeActiveRoute = widget.hasActiveRoute;
    _includeDirectionsList = widget.hasActiveRoute;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final grid = atlasGridPresets[_gridIndex];
    final coverageSegments = <ButtonSegment<AtlasCoverageMode>>[
      ButtonSegment(
        value: AtlasCoverageMode.currentMapView,
        label: Text(l10n.mapAtlasCoverageMapView),
      ),
      ButtonSegment(
        value: AtlasCoverageMode.fitMarkers,
        label: Text(l10n.mapAtlasCoverageMarkers),
      ),
      if (widget.hasActiveRoute)
        ButtonSegment(
          value: AtlasCoverageMode.fitActiveRoute,
          label: Text(l10n.mapAtlasCoverageActiveRoute),
        ),
    ];

    return AlertDialog(
      title: Text(l10n.mapAtlasDialogTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.mapAtlasDialogDescription),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.mapAtlasTitleLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.mapAtlasCoverageLabel),
              const SizedBox(height: 4),
              SegmentedButton<AtlasCoverageMode>(
                segments: coverageSegments,
                selected: {_coverageMode},
                onSelectionChanged: (selected) {
                  setState(() => _coverageMode = selected.first);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _gridIndex,
                decoration: InputDecoration(
                  labelText: l10n.mapAtlasGridLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (var i = 0; i < atlasGridPresets.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(atlasGridPresets[i].label),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _gridIndex = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AtlasPageSize>(
                initialValue: _pageSize,
                decoration: InputDecoration(
                  labelText: l10n.mapAtlasPageSizeLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: AtlasPageSize.letterLandscape,
                    child: Text(l10n.mapAtlasPageLetter),
                  ),
                  DropdownMenuItem(
                    value: AtlasPageSize.a4Landscape,
                    child: Text(l10n.mapAtlasPageA4),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _pageSize = value);
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeMarkerIndex,
                onChanged: (value) {
                  setState(() => _includeMarkerIndex = value ?? true);
                },
                title: Text(l10n.mapAtlasIncludeMarkerIndex),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (widget.hasActiveRoute) ...[
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeActiveRoute,
                  onChanged: (value) {
                    setState(() => _includeActiveRoute = value ?? false);
                  },
                  title: Text(l10n.mapAtlasIncludeActiveRoute),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeDirectionsList,
                  onChanged: (value) {
                    setState(() => _includeDirectionsList = value ?? false);
                  },
                  title: Text(l10n.mapAtlasIncludeDirectionsList),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
              Text(
                '${l10n.mapAtlasSheetCountHint}: ${grid.columns * grid.rows}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            Navigator.of(context).pop(
              AtlasExportOptions(
                title: title.isEmpty ? 'Wayfinder Atlas' : title,
                coverageMode: _coverageMode,
                columns: grid.columns,
                rows: grid.rows,
                pageSize: _pageSize,
                includeMarkerIndex: _includeMarkerIndex,
                includeActiveRoute:
                    widget.hasActiveRoute && _includeActiveRoute,
                includeDirectionsList:
                    widget.hasActiveRoute && _includeDirectionsList,
              ),
            );
          },
          child: Text(l10n.mapAtlasExportButton),
        ),
      ],
    );
  }
}
