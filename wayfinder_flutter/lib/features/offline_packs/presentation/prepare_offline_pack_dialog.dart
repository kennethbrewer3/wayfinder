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
import '../data/prepare_offline_pack.dart';
import '../models/offline_pack.dart';
import '../providers/offline_pack_controller.dart';
import '../providers/server_reachability_provider.dart';

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
  final _nameController = TextEditingController(text: 'Field pack');
  final _selectedLayerIds = <UuidValue>{};
  var _minZoom = 10;
  var _maxZoom = 15;
  var _preparing = false;
  String? _status;
  String? _error;
  double? _progress;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  OfflinePackRegion _regionFromViewport() {
    final viewport =
        ref.read(mapViewportProvider).valueOrNull ??
        const MapViewport(center: LatLng(0, 0), zoom: 12);
    // Import LatLng via map_viewport
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
      await ref
          .read(offlinePackControllerProvider)
          .prepare(
            name: _nameController.text.trim().isEmpty
                ? l10n.offlinePackDefaultName
                : _nameController.text.trim(),
            layerIds: _selectedLayerIds.toList(),
            region: region,
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

  Future<void> _clear() async {
    await ref.read(offlinePackControllerProvider).clearPack();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layersAsync = ref.watch(layersProvider);
    final existing = ref.watch(offlinePackMetaProvider).valueOrNull;
    final catalog = ref.watch(pmtilesCatalogProvider).valueOrNull ?? const [];
    final enabledCount = catalog.where((f) => f.enabledOnMap).length;
    final regionPreview = _regionFromViewport();
    final estimate = estimateOfflineTileCount(
      region: regionPreview,
      archiveCount: enabledCount.clamp(1, 99),
    );

    // Seed selection once layers load.
    layersAsync.whenData((layers) {
      if (_selectedLayerIds.isEmpty && layers.isNotEmpty && !_preparing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _selectedLayerIds.isNotEmpty) {
            return;
          }
          setState(() {
            _selectedLayerIds.addAll(
              existing?.layerIds ??
                  [
                    for (final layer in layers) layer.id,
                  ],
            );
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
              TextField(
                controller: _nameController,
                enabled: !_preparing,
                decoration: InputDecoration(
                  labelText: l10n.offlinePackNameLabel,
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
            onPressed: _preparing ? null : _clear,
            child: Text(l10n.offlinePackClear),
          ),
        TextButton(
          onPressed: _preparing ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _preparing ? null : _prepare,
          child: Text(l10n.offlinePackPrepareAction),
        ),
      ],
    );
  }
}
