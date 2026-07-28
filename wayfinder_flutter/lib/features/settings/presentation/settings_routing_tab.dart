import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart' show AppLogger, formatBytes;
import '../../../core/server_config.dart';
import '../../../core/server_config_storage.dart';
import '../../../core/widgets/http_url_field.dart';
import '../../routing/data/routing_repository.dart';
import '../../routing/models/routing_models.dart';
// Gated by canManageGeocodingProvider for now — the same admins who manage
// the offline geocoding appliance also manage the offline routing appliance.
// A dedicated `canManageRouting` permission can be added server-side later.
import '../../access/providers/access_session_provider.dart';

class SettingsRoutingTab extends ConsumerStatefulWidget {
  const SettingsRoutingTab({super.key});

  @override
  ConsumerState<SettingsRoutingTab> createState() => _SettingsRoutingTabState();
}

class _SettingsRoutingTabState extends ConsumerState<SettingsRoutingTab> {
  static final _log = AppLogger.logSettings;

  late final TextEditingController _routingServerUrlController;
  final _customUrlController = TextEditingController();

  /// Selected region ids. Multiple US states are merged into one graph.
  /// Empty with custom URL mode uses [_customUrlController].
  final List<String> _selectedRegionIds = [];
  bool _customRegionMode = false;
  bool _isSavingRoutingServerUrl = false;
  bool _isStartingImport = false;
  bool _isCancellingImport = false;
  bool _isUploadingOsm = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _routingServerUrlController = TextEditingController(
      text: appServerConfig.routingWebUrl ?? '',
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _routingServerUrlController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveRoutingServerUrl() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSavingRoutingServerUrl = true);
    try {
      final trimmed = _routingServerUrlController.text.trim();
      final storage = ServerConfigStorage();
      if (trimmed.isEmpty) {
        await storage.clearRoutingWebUrl();
        updateOptionalAppServerUrls(clearRoutingWebUrl: true);
        ref.read(routingWebUrlProvider.notifier).state = null;
      } else {
        final normalized = normalizeWebUrl(trimmed);
        await storage.saveRoutingWebUrl(normalized);
        updateOptionalAppServerUrls(routingWebUrl: normalized);
        ref.read(routingWebUrlProvider.notifier).state = normalized;
      }
      refreshRouting(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routingServerUrlSaved)));
    } catch (error, stackTrace) {
      _log.error(
        '🧭 Routing server URL save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSavingRoutingServerUrl = false);
      }
    }
  }

  void _schedulePolling({required bool importInProgress}) {
    _pollTimer?.cancel();
    if (!importInProgress) {
      return;
    }
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      refreshRouting(ref);
    });
  }

  Future<void> _startImport() async {
    final l10n = AppLocalizations.of(context)!;
    final customUrl = _customUrlController.text.trim();
    if (_selectedRegionIds.isEmpty && customUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routingRegionOrUrlRequired)),
      );
      return;
    }

    setState(() => _isStartingImport = true);
    try {
      final repository = ref.read(routingRepositoryProvider);
      if (_selectedRegionIds.length > 1) {
        await repository.startImport(regionIds: List.of(_selectedRegionIds));
      } else if (_selectedRegionIds.length == 1) {
        await repository.startImport(regionId: _selectedRegionIds.single);
      } else {
        await repository.startImport(sourceUrl: customUrl);
      }
      refreshRouting(ref);
      _schedulePolling(importInProgress: true);
      if (!mounted) return;
      final startedL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(startedL10n.routingImportStarted)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🧭 Routing import start failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final errorL10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorL10n.routingImportFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingImport = false);
      }
    }
  }

  bool _isUsStateRegion(RoutingRegion region) =>
      region.id.startsWith('us-') &&
      region.id != 'us' &&
      (region.sourceUrl?.trim().isNotEmpty ?? false);

  void _selectRegion(String? value, List<RoutingRegion> selectable) {
    if (value == null || value == '__custom__') {
      setState(() {
        _selectedRegionIds.clear();
        _customRegionMode = true;
      });
      return;
    }
    final region = selectable.where((r) => r.id == value).firstOrNull;
    if (region == null) {
      return;
    }
    setState(() {
      _customRegionMode = false;
      if (_isUsStateRegion(region)) {
        if (_selectedRegionIds.any((id) => !_isUsStateId(id))) {
          _selectedRegionIds.clear();
        }
        if (!_selectedRegionIds.contains(value)) {
          _selectedRegionIds.add(value);
        }
      } else {
        _selectedRegionIds
          ..clear()
          ..add(value);
      }
    });
  }

  bool _isUsStateId(String id) => id.startsWith('us-') && id != 'us';

  List<String> _parseRegionIds(String? regionId) {
    if (regionId == null || regionId.trim().isEmpty) {
      return const [];
    }
    if (!regionId.contains('+')) {
      return [regionId.trim()];
    }
    return [
      for (final part in regionId.split('+'))
        if (part.trim().isNotEmpty) part.trim(),
    ];
  }

  Future<void> _startLocalBuild() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isStartingImport = true);
    try {
      final repository = ref.read(routingRepositoryProvider);
      await repository.startImport(useLocalPbf: true);
      refreshRouting(ref);
      _schedulePolling(importInProgress: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routingImportStarted)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🧭 Routing local build start failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routingImportFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingImport = false);
      }
    }
  }

  Future<void> _uploadOsmFile() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pbf'],
      withData: kIsWeb,
      withReadStream: !kIsWeb,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }
    final file = picked.files.single;
    final stream = kIsWeb
        ? Stream<List<int>>.fromIterable([
            if (file.bytes != null) file.bytes!,
          ])
        : file.readStream;
    if (stream == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routingOsmUploadFailed('No file data'))),
      );
      return;
    }

    setState(() => _isUploadingOsm = true);
    try {
      final repository = ref.read(routingRepositoryProvider);
      await repository.uploadOsmPbf(
        bytes: stream,
        filename: file.name,
        contentLength: file.size > 0 ? file.size : null,
      );
      refreshRouting(ref);
      _schedulePolling(importInProgress: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routingOsmUploadStarted)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🧭 OSM upload failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routingOsmUploadFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingOsm = false);
      }
    }
  }

  Future<void> _cancelImport() async {
    setState(() => _isCancellingImport = true);
    try {
      final repository = ref.read(routingRepositoryProvider);
      await repository.cancelImport();
      refreshRouting(ref);
    } catch (error, stackTrace) {
      _log.error(
        '🧭 Routing import cancel failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(l10n.routingAbortFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancellingImport = false);
      }
    }
  }

  String _statusLabel(AppLocalizations l10n, RoutingImportStatus status) {
    return switch (status) {
      RoutingImportStatus.idle => l10n.routingStatusIdle,
      RoutingImportStatus.downloading => l10n.routingStatusDownloading,
      RoutingImportStatus.building => l10n.routingStatusBuilding,
      RoutingImportStatus.ready => l10n.routingStatusReady,
      RoutingImportStatus.failed => l10n.routingStatusFailed,
      RoutingImportStatus.cancelled => l10n.routingStatusCancelled,
      RoutingImportStatus.unknown => l10n.routingServerUnreachable,
    };
  }

  /// Primary selection shown in the region menu. During an active import,
  /// prefer the server's reported region so the field does not go blank.
  String? _menuSelectionId(
    RoutingStatus status,
    List<RoutingRegion> regions,
  ) {
    if (status.importInProgress ||
        status.status == RoutingImportStatus.downloading ||
        status.status == RoutingImportStatus.building) {
      final parts = _parseRegionIds(status.regionId);
      if (parts.length == 1 &&
          regions.any((region) => region.id == parts.single)) {
        return parts.single;
      }
      if (parts.length > 1) {
        // Multi-state merge — menu stays on last added / first part.
        return parts.firstWhere(
          (id) => regions.any((region) => region.id == id),
          orElse: () => parts.first,
        );
      }
      final sourceUrl = status.sourceUrl?.trim();
      if (sourceUrl != null &&
          sourceUrl.isNotEmpty &&
          !sourceUrl.startsWith('merge://')) {
        for (final region in regions) {
          if (region.id == 'custom') {
            continue;
          }
          if (region.sourceUrl?.trim() == sourceUrl) {
            return region.id;
          }
        }
      }
      if (status.sourceUrl != null && status.sourceUrl!.trim().isNotEmpty) {
        return '__custom__';
      }
    }
    if (_customRegionMode || _selectedRegionIds.isEmpty) {
      return '__custom__';
    }
    return _selectedRegionIds.last;
  }

  List<String> _effectiveSelectedIds(RoutingStatus status) {
    if (status.importInProgress ||
        status.status == RoutingImportStatus.downloading ||
        status.status == RoutingImportStatus.building) {
      final parts = _parseRegionIds(status.regionId);
      if (parts.isNotEmpty) {
        return parts;
      }
    }
    return List.of(_selectedRegionIds);
  }

  List<RoutingRegion> _selectableRegions(List<RoutingRegion> regions) {
    return [
      for (final region in regions)
        if (region.id != 'custom' &&
            region.sourceUrl != null &&
            region.sourceUrl!.trim().isNotEmpty)
          region,
    ];
  }

  Widget _buildServerConnection(AppLocalizations l10n) {
    final repository = ref.watch(routingRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.routingServerConnectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.routingServerConnectionDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        HttpUrlField(
          controller: _routingServerUrlController,
          labelText: l10n.routingServerUrlLabel,
          hintText: defaultRoutingWebUrl,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _isSavingRoutingServerUrl ? null : _saveRoutingServerUrl,
            child: Text(
              _isSavingRoutingServerUrl
                  ? l10n.actionSaving
                  : l10n.routingSaveServerUrl,
            ),
          ),
        ),
        if (!repository.isConfigured) ...[
          const SizedBox(height: 12),
          Text(
            l10n.routingNotConfigured,
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

  Widget _buildStatusPanel(AppLocalizations l10n, RoutingStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.routingStatusTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              status.graphhopperUp
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
              size: 18,
              color: status.graphhopperUp
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _statusLabel(l10n, status.status),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (status.importInProgress) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value:
                status.status == RoutingImportStatus.downloading &&
                    status.progress != null
                ? status.progress!.clamp(0.0, 1.0)
                : null,
          ),
          if (status.status == RoutingImportStatus.downloading &&
              status.progress != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.routingImportProgressPercent(
                (status.progress! * 100).clamp(0, 100).toStringAsFixed(0),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
        if (status.message != null && status.message!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            status.message!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (status.osmPbfPresent) ...[
          const SizedBox(height: 8),
          Text(
            l10n.routingOsmOnServerHint(formatBytes(status.osmPbfBytes)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
        if (status.error != null && status.error!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            status.error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (status.ready) ...[
          const SizedBox(height: 8),
          Text(
            l10n.routingReadyHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImportSection(
    AppLocalizations l10n,
    RoutingStatus status,
    List<RoutingRegion> regions,
  ) {
    final controlsEnabled =
        !status.importInProgress && !_isStartingImport && !_isUploadingOsm;
    final selectable = _selectableRegions(regions);
    final menuSelectionId = _menuSelectionId(status, selectable);
    final selectedIds = _effectiveSelectedIds(status);
    final showCustomUrl =
        selectable.isEmpty || (_customRegionMode && selectedIds.isEmpty);
    final selectedUsStates = [
      for (final id in selectedIds)
        if (_isUsStateId(id))
          selectable.where((region) => region.id == id).firstOrNull,
    ].whereType<RoutingRegion>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.routingImportTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.routingImportDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.routingMultiStateHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.routingLocalOsmHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        if (selectable.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final selectedLabels = <String>{
                for (final id in selectedIds)
                  if (selectable.any((region) => region.id == id))
                    selectable
                        .firstWhere((region) => region.id == id)
                        .name
                        .toLowerCase(),
                if (showCustomUrl) l10n.routingCustomRegionLabel.toLowerCase(),
              };
              return DropdownMenu<String>(
                key: ValueKey(
                  'routing-region-$menuSelectionId-'
                  '${selectedIds.join('+')}-'
                  '${status.importInProgress}',
                ),
                width: constraints.maxWidth,
                initialSelection: menuSelectionId,
                enabled: controlsEnabled,
                enableFilter: true,
                requestFocusOnTap: true,
                label: Text(l10n.routingRegionLabel),
                hintText: l10n.routingRegionSearchHint,
                leadingIcon: const Icon(Icons.search),
                // DropdownMenu writes the selected label into the text field.
                // Without this, opening the menu filters to only that label
                // (e.g. only "United States (entire)").
                filterCallback: (entries, filter) {
                  final query = filter.trim().toLowerCase();
                  if (query.isEmpty || selectedLabels.contains(query)) {
                    return entries;
                  }
                  return [
                    for (final entry in entries)
                      if (entry.label.toLowerCase().contains(query)) entry,
                  ];
                },
                onSelected: controlsEnabled
                    ? (value) => _selectRegion(value, selectable)
                    : null,
                dropdownMenuEntries: [
                  for (final region in selectable)
                    DropdownMenuEntry<String>(
                      value: region.id,
                      label: region.name,
                    ),
                  DropdownMenuEntry<String>(
                    value: '__custom__',
                    label: l10n.routingCustomRegionLabel,
                  ),
                ],
              );
            },
          ),
        if (selectedUsStates.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.routingSelectedStatesLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final region in selectedUsStates)
                InputChip(
                  label: Text(region.name),
                  onDeleted: controlsEnabled
                      ? () => setState(() {
                          _selectedRegionIds.remove(region.id);
                          if (_selectedRegionIds.isEmpty) {
                            _customRegionMode = false;
                          }
                        })
                      : null,
                ),
            ],
          ),
          if (selectedUsStates.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.routingMultiStateMergeHint(selectedUsStates.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
        ],
        if (showCustomUrl) ...[
          const SizedBox(height: 12),
          HttpUrlField(
            controller: _customUrlController,
            labelText: l10n.routingCustomUrlLabel,
            enabled: controlsEnabled,
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: controlsEnabled ? _startImport : null,
              icon: _isStartingImport || status.importInProgress
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(
                selectedIds.length > 1
                    ? l10n.routingImportMultiAction(selectedIds.length)
                    : l10n.routingImportAction,
              ),
            ),
            OutlinedButton.icon(
              onPressed: controlsEnabled ? _uploadOsmFile : null,
              icon: _isUploadingOsm
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(l10n.routingUploadOsmAction),
            ),
            if (status.osmPbfPresent)
              OutlinedButton.icon(
                onPressed: controlsEnabled ? _startLocalBuild : null,
                icon: const Icon(Icons.storage_outlined),
                label: Text(l10n.routingBuildFromLocalAction),
              ),
            if (status.importInProgress)
              OutlinedButton.icon(
                onPressed: _isCancellingImport ? null : _cancelImport,
                icon: const Icon(Icons.cancel_outlined),
                label: Text(l10n.routingCancelImport),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canManageRouting = ref.watch(canManageGeocodingProvider);
    if (!canManageRouting) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsTabRouting,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.routingPermissionDenied,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    final repository = ref.watch(routingRepositoryProvider);
    final configured = repository.isConfigured;
    final statusAsync = configured ? ref.watch(routingStatusProvider) : null;
    final regionsAsync = configured ? ref.watch(routingRegionsProvider) : null;

    if (statusAsync != null) {
      ref.listen(routingStatusProvider, (previous, next) {
        next.whenData((status) {
          _schedulePolling(importInProgress: status.importInProgress);
        });
      });
    }

    final status = statusAsync?.valueOrNull ?? RoutingStatus.unconfigured;
    final regions = regionsAsync?.valueOrNull ?? const <RoutingRegion>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.settingsTabRouting,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.routingImportDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildServerConnection(l10n),
        if (!configured)
          Text(
            l10n.routingNotConfigured,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        else ...[
          if (statusAsync?.isLoading ?? false)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (statusAsync?.hasError ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.routingServerUnreachable,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _buildStatusPanel(l10n, status),
          _buildImportSection(l10n, status, regions),
        ],
      ],
    );
  }
}
