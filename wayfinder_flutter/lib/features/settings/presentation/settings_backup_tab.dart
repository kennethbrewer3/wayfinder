import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../geo_exchange/data/geo_exchange_service.dart';
import '../../geo_exchange/models/geo_exchange_models.dart';
import '../../geo_exchange/utils/geo_exchange_codec.dart';
import '../../layers/providers/layers_provider.dart';
import '../../map_atlas/presentation/map_atlas_export_action.dart';
import '../../markers/providers/markers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../models/pmtiles_file.dart';
import '../providers/map_data_providers.dart';
import '../providers/pmtiles_providers.dart';

class SettingsBackupTab extends ConsumerStatefulWidget {
  const SettingsBackupTab({super.key});

  @override
  ConsumerState<SettingsBackupTab> createState() => _SettingsBackupTabState();
}

class _SettingsBackupTabState extends ConsumerState<SettingsBackupTab> {
  static final _log = AppLogger.logSettings;

  bool _isExportingMapData = false;
  bool _isRestoringMapData = false;
  bool _isExportingFieldPack = false;
  bool _isRestoringFieldPack = false;
  bool _isImportingGeo = false;
  bool _isExportingGeo = false;
  bool _isExportingAtlas = false;

  Future<void> _exportMapData() async {
    setState(() => _isExportingMapData = true);
    try {
      final repository = ref.read(mapDataRepositoryProvider);
      final archiveBytes = await repository.fetchBackupArchive();
      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final saved = await saveBinaryFile(
        fileName: 'wayfinder-backup-$timestamp.zip',
        bytes: archiveBytes,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupExportSuccess)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '💾 Map data export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupExportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingMapData = false);
      }
    }
  }

  Future<void> _restoreMapData() async {
    final picked = await pickBackupFile();
    if (picked == null || !mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.backupRestoreConfirmTitle),
          content: Text(l10n.backupRestoreConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionRestore),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isRestoringMapData = true);
    try {
      final repository = ref.read(mapDataRepositoryProvider);
      final result = picked.isZip
          ? await repository.restoreFromArchive(picked.zipBytes!)
          : await repository.restoreFromJson(picked.jsonText!);
      refreshMapData(ref);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.markerIcons > 0
                ? l10n.backupRestoreSuccessWithIcons(
                    result.layers,
                    result.markers,
                    result.zones,
                    result.seasonalOverlays,
                    result.watchLogEntries,
                    result.markerIcons,
                  )
                : l10n.backupRestoreSuccess(
                    result.layers,
                    result.markers,
                    result.zones,
                    result.seasonalOverlays,
                    result.watchLogEntries,
                  ),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '💾 Map data restore failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupRestoreFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoringMapData = false);
      }
    }
  }

  Future<GeoImportMode?> _confirmGeoImportMode({
    required int markerCount,
    required int zoneCount,
  }) {
    return showDialog<GeoImportMode>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.geoExchangeImportConfirmTitle),
          content: Text(
            l10n.geoExchangeImportConfirmMessage(markerCount, zoneCount),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(GeoImportMode.add),
              child: Text(l10n.geoExchangeImportAdd),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(GeoImportMode.replace),
              child: Text(l10n.geoExchangeImportReplace),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importGeoExchange() async {
    final picked = await pickGeoExchangeFile();
    if (picked == null || !mounted) {
      return;
    }

    setState(() => _isImportingGeo = true);
    try {
      final bundle = parseGeoExchange(
        contents: picked.contents,
        fileName: picked.fileName,
      );
      final l10n = AppLocalizations.of(context)!;
      if (bundle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.geoExchangeImportEmpty)),
        );
        return;
      }

      final markers = await ref.read(markersProvider.future);
      final zones = await ref.read(zonesProvider.future);
      var mode = GeoImportMode.add;
      if (markers.isNotEmpty || zones.isNotEmpty) {
        setState(() => _isImportingGeo = false);
        final chosen = await _confirmGeoImportMode(
          markerCount: markers.length,
          zoneCount: zones.length,
        );
        if (chosen == null || !mounted) {
          return;
        }
        mode = chosen;
        setState(() => _isImportingGeo = true);
      }

      final client = ref.read(serverClientProvider);
      final result = await importGeoExchangeBundle(
        client: client,
        bundle: bundle,
        layerId: selectedLayerIdForCreate(ref),
        mode: mode,
      );
      refreshMapData(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.geoExchangeImportSuccess(
              result.markersCreated,
              result.linesCreated,
            ),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '📍 Geo exchange import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geoExchangeImportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isImportingGeo = false);
      }
    }
  }

  Future<void> _exportMapAtlas() async {
    setState(() => _isExportingAtlas = true);
    try {
      await runMapAtlasExport(context: context, ref: ref);
    } finally {
      if (mounted) {
        setState(() => _isExportingAtlas = false);
      }
    }
  }

  Future<void> _exportFieldPack() async {
    final l10n = AppLocalizations.of(context)!;
    List<PmtilesFile> files;
    try {
      files = await ref.read(pmtilesCatalogProvider.future);
    } catch (error, stackTrace) {
      _log.error(
        '🎒 Field pack: failed to load PMTiles catalog',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fieldPackExportFailed(error.toString()))),
      );
      return;
    }

    if (!mounted) return;
    final selectedIds = await showDialog<Set<String>>(
      context: context,
      builder: (context) => _FieldPackPmtilesPickerDialog(files: files),
    );
    if (selectedIds == null || !mounted) {
      return;
    }

    setState(() => _isExportingFieldPack = true);
    try {
      final bytes = await ref
          .read(fieldPackRepositoryProvider)
          .exportFieldPack(pmtilesIds: selectedIds.toList());
      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final saved = await saveBinaryFile(
        fileName: 'wayfinder-field-$timestamp.wayfinder-field',
        bytes: bytes,
      );
      if (!mounted) return;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fieldPackExportSuccess)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '🎒 Field pack export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fieldPackExportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingFieldPack = false);
      }
    }
  }

  Future<void> _restoreFieldPack() async {
    final picked = await pickFieldPackFile();
    if (picked == null || !mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.fieldPackRestoreConfirmTitle),
          content: Text(l10n.fieldPackRestoreConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionRestore),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isRestoringFieldPack = true);
    try {
      final result = await ref
          .read(fieldPackRepositoryProvider)
          .restoreFieldPack(picked);
      refreshMapData(ref);
      refreshPmtiles(ref);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final map = result.map;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.fieldPackRestoreSuccess(
              map.layers,
              map.markers,
              map.zones,
              map.seasonalOverlays,
              map.watchLogEntries,
              map.markerIcons,
              result.pmtiles,
            ),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🎒 Field pack restore failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fieldPackRestoreFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoringFieldPack = false);
      }
    }
  }

  Future<void> _exportGeoExchange() async {
    final l10n = AppLocalizations.of(context)!;
    final format = await showDialog<GeoExchangeFormat>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(l10n.geoExchangeExportFormatTitle),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(GeoExchangeFormat.gpx),
              child: Text(l10n.geoExchangeFormatGpx),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(GeoExchangeFormat.kml),
              child: Text(l10n.geoExchangeFormatKml),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(GeoExchangeFormat.geojson),
              child: Text(l10n.geoExchangeFormatGeojson),
            ),
          ],
        );
      },
    );
    if (format == null || !mounted) {
      return;
    }

    setState(() => _isExportingGeo = true);
    try {
      final markers = await ref.read(markersProvider.future);
      final zones = await ref.read(zonesProvider.future);
      final text = exportGeoExchangeText(
        markers: markers,
        zones: zones,
        format: format,
      );
      final bundle = bundleFromMapObjects(markers: markers, zones: zones);
      if (bundle.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.geoExchangeExportEmpty)),
        );
        return;
      }

      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final saved = await saveTextFile(
        fileName: 'wayfinder-export-$timestamp.${format.fileExtension}',
        contents: text,
        allowedExtensions: [format.fileExtension],
      );
      if (!mounted) return;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.geoExchangeExportSuccess)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '📍 Geo exchange export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geoExchangeExportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingGeo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.backupTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.backupDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isExportingMapData ? null : _exportMapData,
          icon: _isExportingMapData
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(
            _isExportingMapData
                ? l10n.actionExporting
                : l10n.backupExportButton,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isRestoringMapData ? null : _restoreMapData,
          icon: _isRestoringMapData
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(
            _isRestoringMapData
                ? l10n.actionRestoring
                : l10n.backupRestoreButton,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.fieldPackTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.fieldPackDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isExportingFieldPack ? null : _exportFieldPack,
          icon: _isExportingFieldPack
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.inventory_2_outlined),
          label: Text(
            _isExportingFieldPack
                ? l10n.actionExporting
                : l10n.fieldPackExportButton,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isRestoringFieldPack ? null : _restoreFieldPack,
          icon: _isRestoringFieldPack
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.unarchive_outlined),
          label: Text(
            _isRestoringFieldPack
                ? l10n.actionRestoring
                : l10n.fieldPackRestoreButton,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.geoExchangeTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.geoExchangeDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _isImportingGeo ? null : _importGeoExchange,
          icon: _isImportingGeo
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.file_open),
          label: Text(
            _isImportingGeo
                ? l10n.actionImporting
                : l10n.geoExchangeImportButton,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isExportingGeo ? null : _exportGeoExchange,
          icon: _isExportingGeo
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share),
          label: Text(
            _isExportingGeo
                ? l10n.actionExporting
                : l10n.geoExchangeExportButton,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.mapAtlasTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.mapAtlasDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _isExportingAtlas ? null : _exportMapAtlas,
          icon: _isExportingAtlas
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(
            _isExportingAtlas
                ? l10n.actionExporting
                : l10n.mapAtlasExportButton,
          ),
        ),
      ],
    );
  }
}

