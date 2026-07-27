import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
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
  RoutingRegion? _selectedRegion;
  bool _isSavingRoutingServerUrl = false;
  bool _isStartingImport = false;
  bool _isCancellingImport = false;
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
    final region = _selectedRegion;
    final customUrl = _customUrlController.text.trim();
    if (region == null && customUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routingRegionOrUrlRequired)),
      );
      return;
    }

    setState(() => _isStartingImport = true);
    try {
      final repository = ref.read(routingRepositoryProvider);
      await repository.startImport(
        regionId: region?.id,
        sourceUrl: region == null ? customUrl : null,
      );
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
    final controlsEnabled = !status.importInProgress && !_isStartingImport;
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
        const SizedBox(height: 12),
        if (regions.isNotEmpty)
          DropdownButtonFormField<RoutingRegion?>(
            initialValue: _selectedRegion,
            decoration: InputDecoration(
              labelText: l10n.routingRegionLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final region in regions)
                DropdownMenuItem(value: region, child: Text(region.name)),
              DropdownMenuItem(
                value: null,
                child: Text(l10n.routingCustomUrlLabel),
              ),
            ],
            onChanged: controlsEnabled
                ? (value) => setState(() => _selectedRegion = value)
                : null,
          ),
        if (regions.isEmpty || _selectedRegion == null) ...[
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
              label: Text(l10n.routingImportAction),
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
