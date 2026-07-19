import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart' show AppLogger, formatBytes;
import '../models/remote_pmtiles_catalog.dart';
import '../providers/pmtiles_providers.dart';

/// Lets the user import regional basemaps / DEM packs from curated remote URLs.
Future<bool?> showGetMapsDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const GetMapsDialog(),
  );
}

enum _GetMapsTab { basemap, dem }

class GetMapsDialog extends ConsumerStatefulWidget {
  const GetMapsDialog({super.key});

  @override
  ConsumerState<GetMapsDialog> createState() => _GetMapsDialogState();
}

class _GetMapsDialogState extends ConsumerState<GetMapsDialog> {
  late Future<List<RemotePmtilesPack>> _catalogFuture;
  final _queryController = TextEditingController();
  _GetMapsTab _tab = _GetMapsTab.basemap;
  String? _importingId;
  String? _statusMessage;
  String? _errorMessage;
  var _importedAny = false;

  @override
  void initState() {
    super.initState();
    _catalogFuture = loadRemotePmtilesCatalog();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _importPack(RemotePmtilesPack pack) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _importingId = pack.id;
      _errorMessage = null;
      _statusMessage = pack.isDemExtract
          ? l10n.mapTilesGetMapsExtracting(pack.title)
          : l10n.mapTilesGetMapsImporting(pack.title);
    });
    try {
      await ref.read(pmtilesRepositoryProvider).importRemotePack(pack);
      if (!mounted) {
        return;
      }
      setState(() {
        _importedAny = true;
        _statusMessage = l10n.mapTilesGetMapsImported(pack.title);
      });
      refreshPmtiles(ref);
    } catch (error, stackTrace) {
      AppLogger.logPmtiles.error(
        '📥 Get maps import failed',
        error: error,
        stackTrace: stackTrace,
        data: pack.name,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _statusMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() => _importingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final busy = _importingId != null;

    return AlertDialog(
      title: Text(l10n.mapTilesGetMapsTitle),
      content: SizedBox(
        width: 560,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _tab == _GetMapsTab.basemap
                  ? l10n.mapTilesGetMapsBasemapDescription
                  : l10n.mapTilesGetMapsDemDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<_GetMapsTab>(
              segments: [
                ButtonSegment(
                  value: _GetMapsTab.basemap,
                  label: Text(l10n.mapTilesGetMapsBasemapBadge),
                  icon: const Icon(Icons.map_outlined),
                ),
                ButtonSegment(
                  value: _GetMapsTab.dem,
                  label: Text(l10n.mapTilesDemBadge),
                  icon: const Icon(Icons.terrain),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: busy
                  ? null
                  : (value) {
                      setState(() => _tab = value.first);
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _queryController,
              enabled: !busy,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.mapTilesGetMapsSearchHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<RemotePmtilesPack>>(
                future: _catalogFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      l10n.mapTilesGetMapsCatalogFailed(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  final packs = snapshot.data ?? const <RemotePmtilesPack>[];
                  final query = _queryController.text.trim().toLowerCase();
                  final filtered = packs
                      .where(
                        (pack) =>
                            _tab == _GetMapsTab.dem ? pack.isDem : !pack.isDem,
                      )
                      .where(
                        (pack) =>
                            query.isEmpty ||
                            pack.title.toLowerCase().contains(query) ||
                            pack.name.toLowerCase().contains(query),
                      )
                      .toList();
                  if (filtered.isEmpty) {
                    return Text(l10n.mapTilesGetMapsEmpty);
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pack = filtered[index];
                      return _PackTile(
                        pack: pack,
                        busy: busy,
                        importing: _importingId == pack.id,
                        onImport: () => _importPack(pack),
                      );
                    },
                  );
                },
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _statusMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy
              ? null
              : () => Navigator.of(context).pop(_importedAny),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.pack,
    required this.busy,
    required this.importing,
    required this.onImport,
  });

  final RemotePmtilesPack pack;
  final bool busy;
  final bool importing;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sizeLabel = pack.isDemExtract
        ? l10n.mapTilesGetMapsSizeRegional
        : pack.bytes == null
        ? l10n.mapTilesGetMapsSizeUnknown
        : formatBytes(pack.bytes!);
    final kindLabel = pack.isDem
        ? l10n.mapTilesDemBadge
        : l10n.mapTilesGetMapsBasemapBadge;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(pack.title),
      subtitle: Text(
        [
          kindLabel,
          sizeLabel,
          if (pack.sourceLabel != null) pack.sourceLabel!,
          if (pack.description != null) pack.description!,
        ].join(' · '),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: pack.description != null,
      trailing: FilledButton(
        onPressed: busy ? null : onImport,
        child: importing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                pack.isDemExtract
                    ? l10n.mapTilesGetMapsExtractAction
                    : l10n.mapTilesGetMapsImportAction,
              ),
      ),
    );
  }
}
