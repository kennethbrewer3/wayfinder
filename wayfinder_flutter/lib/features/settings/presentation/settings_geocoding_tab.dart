import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/app_globals.dart';
import '../../../core/file_save.dart';
import '../../../core/format/locale_count_format.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/server_config.dart';
import '../../../core/server_config_storage.dart';
import '../../geocoding/data/geocoding_repository.dart';
import '../../geocoding/models/geocoding_datasets.dart';
import '../../geocoding/models/geocoding_models.dart';
import '../../geocoding/presentation/geocoding_import_progress_panel.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import 'settings_geocoding_contributions_section.dart';

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
  late final TextEditingController _geocodingServerUrlController;
  bool _initializedFromServer = false;
  bool _isSavingGeocodingServerUrl = false;
  bool _isStartingPlacesImport = false;
  bool _isStartingHousenumbersImport = false;
  bool _isCancellingPlacesImport = false;
  bool _isCancellingHousenumbersImport = false;
  bool _isPlacesArchiveBusy = false;
  bool _isHousenumbersArchiveBusy = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _geocodingServerUrlController = TextEditingController(
      text: appServerConfig.geocodingWebUrl ?? '',
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _customUrlController.dispose();
    _housenumbersUrlController.dispose();
    _geocodingServerUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveGeocodingServerUrl() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSavingGeocodingServerUrl = true);
    try {
      final trimmed = _geocodingServerUrlController.text.trim();
      final storage = ServerConfigStorage();
      if (trimmed.isEmpty) {
        await storage.clearGeocodingWebUrl();
        ref.read(geocodingWebUrlProvider.notifier).state = null;
      } else {
        final normalized = normalizeWebUrl(trimmed);
        await storage.saveGeocodingWebUrl(normalized);
        ref.read(geocodingWebUrlProvider.notifier).state = normalized;
      }
      refreshGeocoding(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingServerUrlSaved)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Geocoding server URL save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingGeocodingServerUrl = false);
      }
    }
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

  String _datasetLabel(AppLocalizations l10n, GeocodingDatasetOption option) {
    return switch (option.id) {
      'sample' => l10n.geocodingDatasetSample,
      'planet' => l10n.geocodingDatasetPlanet,
      'us' => l10n.geocodingDatasetUs,
      'ca' => l10n.geocodingDatasetCa,
      'mx' => l10n.geocodingDatasetMx,
      'gb' => l10n.geocodingDatasetGb,
      'de' => l10n.geocodingDatasetDe,
      'fr' => l10n.geocodingDatasetFr,
      'es' => l10n.geocodingDatasetEs,
      'it' => l10n.geocodingDatasetIt,
      'nl' => l10n.geocodingDatasetNl,
      'au' => l10n.geocodingDatasetAu,
      'nz' => l10n.geocodingDatasetNz,
      'jp' => l10n.geocodingDatasetJp,
      'br' => l10n.geocodingDatasetBr,
      'in' => l10n.geocodingDatasetIn,
      'custom' => l10n.geocodingDatasetCustom,
      _ => option.label,
    };
  }

  String? _datasetDescription(
    AppLocalizations l10n,
    GeocodingDatasetOption option,
  ) {
    return switch (option.id) {
      'sample' => l10n.geocodingDatasetSampleDescription,
      'planet' => l10n.geocodingDatasetPlanetDescription,
      'us' => l10n.geocodingDatasetUsDescription,
      'ca' => l10n.geocodingDatasetCaDescription,
      'custom' => l10n.geocodingDatasetCustomDescription,
      _ => null,
    };
  }

  String? _selectedDescription(AppLocalizations l10n) {
    if (_selectedDataset.isCustom) {
      return _datasetDescription(l10n, _selectedDataset);
    }
    if (_selectedDataset.isFullPlanet) {
      return l10n.geocodingPlanetImportWarning;
    }
    if (_selectedDataset.usesPlanetDownload &&
        _selectedDataset.countryCodes.isNotEmpty) {
      return '${_datasetDescription(l10n, _selectedDataset) ?? ''}\n\n${l10n.geocodingCountryImportDownloadNote}'
          .trim();
    }
    return _datasetDescription(l10n, _selectedDataset);
  }

  Future<void> _downloadAndImportPlaces() async {
    final l10n = AppLocalizations.of(context)!;
    final sourceUrl = _selectedDataset.isCustom
        ? _customUrlController.text.trim()
        : _selectedDataset.sourceUrl;
    if (sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingSourceUrlRequired)),
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
      final startedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedDataset.isFullPlanet
                ? startedL10n.geocodingPlanetImportStarted
                : startedL10n.geocodingPlaceImportStarted,
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
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.geocodingPlaceImportFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingPlacesImport = false);
      }
    }
  }

  Future<void> _cancelPlacesImport() async {
    setState(() => _isCancellingPlacesImport = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      await repository.cancelImport();
      refreshGeocoding(ref);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingPlaceImportAbortRequested)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Geocoding import cancel failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingAbortFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancellingPlacesImport = false);
      }
    }
  }

  Future<void> _downloadAndImportHousenumbers() async {
    final l10n = AppLocalizations.of(context)!;
    final sourceUrl = _housenumbersUrlController.text.trim();
    if (sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingHousenumbersUrlRequired)),
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
      final startedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(startedL10n.geocodingHousenumbersImportStarted)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumbers import start failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorL10n.geocodingHousenumbersImportFailed(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingHousenumbersImport = false);
      }
    }
  }

  Future<void> _cancelHousenumbersImport() async {
    setState(() => _isCancellingHousenumbersImport = true);
    try {
      final repository = ref.read(geocodingRepositoryProvider);
      await repository.cancelHousenumbersImport();
      refreshGeocoding(ref);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingAddressImportAbortRequested)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumbers import cancel failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.geocodingAbortFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancellingHousenumbersImport = false);
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
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
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
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.geocodingPlaceDataExported)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Place archive export failed',
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
        setState(() => _isPlacesArchiveBusy = false);
      }
    }
  }

  Future<void> _importPlacesArchive() async {
    final jsonText = await pickTextFileContents();
    if (jsonText == null || !mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingImportPlaceArchiveTitle,
      message: l10n.geocodingImportPlaceArchiveMessage,
      confirmLabel: l10n.actionImport,
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
      final importedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(importedL10n.geocodingPlaceArchiveImported(rowCount)),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Place archive import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.geocodingImportFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacesArchiveBusy = false);
      }
    }
  }

  Future<void> _clearPlaces() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingRemoveAllPlacesTitle,
      message: l10n.geocodingRemoveAllPlacesMessage,
      confirmLabel: l10n.actionRemoveAll,
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
      final clearedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(clearedL10n.geocodingPlacesRemoved(removed)),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌍 Place clear failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.geocodingRemoveFailed(error.toString())),
        ),
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
      final l10n = AppLocalizations.of(context)!;
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.geocodingHousenumberDataExported)),
        );
      }
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumber archive export failed',
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
        setState(() => _isHousenumbersArchiveBusy = false);
      }
    }
  }

  Future<void> _importHousenumbersArchive() async {
    final jsonText = await pickTextFileContents();
    if (jsonText == null || !mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingImportHousenumberArchiveTitle,
      message: l10n.geocodingImportHousenumberArchiveMessage,
      confirmLabel: l10n.actionImport,
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
      final importedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            importedL10n.geocodingHousenumberArchiveImported(rowCount),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumber archive import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.geocodingImportFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isHousenumbersArchiveBusy = false);
      }
    }
  }

  Future<void> _clearHousenumbers() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.geocodingRemoveAllAddressesTitle,
      message: l10n.geocodingRemoveAllAddressesMessage,
      confirmLabel: l10n.actionRemoveAll,
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
      final clearedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(clearedL10n.geocodingAddressesRemoved(removed)),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🏠 Housenumber clear failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.geocodingRemoveFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isHousenumbersArchiveBusy = false);
      }
    }
  }

  Widget _buildArchiveActions({
    required AppLocalizations l10n,
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
          label: Text(l10n.actionExport),
        ),
        OutlinedButton.icon(
          onPressed: enabled && !busy ? onImport : null,
          icon: const Icon(Icons.download_outlined),
          label: Text(l10n.actionImport),
        ),
        OutlinedButton.icon(
          onPressed: enabled && !busy ? onRemoveAll : null,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.actionRemoveAll),
        ),
      ],
    );
  }

  String _formatCount(int value) {
    return formatLocaleCount(value, Localizations.localeOf(context).toString());
  }

  String _importStatusLabel({
    required AppLocalizations l10n,
    required String status,
    required int rowCount,
    required String readyLabel,
    GeocodingImportPhase? activePhase,
    bool isAddresses = false,
  }) {
    if (activePhase != null && activePhase != GeocodingImportPhase.idle) {
      return geocodingImportPhaseTitle(
        l10n,
        activePhase,
        isAddresses: isAddresses,
      );
    }
    final formattedCount = _formatCount(rowCount);
    return switch (status) {
      geocodingStatusIdle => l10n.geocodingStatusNotImported,
      geocodingStatusDownloading => l10n.geocodingStatusDownloading,
      geocodingStatusImporting => l10n.geocodingStatusImporting,
      geocodingStatusCompleted =>
        l10n.geocodingStatusReady(formattedCount, readyLabel),
      geocodingStatusFailed => l10n.geocodingStatusFailed,
      geocodingStatusCancelled => l10n.geocodingStatusCancelled,
      _ => status,
    };
  }

  String _activeDatasetLabel(
    AppLocalizations l10n,
    GeocodingImportState settings,
  ) {
    final option = GeocodingDatasetOption.match(
      sourceUrl: settings.sourceUrl,
      countryCodes: settings.countryCodes,
    );
    if (option.isCustom) {
      return l10n.geocodingCustomUrlLabel;
    }
    return _datasetLabel(l10n, option);
  }

  Widget _buildImportProgress({
    required bool isRunning,
    required String importStatus,
    required double progress,
    required int importedRowCount,
    required String rowLabel,
    required bool isAddresses,
    required bool isCancelling,
    required VoidCallback? onAbort,
  }) {
    if (!isRunning) {
      return const SizedBox.shrink();
    }

    return GeocodingImportProgressPanel(
      importStatus: importStatus,
      progress: progress,
      importedRowCount: importedRowCount,
      rowLabel: rowLabel,
      isAddresses: isAddresses,
      onAbort: onAbort,
      isCancelling: isCancelling,
    );
  }

  Widget _buildGeocodingServerConnection(AppLocalizations l10n) {
    final repository = ref.watch(geocodingRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.geocodingServerConnectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.geocodingServerConnectionDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _geocodingServerUrlController,
          decoration: InputDecoration(
            labelText: l10n.geocodingServerUrlLabel,
            hintText: defaultGeocodingWebUrl,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
          autofillHints: const [AutofillHints.url],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _isSavingGeocodingServerUrl ? null : _saveGeocodingServerUrl,
            child: Text(
              _isSavingGeocodingServerUrl
                  ? l10n.actionSaving
                  : l10n.geocodingSaveServerUrl,
            ),
          ),
        ),
        if (!repository.isConfigured) ...[
          const SizedBox(height: 12),
          Text(
            l10n.geocodingServerNotConfiguredMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(geocodingRepositoryProvider);
    final configured = repository.isConfigured;
    final settingsAsync =
        configured ? ref.watch(geocodingSettingsProvider) : null;
    final description = _selectedDescription(l10n);
    final contributionSettings =
        settingsAsync?.valueOrNull ?? defaultGeocodingImportState();
    final importRunning = settingsAsync?.valueOrNull?.isRunning ?? false;

    if (settingsAsync != null) {
      ref.listen(geocodingSettingsProvider, (previous, next) {
        next.whenData((settings) {
          _schedulePolling(isRunning: settings.isRunning);
        });
      });
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.geocodingTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.geocodingDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildGeocodingServerConnection(l10n),
        SettingsGeocodingContributionsSection(
          settings: contributionSettings,
          enabled: configured && !importRunning,
          serverConfigured: configured,
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        if (!configured)
          Text(
            l10n.geocodingServerNotConfiguredMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          )
        else
          settingsAsync!.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LinearProgressIndicator(),
          ),
          error: (error, _) => Text(
            l10n.geocodingSettingsLoadFailed(error.toString()),
          ),
          data: (settings) {
            _syncFromServer(settings);
            return _buildDownloadedDatasetSections(l10n, settings, description);
          },
        ),
      ],
    );
  }

  Widget _buildDownloadedDatasetSections(
    AppLocalizations l10n,
    GeocodingImportState settings,
    String? description,
  ) {
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
                  l10n.geocodingDownloadedDatasetsSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.geocodingDownloadedDatasetsSectionDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.geocodingPlacesSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.geocodingPlanetImportWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GeocodingDatasetOption>(
                  key: ValueKey(_selectedDataset.id),
                  initialValue: _selectedDataset,
                  decoration: InputDecoration(
                    labelText: l10n.geocodingPlaceDatasetLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final option in geocodingDatasetOptions)
                      DropdownMenuItem(
                        value: option,
                        child: Text(_datasetLabel(l10n, option)),
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
                    decoration: InputDecoration(
                      labelText: l10n.geocodingCustomPlaceUrlLabel,
                      hintText: geocodingPlanetSourceUrl,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.url],
                    enabled: placesControlsEnabled,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.geocodingStatusLabel(
                    _importStatusLabel(
                      l10n: l10n,
                      status: settings.importStatus,
                      rowCount: settings.importedRowCount,
                      readyLabel: l10n.geocodingRowLabelPlaces,
                      activePhase: settings.isPlacesRunning
                          ? resolveGeocodingImportPhase(
                              isRunning: settings.isPlacesRunning,
                              status: settings.importStatus,
                              progress: settings.importProgress,
                            )
                          : null,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (settings.importStatus != geocodingStatusIdle) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.geocodingLastSelection(
                      _activeDatasetLabel(l10n, settings),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                _buildImportProgress(
                  isRunning: settings.isPlacesRunning,
                  importStatus: settings.importStatus,
                  progress: settings.importProgress,
                  importedRowCount: settings.importedRowCount,
                  rowLabel: l10n.geocodingRowLabelRows,
                  isAddresses: false,
                  isCancelling: _isCancellingPlacesImport,
                  onAbort: settings.isPlacesRunning ? _cancelPlacesImport : null,
                ),
                if (!settings.isPlacesRunning && settings.importedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.geocodingLastImport(
                      settings.importedAt!.toLocal().toString(),
                    ),
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
                  l10n.geocodingPlacesArchiveDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _buildArchiveActions(
                  l10n: l10n,
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
                        ? l10n.geocodingPlaceImportInProgress
                        : l10n.geocodingDownloadImportPlaces,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  l10n.geocodingAddressesSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.geocodingHousenumbersImportWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _housenumbersUrlController,
                  decoration: InputDecoration(
                    labelText: l10n.geocodingHousenumbersUrlLabel,
                    hintText: geocodingHousenumbersSourceUrl,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.url],
                  enabled: housenumbersControlsEnabled,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.geocodingStatusLabel(
                    _importStatusLabel(
                      l10n: l10n,
                      status: settings.housenumbersImportStatus,
                      rowCount: settings.housenumbersImportedRowCount,
                      readyLabel: l10n.geocodingRowLabelAddresses,
                      activePhase: settings.isHousenumbersRunning
                          ? resolveGeocodingImportPhase(
                              isRunning: settings.isHousenumbersRunning,
                              status: settings.housenumbersImportStatus,
                              progress: settings.housenumbersImportProgress,
                            )
                          : null,
                      isAddresses: true,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                _buildImportProgress(
                  isRunning: settings.isHousenumbersRunning,
                  importStatus: settings.housenumbersImportStatus,
                  progress: settings.housenumbersImportProgress,
                  importedRowCount: settings.housenumbersImportedRowCount,
                  rowLabel: l10n.geocodingRowLabelAddresses,
                  isAddresses: true,
                  isCancelling: _isCancellingHousenumbersImport,
                  onAbort: settings.isHousenumbersRunning
                      ? _cancelHousenumbersImport
                      : null,
                ),
                if (!settings.isHousenumbersRunning &&
                    settings.housenumbersImportedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.geocodingLastImport(
                      settings.housenumbersImportedAt!.toLocal().toString(),
                    ),
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
                  l10n.geocodingAddressesArchiveDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _buildArchiveActions(
                  l10n: l10n,
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
                        ? l10n.geocodingAddressImportInProgress
                        : l10n.geocodingDownloadImportHousenumbers,
                  ),
                ),
              ],
            );
  }
}
