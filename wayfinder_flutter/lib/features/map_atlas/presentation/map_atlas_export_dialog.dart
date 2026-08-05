import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../comms_plan/models/comms_card_of_the_day.dart';
import '../../comms_plan/models/comms_challenge_table.dart';
import '../../comms_plan/models/comms_one_time_pad.dart';
import '../../comms_plan/providers/comms_plan_provider.dart';
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
  final plans = ref.read(commsPlansProvider).valueOrNull ?? const [];
  final active = activeCommsPlan(plans);
  final hasChallengeTable = decodeCommsChallengeTables(
    active?.challengeTableJson,
  ).isNotEmpty;
  final hasOneTimePad = decodeCommsOneTimePads(
    active?.oneTimePadJson,
  ).isNotEmpty;
  final hasCardOfTheDay = decodeCommsCardsOfTheDay(
    active?.cardOfTheDayJson,
  ).isNotEmpty;
  return showDialog<AtlasExportOptions>(
    context: context,
    builder: (context) => _MapAtlasExportDialog(
      hasActiveRoute: hasRoute,
      hasCommsChallengeTable: hasChallengeTable,
      hasCommsOneTimePad: hasOneTimePad,
      hasCommsCardOfTheDay: hasCardOfTheDay,
    ),
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
  const _MapAtlasExportDialog({
    required this.hasActiveRoute,
    required this.hasCommsChallengeTable,
    required this.hasCommsOneTimePad,
    required this.hasCommsCardOfTheDay,
  });

  final bool hasActiveRoute;
  final bool hasCommsChallengeTable;
  final bool hasCommsOneTimePad;
  final bool hasCommsCardOfTheDay;

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
  late bool _includeCommsChallengeTable;
  late bool _includeCommsOneTimePad;
  late bool _includeCommsCardOfTheDay;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Wayfinder Atlas');
    _coverageMode = widget.hasActiveRoute
        ? AtlasCoverageMode.fitActiveRoute
        : AtlasCoverageMode.currentMapView;
    _includeActiveRoute = widget.hasActiveRoute;
    _includeDirectionsList = widget.hasActiveRoute;
    _includeCommsChallengeTable = widget.hasCommsChallengeTable;
    _includeCommsOneTimePad = widget.hasCommsOneTimePad;
    _includeCommsCardOfTheDay = widget.hasCommsCardOfTheDay;
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
              if (widget.hasCommsChallengeTable)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeCommsChallengeTable,
                  onChanged: (value) {
                    setState(
                      () => _includeCommsChallengeTable = value ?? false,
                    );
                  },
                  title: Text(l10n.mapAtlasIncludeCommsChallengeTable),
                  subtitle: Text(l10n.mapAtlasIncludeCommsChallengeTableHint),
                  controlAffinity: ListTileControlAffinity.leading,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.mapAtlasCommsChallengeTableUnavailable,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (widget.hasCommsOneTimePad)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeCommsOneTimePad,
                  onChanged: (value) {
                    setState(() => _includeCommsOneTimePad = value ?? false);
                  },
                  title: Text(l10n.mapAtlasIncludeCommsOneTimePad),
                  subtitle: Text(l10n.mapAtlasIncludeCommsOneTimePadHint),
                  controlAffinity: ListTileControlAffinity.leading,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.mapAtlasCommsOneTimePadUnavailable,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (widget.hasCommsCardOfTheDay)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeCommsCardOfTheDay,
                  onChanged: (value) {
                    setState(() => _includeCommsCardOfTheDay = value ?? false);
                  },
                  title: Text(l10n.mapAtlasIncludeCommsCardOfTheDay),
                  subtitle: Text(l10n.mapAtlasIncludeCommsCardOfTheDayHint),
                  controlAffinity: ListTileControlAffinity.leading,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.mapAtlasCommsCardOfTheDayUnavailable,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
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
                includeCommsChallengeTable:
                    widget.hasCommsChallengeTable &&
                    _includeCommsChallengeTable,
                includeCommsOneTimePad:
                    widget.hasCommsOneTimePad && _includeCommsOneTimePad,
                includeCommsCardOfTheDay:
                    widget.hasCommsCardOfTheDay && _includeCommsCardOfTheDay,
              ),
            );
          },
          child: Text(l10n.mapAtlasExportButton),
        ),
      ],
    );
  }
}
