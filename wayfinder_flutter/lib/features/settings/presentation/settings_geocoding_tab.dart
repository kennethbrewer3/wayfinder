import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/file_save.dart';
import '../../../core/logging/app_logger.dart';
import '../../geocoding/data/geocoding_repository.dart';
import '../../geocoding/models/geocoding_datasets.dart';
import '../../geocoding/models/geocoding_models.dart';
import '../../geocoding/providers/geocoding_providers.dart';

class SettingsGeocodingTab extends ConsumerStatefulWidget {
  const SettingsGeocodingTab({super.key});

  @override
  ConsumerState<SettingsGeocodingTab> createState() =>
      _SettingsGeocodingTabState();
}

class _SettingsGeocodingTabState extends ConsumerState<SettingsGeocodingTab> {
  static final _log = AppLogger.logSettings;

  GeocodingDatasetOption _selectedDataset = geocodingDatasetOptions.first;
  final _customUrlController = TextEditingController();
  final _housenumbersUrlController = TextEditingController(
    text: geocodingHousenumbersSourceUrl,
  );
  bool _initializedFromServer = false;
  bool _isStartingPlacesImport = false;
  bool _isStartingHousenumbersImport = false;
  bool _isPlacesArchiveBusy = false;
  bool _isHousenumbersArchiveBusy = false;
  Timer? _pollTimer;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _customUrlController.dispose();
    _housenumbersUrlController.dispose();
    super.dispose();
  }

  void _syncFromServer(GeocodingImportState settings) {
    if (_initializedFromServer) {
      return;
    }

    _selectedDataset = GeocodingDatasetOption.match(
      sourceUrl: settings.sourceUrl,
      countryCodes: settings.countryCodes,
    );
    _customUrlController.text = _selectedDataset.isCustom
        ? settings.sourceUrl
        : settings.sourceUrl;
    _housenumbersUrlController.text = settings.housenumbersSourceUrl;
    _initializedFromServer = true;
  }

  void _schedulePolling({required bool isRunning}) {
    _pollTimer?.cancel();
    if (!isRunning) {
      return;
    }
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      refreshGeocoding(ref);
    });
  }

  String? _selectedDescription() {
    if (_selectedDataset.isCustom) {
      return _selectedDataset.description;
    }
    if (_selectedDataset.isFullPlanet) {
      return geocodingPlanetImportWarning;
    }
    if (_selectedDataset.usesPlanetDownload &&
        _selectedDataset.countryCodes.isNotEmpty) {
      return '${_selectedDataset.description ?? ''}\n\n$geocodingCountryImportDownloadNote'
          .trim();
    }
    return _selectedDataset.description;
  }

  Future<void> _downloadAndImportPlaces() async {
    final sourceUrl = _selectedDataset.isCustom
        ? _customUrlController.text.trim()
        : _selectedDataset.sourceUrl;
    if (sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geocoding source URL is required.')),
      );
      return;
    }

    final countryCodes = _selectedDataset.isCustom ||
            _selectedDataset.isFullPlanet ||
            _selectedDataset.isSample
        ? null
        : _selectedDataset.countryCodes;

    setState(() => _isStartingPlacesImport = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      await repository.updateImportConfig(
        sourceUrl: sourceUrl,
        countryCodes: countryCodes,
      );
      await repository.startImport(
        sourceUrl: sourceUrl,
        countryCodes: countryCodes,
      );
      refreshGeocoding(ref);
      _schedulePolling(isRunning: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedDataset.isFullPlanet
                ? 'Full planet place import started. This can take many hours.'
                : 'Place-name import started.',
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Geocoding import start failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Place import failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingPlacesImport = false);
      }
    }
  }

  Future<void> _downloadAndImportHousenumbers() async {
    final sourceUrl = _housenumbersUrlController.text.trim();
    if (sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Housenumbers source URL is required.')),
      );
      return;
    }

    setState(() => _isStartingHousenumbersImport = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      await repository.startHousenumbersImport(sourceUrl: sourceUrl);
      refreshGeocoding(ref);
      _schedulePolling(isRunning: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Housenumbers import started. This can take many hours.',
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumbers import start failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Housenumbers import failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingHousenumbersImport = false);
      }
    }
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _exportPlacesArchive() async {
    setState(() => _isPlacesArchiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final jsonText = await repository.exportPlacesArchive();
      final timestamp =
          DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final saved = await saveTextFile(
        fileName: 'wayfinder-geocode-places-$timestamp.json',
        contents: jsonText,
      );
      if (!mounted) return;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place data exported.')),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Place archive export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacesArchiveBusy = false);
      }
    }
  }

  Future<void> _importPlacesArchive() async {
    final jsonText = await pickTextFileContents();
    if (jsonText == null || !mounted) {
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Import place archive?',
      message:
          'This replaces all place-name records on the server with the selected '
          'archive file.',
      confirmLabel: 'Import',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isPlacesArchiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final rowCount = await repository.importPlacesArchive(jsonText);
      refreshGeocoding(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $rowCount place record(s).')),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Place archive import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacesArchiveBusy = false);
      }
    }
  }

  Future<void> _clearPlaces() async {
    final confirmed = await _confirmAction(
      title: 'Remove all place records?',
      message:
          'This permanently deletes every place-name record from the server. '
          'This cannot be undone.',
      confirmLabel: 'Remove all',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isPlacesArchiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final removed = await repository.clearPlaces();
      refreshGeocoding(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed $removed place record(s).')),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Place clear failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacesArchiveBusy = false);
      }
    }
  }

  Future<void> _exportHousenumbersArchive() async {
    setState(() => _isHousenumbersArchiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final jsonText = await repository.exportHousenumbersArchive();
      final timestamp =
          DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final saved = await saveTextFile(
        fileName: 'wayfinder-geocode-housenumbers-$timestamp.json',
        contents: jsonText,
      );
      if (!mounted) return;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Housenumber data exported.')),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumber archive export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isHousenumbersArchiveBusy = false);
      }
    }
  }

  Future<void> _importHousenumbersArchive() async {
    final jsonText = await pickTextFileContents();
    if (jsonText == null || !mounted) {
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Import housenumber archive?',
      message:
          'This replaces all street-address records on the server with the '
          'selected archive file.',
      confirmLabel: 'Import',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isHousenumbersArchiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final rowCount = await repository.importHousenumbersArchive(jsonText);
      refreshGeocoding(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $rowCount address record(s).')),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumber archive import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isHousenumbersArchiveBusy = false);
      }
    }
  }

  Future<void> _clearHousenumbers() async {
    final confirmed = await _confirmAction(
      title: 'Remove all address records?',
      message:
          'This permanently deletes every housenumber record from the server. '
          'This cannot be undone.',
      confirmLabel: 'Remove all',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isHousenumbersArchiveBusy = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      final removed = await repository.clearHousenumbers();
      refreshGeocoding(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed $removed address record(s).')),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumber clear failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isHousenumbersArchiveBusy = false);
      }
    }
  }

  Widget _buildArchiveActions({
    required bool enabled,
    required bool busy,
    required VoidCallback onExport,
    required VoidCallback onImport,
    required VoidCallback onRemoveAll,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: enabled && !busy ? onExport : null,
          icon: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_outlined),
          label: const Text('Export'),
        ),
        OutlinedButton.icon(
          onPressed: enabled && !busy ? onImport : null,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Import'),
        ),
        OutlinedButton.icon(
          onPressed: enabled && !busy ? onRemoveAll : null,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Remove all'),
        ),
      ],
    );
  }

  String _importStatusLabel({
    required String status,
    required int rowCount,
    required String readyLabel,
  }) {
    return switch (status) {
      geocodingStatusIdle => 'Not imported',
      geocodingStatusDownloading => 'Downloading…',
      geocodingStatusImporting => 'Importing…',
      geocodingStatusCompleted => 'Ready ($rowCount $readyLabel)',
      geocodingStatusFailed => 'Failed',
      _ => status,
    };
  }

  String _activeDatasetLabel(GeocodingImportState settings) {
    final option = GeocodingDatasetOption.match(
      sourceUrl: settings.sourceUrl,
      countryCodes: settings.countryCodes,
    );
    if (option.isCustom) {
      return 'Custom URL';
    }
    return option.label;
  }

  Widget _buildImportProgress({
    required bool isRunning,
    required double progress,
    required int importedRowCount,
    required String rowLabel,
  }) {
    if (!isRunning) {
      return const SizedBox.shrink();
    }

    final progressPercent =
        (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text(
          '$progressPercent% · $importedRowCount $rowLabel imported',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(geocodingSettingsProvider);
    final description = _selectedDescription();

    ref.listen(geocodingSettingsProvider, (previous, next) {
      next.whenData((settings) {
        _schedulePolling(isRunning: settings.isRunning);
      });
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Geocoding',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Download OSMNames data to the server for offline search. Place names '
          'and street addresses are imported separately.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        settingsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Failed to load geocoding settings: $error'),
          data: (settings) {
            _syncFromServer(settings);
            final placesControlsEnabled = !settings.isPlacesRunning &&
                !_isStartingPlacesImport &&
                !_isPlacesArchiveBusy &&
                !settings.isHousenumbersRunning;
            final housenumbersControlsEnabled =
                !settings.isHousenumbersRunning &&
                    !_isStartingHousenumbersImport &&
                    !_isHousenumbersArchiveBusy &&
                    !settings.isPlacesRunning;
            final placesArchiveEnabled =
                !settings.isRunning && !_isPlacesArchiveBusy;
            final housenumbersArchiveEnabled =
                !settings.isRunning && !_isHousenumbersArchiveBusy;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Place names (geonames.tsv)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  geocodingPlanetImportWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GeocodingDatasetOption>(
                  key: ValueKey(_selectedDataset.id),
                  initialValue: _selectedDataset,
                  decoration: const InputDecoration(
                    labelText: 'Place dataset',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final option in geocodingDatasetOptions)
                      DropdownMenuItem(
                        value: option,
                        child: Text(option.label),
                      ),
                  ],
                  onChanged: placesControlsEnabled
                      ? (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedDataset = value;
                            if (!value.isCustom) {
                              _customUrlController.text = value.sourceUrl;
                            }
                          });
                        }
                      : null,
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_selectedDataset.isCustom) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Custom place data URL',
                      hintText: geocodingPlanetSourceUrl,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.url],
                    enabled: placesControlsEnabled,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Status: ${_importStatusLabel(
                    status: settings.importStatus,
                    rowCount: settings.importedRowCount,
                    readyLabel: 'places',
                  )}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (settings.importStatus != geocodingStatusIdle) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last selection: ${_activeDatasetLabel(settings)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                _buildImportProgress(
                  isRunning: settings.isPlacesRunning,
                  progress: settings.importProgress,
                  importedRowCount: settings.importedRowCount,
                  rowLabel: 'rows',
                ),
                if (!settings.isPlacesRunning && settings.importedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last import: ${settings.importedAt!.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (settings.importError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    settings.importError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Archive place data as a JSON file, restore from a previous '
                  'export, or remove all records from the server.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _buildArchiveActions(
                  enabled: placesArchiveEnabled,
                  busy: _isPlacesArchiveBusy,
                  onExport: _exportPlacesArchive,
                  onImport: _importPlacesArchive,
                  onRemoveAll: _clearPlaces,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed:
                      placesControlsEnabled ? _downloadAndImportPlaces : null,
                  icon: _isStartingPlacesImport || settings.isPlacesRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download_outlined),
                  label: Text(
                    settings.isPlacesRunning
                        ? 'Place import in progress…'
                        : 'Download and import places',
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Street addresses (housenumbers.tsv)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  geocodingHousenumbersImportWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _housenumbersUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Housenumbers data URL',
                    hintText: geocodingHousenumbersSourceUrl,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.url],
                  enabled: housenumbersControlsEnabled,
                ),
                const SizedBox(height: 12),
                Text(
                  'Status: ${_importStatusLabel(
                    status: settings.housenumbersImportStatus,
                    rowCount: settings.housenumbersImportedRowCount,
                    readyLabel: 'addresses',
                  )}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                _buildImportProgress(
                  isRunning: settings.isHousenumbersRunning,
                  progress: settings.housenumbersImportProgress,
                  importedRowCount: settings.housenumbersImportedRowCount,
                  rowLabel: 'addresses',
                ),
                if (!settings.isHousenumbersRunning &&
                    settings.housenumbersImportedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last import: ${settings.housenumbersImportedAt!.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (settings.housenumbersImportError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    settings.housenumbersImportError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Archive address data as a separate JSON file, restore from a '
                  'previous export, or remove all records from the server.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _buildArchiveActions(
                  enabled: housenumbersArchiveEnabled,
                  busy: _isHousenumbersArchiveBusy,
                  onExport: _exportHousenumbersArchive,
                  onImport: _importHousenumbersArchive,
                  onRemoveAll: _clearHousenumbers,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: housenumbersControlsEnabled
                      ? _downloadAndImportHousenumbers
                      : null,
                  icon: _isStartingHousenumbersImport ||
                          settings.isHousenumbersRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.home_work_outlined),
                  label: Text(
                    settings.isHousenumbersRunning
                        ? 'Address import in progress…'
                        : 'Download and import housenumbers',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
