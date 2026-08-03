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

class PrepareOfflinePackDialog extends ConsumerStatefulWidget {
  const PrepareOfflinePackDialog({super.key});

  @override
  ConsumerState<PrepareOfflinePackDialog> createState() =>
      _PrepareOfflinePackDialogState();
}

class _PrepareOfflinePackDialogState
    extends ConsumerState<PrepareOfflinePackDialog> {
  final _nameController = TextEditingController(text: 'Home');
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
    if (_selectedLayerIds.isEmpty) {
      setState(() => _error = l10n.offlinePackSelectLayersRequired);
      return;
    }
    if (_minZoom > _maxZoom) {
      setState(() => _error = l10n.offlinePackZoomRangeInvalid);
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
      final replaceId = _targetPackId.isEmpty ? null : _targetPackId;
      await ref
          .read(offlinePackControllerProvider)
          .prepare(
            name: _nameController.text.trim().isEmpty
                ? l10n.offlinePackDefaultName
                : _nameController.text.trim(),
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
    setState(() {
      if (_targetPackId == packId) {
        _targetPackId = _newPackTargetId;
      }
    });
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
            if (existing != null) {
              _nameController.text = existing.name;
              _targetPackId = existing.id;
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
                for (final pack in index.packs)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      pack.id == index.activePackId
                          ? Icons.check_circle
                          : Icons.offline_pin_outlined,
                      color: pack.id == index.activePackId
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(pack.name),
                    subtitle: Text(
                      pack.id == index.activePackId
                          ? l10n.offlinePackActiveLabel
                          : l10n.offlinePackInactiveLabel,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (pack.id != index.activePackId)
                          TextButton(
                            onPressed: _preparing
                                ? null
                                : () => _activate(pack.id),
                            child: Text(l10n.offlinePackActivateAction),
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
                          if (value.isNotEmpty) {
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
