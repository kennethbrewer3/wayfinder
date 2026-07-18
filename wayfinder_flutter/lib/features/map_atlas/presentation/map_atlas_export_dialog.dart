import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../map/providers/map_providers.dart';
import '../../map/utils/pmtiles_viewport.dart';
import '../../markers/providers/markers_provider.dart';
import '../models/atlas_bounds.dart';
import '../utils/atlas_pdf_builder.dart';
import '../utils/atlas_tiler.dart';

Future<AtlasExportOptions?> showMapAtlasExportDialog({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showDialog<AtlasExportOptions>(
    context: context,
    builder: (context) => const _MapAtlasExportDialog(),
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

class _MapAtlasExportDialog extends StatefulWidget {
  const _MapAtlasExportDialog();

  @override
  State<_MapAtlasExportDialog> createState() => _MapAtlasExportDialogState();
}

class _MapAtlasExportDialogState extends State<_MapAtlasExportDialog> {
  late final TextEditingController _titleController;
  var _coverageMode = AtlasCoverageMode.currentMapView;
  var _gridIndex = 2; // 2×2
  var _pageSize = AtlasPageSize.letterLandscape;
  var _includeMarkerIndex = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Wayfinder Atlas');
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
                segments: [
                  ButtonSegment(
                    value: AtlasCoverageMode.currentMapView,
                    label: Text(l10n.mapAtlasCoverageMapView),
                  ),
                  ButtonSegment(
                    value: AtlasCoverageMode.fitMarkers,
                    label: Text(l10n.mapAtlasCoverageMarkers),
                  ),
                ],
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
              ),
            );
          },
          child: Text(l10n.mapAtlasExportButton),
        ),
      ],
    );
  }
}
