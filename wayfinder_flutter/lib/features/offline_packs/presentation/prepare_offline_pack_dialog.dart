import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../layers/providers/layers_provider.dart';
import '../../layers/utils/map_layer_utils.dart';
import '../../map/models/map_viewport.dart';
import '../../map/providers/map_providers.dart';
import '../../map/utils/pmtiles_viewport.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../data/offline_pack_store.dart';
import '../data/prepare_offline_pack.dart';
import '../models/offline_pack.dart';
import '../providers/offline_pack_controller.dart';
import '../providers/server_reachability_provider.dart';

/// Sentinel for “create a new pack” in the prepare target dropdown.
const _newPackTargetId = '';

Future<bool?> showPrepareOfflinePackDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PrepareOfflinePackDialog(),
  );
}

String _suggestNewPackName(AppLocalizations l10n, OfflinePackIndex index) {
  final base = l10n.offlinePackDefaultName;
  final used = {
    for (final pack in index.packs) pack.name.trim().toLowerCase(),
  };
  if (!used.contains(base.toLowerCase())) {
    return base;
  }
  var n = 2;
  while (used.contains('$base $n'.toLowerCase())) {
    n++;
  }
  return '$base $n';
}

bool _nameTaken(
  OfflinePackIndex index,
  String name, {
  String? excludingPackId,
}) {
  final needle = name.trim().toLowerCase();
  if (needle.isEmpty) {
    return false;
  }
  for (final pack in index.packs) {
    if (excludingPackId != null && pack.id == excludingPackId) {
      continue;
    }
    if (pack.name.trim().toLowerCase() == needle) {
      return true;
    }
  }
  return false;
}