class _FieldPackPmtilesPickerDialog extends StatefulWidget {
  const _FieldPackPmtilesPickerDialog({required this.files});

  final List<PmtilesFile> files;

  @override
  State<_FieldPackPmtilesPickerDialog> createState() =>
      _FieldPackPmtilesPickerDialogState();
}

class _FieldPackPmtilesPickerDialogState
    extends State<_FieldPackPmtilesPickerDialog> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    final enabled = widget.files.where((f) => f.enabledOnMap).toList();
    final defaults = enabled.isNotEmpty ? enabled : widget.files;
    _selectedIds = {for (final file in defaults) file.id};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final files = widget.files;

    return AlertDialog(
      title: Text(l10n.fieldPackSelectPmtilesTitle),
      content: SizedBox(
        width: 420,
        child: files.isEmpty
            ? Text(l10n.fieldPackSelectPmtilesEmpty)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.fieldPackSelectPmtilesMessage),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIds
                              ..clear()
                              ..addAll(files.map((f) => f.id));
                          });
                        },
                        child: Text(l10n.fieldPackSelectAll),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(_selectedIds.clear);
                        },
                        child: Text(l10n.fieldPackSelectNone),
                      ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return CheckboxListTile(
                          value: _selectedIds.contains(file.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedIds.add(file.id);
                              } else {
                                _selectedIds.remove(file.id);
                              }
                            });
                          },
                          title: Text(file.name),
                          subtitle: Text(file.formattedSize),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(Set<String>.from(_selectedIds)),
          child: Text(l10n.fieldPackExportConfirm),
        ),
      ],
    );
  }
}