String _formatPreparedAt(DateTime when) {
  final local = when.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

List<Widget> _packDetailLines(
  BuildContext context,
  AppLocalizations l10n,
  OfflinePackIndexEntry pack,
) {
  final style = Theme.of(context).textTheme.bodySmall;
  final layersLine = pack.layerNames.isEmpty
      ? l10n.offlinePackDetailsLayersEmpty
      : l10n.offlinePackDetailsLayers(pack.layerNames.join(', '));
  return [
    Text(layersLine, style: style),
    Text(
      l10n.offlinePackDetailsCounts(
        pack.markerCount,
        pack.zoneCount,
        pack.tileCount,
        pack.seasonalOverlayCount,
      ),
      style: style,
    ),
    Text(
      l10n.offlinePackDetailsPrepared(_formatPreparedAt(pack.preparedAt)),
      style: style,
    ),
  ];
}

class PrepareOfflinePackDialog extends ConsumerStatefulWidget {
  const PrepareOfflinePackDialog({super.key});

  @override
  ConsumerState<PrepareOfflinePackDialog> createState() =>
      _PrepareOfflinePackDialogState();
}

class _PrepareOfflinePackDialogState
    extends ConsumerState<PrepareOfflinePackDialog> {
  final _nameController = TextEditingController();
  final _selectedLayerIds = <UuidValue>{};
  var _includeSeasonalOverlays = false;
  var _seededFromExisting = false;
  var _minZoom = 10;
  var _maxZoom = 15;
  var _preparing = false;
  String? _status;
  String? _error;
  double? _progress;

  /// Empty string = create new pack; otherwise replace that pack id.
  var _targetPackId = _newPackTargetId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  OfflinePackRegion _regionFromViewport() {
    final viewport =
        ref.read(mapViewportProvider).valueOrNull ??
        const MapViewport(center: LatLng(0, 0), zoom: 12);
    final bounds = expandLatLngBounds(
      approximateVisibleBounds(viewport),
      fraction: 0.25,
    );
    return OfflinePackRegion(
      south: bounds.south,
      west: bounds.west,
      north: bounds.north,
      east: bounds.east,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );
  }

  Future<void> _prepare() async {
    final l10n = AppLocalizations.of(context)!;
    final index =
        ref.read(offlinePackIndexProvider).valueOrNull ??
        const OfflinePackIndex();
    if (_selectedLayerIds.isEmpty) {
      setState(() => _error = l10n.offlinePackSelectLayersRequired);
      return;
    }
    if (_minZoom > _maxZoom) {
      setState(() => _error = l10n.offlinePackZoomRangeInvalid);
      return;
    }

    final replaceId = _targetPackId.isEmpty ? null : _targetPackId;
    final name = _nameController.text.trim().isEmpty
        ? _suggestNewPackName(l10n, index)
        : _nameController.text.trim();
    if (_nameTaken(index, name, excludingPackId: replaceId)) {
      setState(() => _error = l10n.offlinePackNameDuplicate);
      return;
    }

    setState(() {
      _preparing = true;
      _error = null;
      _status = l10n.offlinePackPreparing;
      _progress = 0;
    });

    try {
      final region = _regionFromViewport();
      await ref
          .read(offlinePackControllerProvider)
          .prepare(
            name: name,
            layerIds: _selectedLayerIds.toList(),
            region: region,
            packId: replaceId,
            includeSeasonalOverlays: _includeSeasonalOverlays,
            onProgress: (message, fraction) {
              if (!mounted) {
                return;
              }
              setState(() {
                _status = message;
                _progress = fraction;
              });
            },
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preparing = false;
        _error = error.toString();
        _status = null;
        _progress = null;
      });
    }
  }

  Future<void> _clearActive() async {
    await ref.read(offlinePackControllerProvider).clearPack();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _activate(String packId) async {
    await ref.read(offlinePackControllerProvider).activatePack(packId);
    if (!mounted) {
      return;
    }
    setState(() {
      _targetPackId = packId;
    });
  }

  Future<void> _deletePack(String packId) async {
    await ref.read(offlinePackControllerProvider).clearPack(packId: packId);
    if (!mounted) {
      return;
    }
    final index =
        ref.read(offlinePackIndexProvider).valueOrNull ??
        const OfflinePackIndex();
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (_targetPackId == packId) {
        _targetPackId = _newPackTargetId;
        _nameController.text = _suggestNewPackName(l10n, index);
      }
    });
  }

  Future<void> _renamePack(OfflinePackIndexEntry pack) async {
    final l10n = AppLocalizations.of(context)!;
    final index =
        ref.read(offlinePackIndexProvider).valueOrNull ??
        const OfflinePackIndex();
    final controller = TextEditingController(text: pack.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.offlinePackRenameTitle),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._packDetailLines(context, l10n, pack),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.offlinePackNameLabel,
                    hintText: l10n.offlinePackNameHint,
                  ),
                  onSubmitted: (value) =>
                      Navigator.of(context).pop(value.trim()),
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
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.actionRename),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || !mounted) {
      return;
    }
    if (_nameTaken(index, newName, excludingPackId: pack.id)) {
      setState(() => _error = l10n.offlinePackNameDuplicate);
      return;
    }
    try {
      await ref
          .read(offlinePackControllerProvider)
          .renamePack(packId: pack.id, name: newName);
    } on StateError {
      if (!mounted) {
        return;
      }
      setState(() => _error = l10n.offlinePackNameDuplicate);
      return;
    }
    if (!mounted) {
      return;
    }
    if (_targetPackId == pack.id ||
        ref.read(offlinePackMetaProvider).valueOrNull?.id == pack.id) {
      setState(() => _nameController.text = newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layersAsync = ref.watch(layersProvider);
    final existing = ref.watch(offlinePackMetaProvider).valueOrNull;
    final index =
        ref.watch(offlinePackIndexProvider).valueOrNull ??
        const OfflinePackIndex();
    final catalog = ref.watch(pmtilesCatalogProvider).valueOrNull ?? const [];
    final enabledCount = catalog.where((f) => f.enabledOnMap).length;
    final regionPreview = _regionFromViewport();
    final estimate = estimateOfflineTileCount(
      region: regionPreview,
      archiveCount: enabledCount.clamp(1, 99),
    );

    // Seed selection once layers / existing pack meta load.
    layersAsync.whenData((layers) {
      if (!_seededFromExisting && layers.isNotEmpty && !_preparing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _seededFromExisting) {
            return;
          }
          setState(() {
            _seededFromExisting = true;
            if (_selectedLayerIds.isEmpty) {
              _selectedLayerIds.addAll(
                existing?.layerIds ??
                    [
                      for (final layer in layers) layer.id,
                    ],
              );
            }
            _includeSeasonalOverlays =
                existing?.includeSeasonalOverlays ?? false;
            // Default to creating a new pack with a unique name so consecutive
            // prepares do not silently reuse the previous pack's label.
            _targetPackId = _newPackTargetId;
            _nameController.text = _suggestNewPackName(l10n, index);
            if (existing != null) {
              _minZoom = existing.region.minZoom;
              _maxZoom = existing.region.maxZoom;
            }
          });
        });
      }
    });

    return AlertDialog(
      title: Text(l10n.offlinePackPrepareTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.offlinePackPrepareDescription),
              const SizedBox(height: 12),
              if (index.packs.isNotEmpty) ...[
                Text(
                  l10n.offlinePackSavedPacksLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                for (final pack in index.packs) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 8),
                          child: Icon(
                            pack.id == index.activePackId
                                ? Icons.check_circle
                                : Icons.offline_pin_outlined,
                            color: pack.id == index.activePackId
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pack.name,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                pack.id == index.activePackId
                                    ? l10n.offlinePackActiveLabel
                                    : l10n.offlinePackInactiveLabel,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              ..._packDetailLines(context, l10n, pack),
                            ],
                          ),
                        ),
                        if (pack.id != index.activePackId)
                          TextButton(
                            onPressed: _preparing
                                ? null
                                : () => _activate(pack.id),
                            child: Text(l10n.offlinePackActivateAction),
                          ),
                        IconButton(
                          tooltip: l10n.actionRename,
                          onPressed: _preparing
                              ? null
                              : () => _renamePack(pack),
                          icon: const Icon(Icons.drive_file_rename_outline),
                        ),
                        IconButton(
                          tooltip: l10n.offlinePackClear,
                          onPressed: _preparing
                              ? null
                              : () => _deletePack(pack.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'pack-target-$_targetPackId-${index.packs.length}',
                ),
                initialValue: _targetPackId,
                decoration: InputDecoration(
                  labelText: l10n.offlinePackTargetLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: _newPackTargetId,
                    child: Text(l10n.offlinePackTargetNew),
                  ),
                  for (final pack in index.packs)
                    DropdownMenuItem(
                      value: pack.id,
                      child: Text(
                        l10n.offlinePackTargetReplace(pack.name),
                      ),
                    ),
                ],
                onChanged: _preparing
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _targetPackId = value;
                          if (value.isEmpty) {
                            _nameController.text = _suggestNewPackName(
                              l10n,
                              index,
                            );
                          } else {
                            for (final pack in index.packs) {
                              if (pack.id == value) {
                                _nameController.text = pack.name;
                                break;
                              }
                            }
                          }
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                enabled: !_preparing,
                decoration: InputDecoration(
                  labelText: l10n.offlinePackNameLabel,
                  hintText: l10n.offlinePackNameHint,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.offlinePackLayersLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              layersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (layers) {
                  final sorted = sortedMapLayers(layers);
                  if (sorted.isEmpty) {
                    return Text(l10n.offlinePackNoLayers);
                  }
                  return Column(
                    children: [
                      for (final layer in sorted)
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: _selectedLayerIds.contains(layer.id),
                          title: Text(layer.name),
                          onChanged: _preparing
                              ? null
                              : (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedLayerIds.add(layer.id);
                                    } else {
                                      _selectedLayerIds.remove(layer.id);
                                    }
                                  });
                                },
                        ),
                    ],
                  );
                },
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: _includeSeasonalOverlays,
                title: Text(l10n.offlinePackIncludeSeasonalOverlays),
                subtitle: Text(l10n.offlinePackIncludeSeasonalOverlaysHint),
                onChanged: _preparing
                    ? null
                    : (value) {
                        setState(() {
                          _includeSeasonalOverlays = value ?? false;
                        });
                      },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.offlinePackZoomLabel(_minZoom, _maxZoom),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              RangeSlider(
                values: RangeValues(
                  _minZoom.toDouble(),
                  _maxZoom.toDouble(),
                ),
                min: 6,
                max: 16,
                divisions: 10,
                labels: RangeLabels('$_minZoom', '$_maxZoom'),
                onChanged: _preparing
                    ? null
                    : (values) {
                        setState(() {
                          _minZoom = values.start.round();
                          _maxZoom = values.end.round();
                        });
                      },
              ),
              Text(
                l10n.offlinePackEstimate(estimate, enabledCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (existing != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.offlinePackExistingSummary(
                    existing.name,
                    existing.tileCount,
                    existing.markerCount,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 4),
                Text(_status!),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (existing != null)
          TextButton(
            onPressed: _preparing ? null : _clearActive,
            child: Text(l10n.offlinePackClear),
          ),
        TextButton(
          onPressed: _preparing ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _preparing ? null : _prepare,
          child: Text(
            _targetPackId.isEmpty
                ? l10n.offlinePackPrepareNewAction
                : l10n.offlinePackPrepareAction,
          ),
        ),
      ],
    );
  }
}
