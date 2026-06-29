import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/core/l10n/localized_labels.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../circles/models/circle_geometry.dart';
import '../../circles/models/circle_size_display.dart';
import '../../circles/presentation/create_circle_dialog.dart';
import '../../circles/utils/circle_distance.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../rectangles/models/rectangle_size_display.dart';
import '../../rectangles/presentation/create_rectangle_dialog.dart';
import '../../rectangles/utils/rectangle_dimensions.dart';
import '../../layers/data/layers_repository.dart';
import '../../layers/providers/layers_provider.dart';
import '../../layers/utils/map_layer_utils.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/models/measurement_units.dart';
import '../../lines/presentation/create_line_dialog.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../map/providers/selected_map_object_provider.dart';
import '../../lines/utils/line_path.dart';
import '../../lines/utils/line_distance.dart';
import '../../tracks/models/track_geometry.dart';
import '../../tracks/presentation/create_track_dialog.dart';
import '../../tracks/presentation/map_track_layer.dart';
import '../../map/providers/map_providers.dart';
import '../../markers/models/marker_color.dart';
import '../../markers/presentation/create_marker_dialog.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/presentation/map_object_notes_preview.dart';
import '../../markers/presentation/map_objects_status.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../utils/map_object_sort.dart';

class SidebarPanel extends ConsumerWidget {
  const SidebarPanel({
    super.key,
    required this.onZoomTo,
  });

  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebar = ref.watch(sidebarProvider);
    final markersAsync = ref.watch(markersProvider);
    final zonesAsync = ref.watch(zonesProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarHeader(
            expanded: sidebar.expanded,
            onToggle: () {
              ref.read(sidebarProvider.notifier).toggleExpanded();
            },
          ),
          if (sidebar.expanded) ...[
            const SizedBox(height: 8),
            Expanded(
              child: _LayerOrganizedPanel(
                markersAsync: markersAsync,
                zonesAsync: zonesAsync,
                sidebar: sidebar,
                onZoomTo: onZoomTo,
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                l10n.sidebarTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            tooltip: expanded ? l10n.sidebarCollapsePanel : l10n.sidebarExpandPanel,
            icon: Icon(
              expanded
                  ? (isWide ? Icons.chevron_right : Icons.expand_more)
                  : (isWide ? Icons.chevron_left : Icons.expand_less),
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

class _LayerOrganizedPanel extends ConsumerWidget {
  const _LayerOrganizedPanel({
    required this.markersAsync,
    required this.zonesAsync,
    required this.sidebar,
    required this.onZoomTo,
  });

  final AsyncValue<List<MapMarker>> markersAsync;
  final AsyncValue<List<MapZone>> zonesAsync;
  final SidebarState sidebar;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layersAsync = ref.watch(layersProvider);
    final l10n = AppLocalizations.of(context)!;

    if (layersAsync.isLoading ||
        markersAsync.isLoading ||
        zonesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (layersAsync.hasError) {
      return MapObjectsErrorState(
        title: l10n.sidebarLayersUnavailable,
        message: layersLoadErrorMessage(layersAsync.error!, l10n),
        onRetry: () => ref.invalidate(layersProvider),
      );
    }

    if (markersAsync.hasError) {
      return MapObjectsErrorState(
        title: l10n.sidebarMarkersUnavailable,
        message: mapObjectsLoadErrorMessage(markersAsync.error!, l10n),
        onRetry: () => ref.invalidate(markersProvider),
      );
    }

    if (zonesAsync.hasError) {
      return MapObjectsErrorState(
        title: l10n.sidebarZonesUnavailable,
        message: mapObjectsLoadErrorMessage(zonesAsync.error!, l10n),
        onRetry: () => ref.read(zonesProvider.notifier).reload(),
      );
    }

    final layers = layersAsync.value ?? const <MapLayer>[];
    final markers = markersAsync.value ?? const <MapMarker>[];
    final zones = zonesAsync.value ?? const <MapZone>[];
    final query = sidebar.searchQuery.trim().toLowerCase();

    bool matchesSearch(String name) =>
        query.isEmpty || name.toLowerCase().contains(query);

    final orderedLayers = mapLayersForSidebar(layers);
    final selectedLayerId = resolveSelectedLayerId(
      selectedLayerId: sidebar.selectedLayerId,
      layers: layers,
    );

    if (sidebar.selectedLayerId == null && selectedLayerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sidebarProvider.notifier).setSelectedLayerId(selectedLayerId);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            l10n.sidebarLayerOrderHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: orderedLayers.length,
            itemBuilder: (context, index) {
              final layer = orderedLayers[index];
              final layerSettings = sidebar.settingsForLayer(layer.id);
              final filteredLayerMarkers = markersForLayer(markers, layer.id)
                  .where((marker) => matchesSearch(marker.name))
                  .toList();
              final filteredLayerZones = zonesForLayer(zones, layer.id)
                  .where((zone) => matchesSearch(zone.name))
                  .toList();
              final layerMarkers = sortMarkers(
                filteredLayerMarkers,
                layerSettings.markerSort,
              );
              final layerZones = sortZones(
                filteredLayerZones,
                layerSettings.zoneSort,
              );
              final isSelected = layer.id == selectedLayerId;
              final isExpanded = isLayerExpandedInSidebar(
                layerId: layer.id,
                expandedLayerIds: sidebar.expandedLayerIds,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.35)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LayerHeader(
                        layer: layer,
                        isSelected: isSelected,
                        isExpanded: isExpanded,
                        isTop: index == 0,
                        isBottom: index == orderedLayers.length - 1,
                        objectCount: layerMarkers.length + layerZones.length,
                        onSelect: () {
                          ref
                              .read(sidebarProvider.notifier)
                              .setSelectedLayerId(layer.id);
                        },
                        onToggleExpanded: () {
                          ref.read(sidebarProvider.notifier).toggleLayerExpanded(
                                layer.id,
                                expanded: !isExpanded,
                                allLayerIds: orderedLayers.map((l) => l.id),
                              );
                        },
                        onToggleVisible: () {
                          updateMapLayer(
                            ref,
                            layer.copyWith(visible: !layer.visible),
                          );
                        },
                        onMoveUp: () {
                          reorderMapLayers(
                            ref,
                            applyLayerOrder(layers, index, index - 1),
                          );
                        },
                        onMoveDown: () {
                          reorderMapLayers(
                            ref,
                            applyLayerOrder(layers, index, index + 1),
                          );
                        },
                        onRename: () => _renameLayer(context, ref, layer),
                        onDelete: () => _deleteLayer(context, ref, layer, layers),
                      ),
                      if (isExpanded)
                        _LayerObjectPanel(
                          layerId: layer.id,
                          settings: layerSettings,
                          layerMarkers: layerMarkers,
                          layerZones: layerZones,
                          hasSearchQuery: query.isNotEmpty,
                          onZoomTo: onZoomTo,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _createLayer(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.sidebarAddLayer),
          ),
        ),
      ],
    );
  }

  Future<void> _createLayer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await _promptForLayerName(
      context: context,
      title: l10n.sidebarNewLayerTitle,
      confirmLabel: l10n.actionCreate,
    );
    if (name == null || name.isEmpty || !context.mounted) {
      return;
    }

    await createMapLayer(ref, name);
    final createdLayers = await ref.read(layersProvider.future);
    final created = createdLayers.lastWhere(
      (layer) => layer.name == name,
      orElse: () => createdLayers.last,
    );
    ref.read(sidebarProvider.notifier).setSelectedLayerId(created.id);
  }

  Future<void> _renameLayer(
    BuildContext context,
    WidgetRef ref,
    MapLayer layer,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await _promptForLayerName(
      context: context,
      title: l10n.sidebarRenameLayerTitle,
      confirmLabel: l10n.actionSave,
      initialName: layer.name,
    );
    if (name == null || name.isEmpty || name == layer.name || !context.mounted) {
      return;
    }

    await updateMapLayer(ref, layer.copyWith(name: name));
  }

  Future<void> _deleteLayer(
    BuildContext context,
    WidgetRef ref,
    MapLayer layer,
    List<MapLayer> layers,
  ) async {
    if (layers.length <= 1) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sidebarKeepOneLayer)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dialogL10n.sidebarDeleteLayerTitle),
          content: Text(dialogL10n.sidebarDeleteLayerMessage(layer.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(dialogL10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(dialogL10n.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await deleteMapLayer(ref, layer);
    final remaining =
        ref.read(layersProvider).valueOrNull ?? const <MapLayer>[];
    ref.read(sidebarProvider.notifier).setSelectedLayerId(
          resolveSelectedLayerId(
            selectedLayerId: null,
            layers: remaining,
          ),
        );
  }

  Future<String?> _promptForLayerName({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    String initialName = '',
  }) {
    final controller = TextEditingController(text: initialName);
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.sidebarLayerNameLabel,
            ),
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isNotEmpty) {
                Navigator.of(context).pop(trimmed);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty) {
                  return;
                }
                Navigator.of(context).pop(trimmed);
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}

class _LayerHeader extends StatelessWidget {
  const _LayerHeader({
    required this.layer,
    required this.isSelected,
    required this.isExpanded,
    required this.isTop,
    required this.isBottom,
    required this.objectCount,
    required this.onSelect,
    required this.onToggleExpanded,
    required this.onToggleVisible,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRename,
    required this.onDelete,
  });

  final MapLayer layer;
  final bool isSelected;
  final bool isExpanded;
  final bool isTop;
  final bool isBottom;
  final int objectCount;
  final VoidCallback onSelect;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleVisible;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: isExpanded ? l10n.sidebarCollapseLayer : l10n.sidebarExpandLayer,
              onPressed: onToggleExpanded,
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
            IconButton(
              tooltip: layer.visible ? l10n.sidebarHideLayer : l10n.sidebarShowLayer,
              onPressed: onToggleVisible,
              icon: Icon(
                layer.visible ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    layer.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    l10n.sidebarObjectCount(objectCount) +
                        (isSelected ? l10n.sidebarSelectedForNewObjects : ''),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.sidebarMoveUp,
              onPressed: isTop ? null : onMoveUp,
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              tooltip: l10n.sidebarMoveDown,
              onPressed: isBottom ? null : onMoveDown,
              icon: const Icon(Icons.arrow_downward),
            ),
            PopupMenuButton<_LayerMenuAction>(
              onSelected: (action) {
                switch (action) {
                  case _LayerMenuAction.rename:
                    onRename();
                  case _LayerMenuAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _LayerMenuAction.rename,
                  child: Text(l10n.actionRename),
                ),
                PopupMenuItem(
                  value: _LayerMenuAction.delete,
                  child: Text(l10n.actionDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _LayerMenuAction { rename, delete }

class _LayerObjectPanel extends ConsumerWidget {
  const _LayerObjectPanel({
    required this.layerId,
    required this.settings,
    required this.layerMarkers,
    required this.layerZones,
    required this.hasSearchQuery,
    required this.onZoomTo,
  });

  final UuidValue layerId;
  final LayerSidebarSettings settings;
  final List<MapMarker> layerMarkers;
  final List<MapZone> layerZones;
  final bool hasSearchQuery;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sidebarProvider.notifier);
    final showingMarkers = settings.activeTab == SidebarPanelTab.markers;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SegmentedButton<SidebarPanelTab>(
            segments: [
              ButtonSegment(
                value: SidebarPanelTab.markers,
                label: Text(l10n.sidebarTabMarkers),
                icon: const Icon(Icons.place_outlined),
              ),
              ButtonSegment(
                value: SidebarPanelTab.zones,
                label: Text(l10n.sidebarTabZones),
                icon: const Icon(Icons.layers_outlined),
              ),
            ],
            selected: {settings.activeTab},
            onSelectionChanged: (selection) {
              notifier.setLayerActiveTab(layerId, selection.first);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SegmentedButton<SidebarViewMode>(
            segments: [
              ButtonSegment(
                value: SidebarViewMode.list,
                label: Text(l10n.sidebarViewList),
              ),
              ButtonSegment(
                value: SidebarViewMode.tree,
                label: Text(l10n.sidebarViewTree),
              ),
            ],
            selected: {settings.viewMode},
            onSelectionChanged: (selection) {
              notifier.setLayerViewMode(layerId, selection.first);
            },
          ),
        ),
        if (showingMarkers)
          _MarkerSortSelector(
            value: settings.markerSort,
            onChanged: (sort) {
              notifier.setLayerMarkerSort(layerId, sort);
            },
          )
        else
          _ZoneSortSelector(
            value: settings.zoneSort,
            onChanged: (sort) {
              notifier.setLayerZoneSort(layerId, sort);
            },
          ),
        if (showingMarkers)
          _LayerMarkersContent(
            markers: layerMarkers,
            settings: settings,
            hasSearchQuery: hasSearchQuery,
            onZoomTo: onZoomTo,
          )
        else
          _LayerZonesContent(
            zones: layerZones,
            settings: settings,
            hasSearchQuery: hasSearchQuery,
            onZoomTo: onZoomTo,
          ),
      ],
    );
  }
}

class _LayerMarkersContent extends StatelessWidget {
  const _LayerMarkersContent({
    required this.markers,
    required this.settings,
    required this.hasSearchQuery,
    required this.onZoomTo,
  });

  final List<MapMarker> markers;
  final LayerSidebarSettings settings;
  final bool hasSearchQuery;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (markers.isEmpty) {
      if (hasSearchQuery) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: MapObjectsEmptyState(
            icon: Icons.search_off,
            title: l10n.sidebarNoMatchingMarkers,
            message: l10n.sidebarTryDifferentSearch,
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: MapObjectsEmptyState(
          icon: Icons.place_outlined,
          title: l10n.sidebarNoMarkersOnLayer,
          message: l10n.sidebarAddMarkerHint,
        ),
      );
    }

    if (settings.viewMode == SidebarViewMode.tree) {
      return _MarkerTreeView(
        groups: groupMarkers(markers, settings.markerSort, l10n),
        onZoomTo: onZoomTo,
        nested: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, marker) in markers.indexed) ...[
          if (index > 0) const Divider(height: 1),
          _MarkerListTile(
            key: ValueKey(marker.id),
            marker: marker,
            onZoomTo: onZoomTo,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _LayerZonesContent extends StatelessWidget {
  const _LayerZonesContent({
    required this.zones,
    required this.settings,
    required this.hasSearchQuery,
    required this.onZoomTo,
  });

  final List<MapZone> zones;
  final LayerSidebarSettings settings;
  final bool hasSearchQuery;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (zones.isEmpty) {
      if (hasSearchQuery) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: MapObjectsEmptyState(
            icon: Icons.search_off,
            title: l10n.sidebarNoMatchingZones,
            message: l10n.sidebarTryDifferentSearch,
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: MapObjectsEmptyState(
          icon: Icons.layers_outlined,
          title: l10n.sidebarNoZonesOnLayer,
          message: l10n.sidebarAddZoneHint,
        ),
      );
    }

    if (settings.viewMode == SidebarViewMode.tree) {
      return _ZoneTreeView(
        groups: groupZones(zones, settings.zoneSort, l10n),
        onZoomTo: onZoomTo,
        nested: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, zone) in zones.indexed) ...[
          if (index > 0) const Divider(height: 1),
          _ZoneListTile(
            key: ValueKey(zone.id),
            zone: zone,
            onZoomTo: onZoomTo,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MarkerSortSelector extends StatelessWidget {
  const _MarkerSortSelector({
    required this.value,
    required this.onChanged,
  });

  final MarkerSortField value;
  final ValueChanged<MarkerSortField> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SortFieldSelector<MarkerSortField>(
      label: l10n.sidebarSortMarkers,
      value: value,
      items: MarkerSortField.values,
      itemLabel: (field) => field.localizedLabel(l10n),
      onChanged: onChanged,
    );
  }
}

class _ZoneSortSelector extends StatelessWidget {
  const _ZoneSortSelector({
    required this.value,
    required this.onChanged,
  });

  final ZoneSortField value;
  final ValueChanged<ZoneSortField> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SortFieldSelector<ZoneSortField>(
      label: l10n.sidebarSortZones,
      value: value,
      items: ZoneSortField.values,
      itemLabel: (field) => field.localizedLabel(l10n),
      onChanged: onChanged,
    );
  }
}

class _SortFieldSelector<T> extends StatelessWidget {
  const _SortFieldSelector({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            style: theme.textTheme.bodyMedium,
            items: [
              for (final item in items)
                DropdownMenuItem(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
            ],
            onChanged: (selection) {
              if (selection != null) {
                onChanged(selection);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _MarkerTreeView extends StatelessWidget {
  const _MarkerTreeView({
    required this.groups,
    required this.onZoomTo,
    this.nested = false,
  });

  final List<MapObjectTreeGroup<MapMarker>> groups;
  final ValueChanged<LatLng> onZoomTo;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    return _MapObjectTreeScaffold(
      groups: groups,
      nested: nested,
      itemBuilder: (marker) => _MarkerListTile(
        key: ValueKey(marker.id),
        marker: marker,
        onZoomTo: onZoomTo,
      ),
    );
  }
}

class _ZoneTreeView extends StatelessWidget {
  const _ZoneTreeView({
    required this.groups,
    required this.onZoomTo,
    this.nested = false,
  });

  final List<MapObjectTreeGroup<MapZone>> groups;
  final ValueChanged<LatLng> onZoomTo;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    return _MapObjectTreeScaffold(
      groups: groups,
      nested: nested,
      itemBuilder: (zone) => _ZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      ),
    );
  }
}

class _MapObjectTreeScaffold<T> extends StatelessWidget {
  const _MapObjectTreeScaffold({
    required this.groups,
    required this.itemBuilder,
    this.nested = false,
  });

  final List<MapObjectTreeGroup<T>> groups;
  final Widget Function(T item) itemBuilder;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      shrinkWrap: nested,
      physics: nested ? const NeverScrollableScrollPhysics() : null,
      itemCount: groups.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey('tree-group-${group.key}'),
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: EdgeInsets.zero,
            leading: group.leading,
            title: Text(
              group.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              l10n.sidebarObjectCount(group.items.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            children: [
              for (final (itemIndex, item) in group.items.indexed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (itemIndex > 0) const Divider(height: 1),
                    itemBuilder(item),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MarkerListTile extends ConsumerWidget {
  const _MarkerListTile({
    super.key,
    required this.marker,
    required this.onZoomTo,
  });

  final MapMarker marker;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notesPreview = marker.notes?.trim();
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.marker &&
        selected?.id == marker.id;

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            ref.read(selectedMapObjectProvider.notifier).clear();
            onZoomTo(LatLng(marker.latitude, marker.longitude));
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MapMarkerIcon(
                  color: parseMarkerColor(marker.color),
                  iconName: marker.icon,
                  width: 28,
                  height: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${marker.latitude.toStringAsFixed(4)}, '
                        '${marker.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (notesPreview != null && notesPreview.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        MapObjectNotesPreview(markdown: notesPreview),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _MapObjectActionBar(
          actions: [
            _MapObjectIconAction(
              tooltip: marker.visible ? l10n.sidebarHideMarker : l10n.sidebarShowMarker,
              icon: marker.visible ? Icons.visibility : Icons.visibility_off,
              toggled: marker.visible,
              isToggle: true,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapMarker.updateMarker(
                  marker.copyWith(visible: !marker.visible),
                );
                ref.invalidate(markersProvider);
              },
            ),
            _MapObjectIconAction(
              tooltip: l10n.sidebarEditMarker,
              icon: Icons.edit_outlined,
              onPressed: () => updateMarkerFromForm(
                context: context,
                ref: ref,
                marker: marker,
              ),
            ),
            _MapObjectIconAction(
              tooltip: l10n.sidebarDeleteMarker,
              icon: Icons.delete_outline,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapMarker.deleteMarker(marker.id);
                ref.invalidate(markersProvider);
              },
            ),
          ],
        ),
      ],
    ),
    );
  }
}

class _ZoneListTile extends ConsumerWidget {
  const _ZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLine = zone.type == lineZoneType;
    if (isLine) {
      return _LineZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      );
    }
    final isCircle = zone.type == circleZoneType;
    if (isCircle) {
      return _CircleZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      );
    }
    final isRectangle = zone.type == rectangleZoneType;
    if (isRectangle) {
      return _RectangleZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      );
    }
    final isTrack = zone.type == trackZoneType;
    if (isTrack) {
      return _TrackZoneListTile(
        key: ValueKey(zone.id),
        zone: zone,
        onZoomTo: onZoomTo,
      );
    }
    return _GenericZoneListTile(
      key: ValueKey(zone.id),
      zone: zone,
      onZoomTo: onZoomTo,
    );
  }
}

class _LineZoneListTile extends ConsumerWidget {
  const _LineZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final zoneId = zone.id;
    final geometry = LineGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;
    final notesPreview = geometry?.notes?.trim();

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final distance = formatLineDistance(
      geometry.pathLengthMeters,
      measurementUnits,
    );

    return ColoredBox(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              ref.read(selectedMapObjectProvider.notifier).clear();
              final center = lineZoneCenter(zone);
              if (center != null) {
                onZoomTo(center);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(zone.color),
                    radius: 18,
                    child: const Icon(
                      Icons.timeline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          distance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notesPreview != null && notesPreview.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          MapObjectNotesPreview(
                            markdown: notesPreview,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MapObjectActionBar(
            actions: [
              _MapObjectIconAction(
                tooltip: geometry.showNameLabel
                    ? l10n.sidebarHideNameOnMap
                    : l10n.sidebarShowNameOnMap,
                icon: geometry.showNameLabel ? Icons.label : Icons.label_off,
                toggled: geometry.showNameLabel,
                isToggle: true,
                onPressed: () => toggleLineNameLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip: geometry.showDistanceLabel
                    ? l10n.sidebarHideDistanceOnMap
                    : l10n.sidebarShowDistanceOnMap,
                icon: geometry.showDistanceLabel
                    ? Icons.straighten
                    : Icons.straighten_outlined,
                toggled: geometry.showDistanceLabel,
                isToggle: true,
                onPressed: () =>
                    toggleLineDistanceLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip: zone.visible ? l10n.sidebarHideLine : l10n.sidebarShowLine,
                icon: zone.visible ? Icons.visibility : Icons.visibility_off,
                toggled: zone.visible,
                isToggle: true,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.updateZone(
                    zone.copyWith(visible: !zone.visible),
                  );
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
              _MapObjectIconAction(
                tooltip: l10n.sidebarEditLine,
                icon: Icons.edit_outlined,
                onPressed: () => updateLineFromForm(
                  context: context,
                  ref: ref,
                  zone: zone,
                ),
              ),
              _MapObjectIconAction(
                tooltip: l10n.sidebarDeleteLine,
                icon: Icons.delete_outline,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.deleteZone(zoneId);
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackZoneListTile extends ConsumerWidget {
  const _TrackZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final zoneId = zone.id;
    final geometry = TrackGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final distance = geometry.hasRenderablePath
        ? formatLineDistance(
            lineLengthMetersForPoints(geometry.pathPoints),
            measurementUnits,
          )
        : '—';

    return ColoredBox(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              ref.read(selectedMapObjectProvider.notifier).clear();
              final center = trackZoneCenterPoint(zone);
              if (center != null) {
                onZoomTo(center);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(zone.color),
                    radius: 18,
                    child: const Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${geometry.points.length} · $distance',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MapObjectActionBar(
            actions: [
              _MapObjectIconAction(
                tooltip: zone.visible ? l10n.sidebarHideTrack : l10n.sidebarShowTrack,
                icon: zone.visible ? Icons.visibility : Icons.visibility_off,
                toggled: zone.visible,
                isToggle: true,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.updateZone(
                    zone.copyWith(visible: !zone.visible),
                  );
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
              _MapObjectIconAction(
                tooltip: l10n.sidebarEditTrack,
                icon: Icons.edit_outlined,
                onPressed: () => updateTrackFromForm(
                  context: context,
                  ref: ref,
                  zone: zone,
                ),
              ),
              _MapObjectIconAction(
                tooltip: l10n.sidebarDeleteTrack,
                icon: Icons.delete_outline,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.deleteZone(zoneId);
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleZoneListTile extends ConsumerWidget {
  const _CircleZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final zoneId = zone.id;
    final geometry = CircleGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;
    final notesPreview = geometry?.notes?.trim();

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final radiusLabel = formatCircleSize(
      geometry.radiusMeters,
      measurementUnits,
      CircleSizeDisplay.radius,
    );
    final mapSizeLabel = formatCircleSizeForMapLabel(
      geometry.radiusMeters,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            ref.read(selectedMapObjectProvider.notifier).clear();
            onZoomTo(geometry.center);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _parseColor(zone.borderColor),
                  radius: 18,
                  child: const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mapSizeLabel == null
                            ? 'R $radiusLabel · no map label'
                            : '${geometry.sizeDisplay.localizedShortLabel(l10n)} $mapSizeLabel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (notesPreview != null && notesPreview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        MapObjectNotesPreview(
                          markdown: notesPreview,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _MapObjectActionBar(
          actions: [
            _MapObjectIconAction(
              tooltip: geometry.showNameLabel
                  ? l10n.sidebarHideNameOnMap
                  : l10n.sidebarShowNameOnMap,
              icon: geometry.showNameLabel ? Icons.label : Icons.label_off,
              toggled: geometry.showNameLabel,
              isToggle: true,
              onPressed: () => toggleCircleNameLabel(ref: ref, zoneId: zoneId),
            ),
            _MapObjectIconAction(
              tooltip: geometry.sizeDisplay.localizedToggleTooltip(l10n),
              icon: geometry.sizeDisplay == CircleSizeDisplay.none
                  ? Icons.straighten_outlined
                  : Icons.straighten,
              toggled: geometry.sizeDisplay != CircleSizeDisplay.none,
              isToggle: true,
              onPressed: () => toggleCircleSizeLabel(ref: ref, zoneId: zoneId),
            ),
            _MapObjectIconAction(
              tooltip: zone.visible ? l10n.sidebarHideCircle : l10n.sidebarShowCircle,
              icon: zone.visible ? Icons.visibility : Icons.visibility_off,
              toggled: zone.visible,
              isToggle: true,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapZone.updateZone(
                  zone.copyWith(visible: !zone.visible),
                );
                ref.read(zonesProvider.notifier).reload();
              },
            ),
            _MapObjectIconAction(
              tooltip: l10n.sidebarEditCircle,
              icon: Icons.edit_outlined,
              onPressed: () => updateCircleFromForm(
                context: context,
                ref: ref,
                zone: zone,
              ),
            ),
            _MapObjectIconAction(
              tooltip: l10n.sidebarDeleteCircle,
              icon: Icons.delete_outline,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapZone.deleteZone(zoneId);
                ref.read(zonesProvider.notifier).reload();
              },
            ),
          ],
        ),
      ],
    ),
    );
  }
}

class _RectangleZoneListTile extends ConsumerWidget {
  const _RectangleZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final zoneId = zone.id;
    final geometry = RectangleGeometry.fromZone(zone);
    final measurementUnits = ref.watch(measurementUnitsProvider);
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;
    final notesPreview = geometry?.notes?.trim();

    if (geometry == null || !geometry.isValid) {
      return _GenericZoneListTile(zone: zone, onZoomTo: onZoomTo);
    }

    final dimensionsLabel = formatRectangleDimensions(
      geometry.bounds,
      measurementUnits,
    );
    final mapSizeLabel = formatRectangleSizeForMapLabel(
      geometry.bounds,
      measurementUnits,
      geometry.sizeDisplay,
    );

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              ref.read(selectedMapObjectProvider.notifier).clear();
              onZoomTo(geometry.bounds.center);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(zone.borderColor),
                    radius: 18,
                    child: const Icon(
                      Icons.crop_square,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mapSizeLabel == null
                              ? '$dimensionsLabel · no map label'
                              : '${geometry.sizeDisplay.shortLabel} $mapSizeLabel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notesPreview != null && notesPreview.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          MapObjectNotesPreview(
                            markdown: notesPreview,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MapObjectActionBar(
            actions: [
              _MapObjectIconAction(
                tooltip: geometry.showNameLabel
                    ? l10n.sidebarHideNameOnMap
                    : l10n.sidebarShowNameOnMap,
                icon: geometry.showNameLabel ? Icons.label : Icons.label_off,
                toggled: geometry.showNameLabel,
                isToggle: true,
                onPressed: () =>
                    toggleRectangleNameLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip:
                    rectangleSizeDisplayToggleTooltip(geometry.sizeDisplay),
                icon: geometry.sizeDisplay == RectangleSizeDisplay.none
                    ? Icons.straighten_outlined
                    : Icons.straighten,
                toggled: geometry.sizeDisplay != RectangleSizeDisplay.none,
                isToggle: true,
                onPressed: () =>
                    toggleRectangleSizeLabel(ref: ref, zoneId: zoneId),
              ),
              _MapObjectIconAction(
                tooltip: zone.visible
                    ? l10n.sidebarHideRectangle
                    : l10n.sidebarShowRectangle,
                icon: zone.visible ? Icons.visibility : Icons.visibility_off,
                toggled: zone.visible,
                isToggle: true,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.updateZone(
                    zone.copyWith(visible: !zone.visible),
                  );
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
              _MapObjectIconAction(
                tooltip: l10n.sidebarEditRectangle,
                icon: Icons.edit_outlined,
                onPressed: () => updateRectangleFromForm(
                  context: context,
                  ref: ref,
                  zone: zone,
                ),
              ),
              _MapObjectIconAction(
                tooltip: l10n.sidebarDeleteRectangle,
                icon: Icons.delete_outline,
                onPressed: () async {
                  final client = ref.read(serverClientProvider);
                  await client.mapZone.deleteZone(zoneId);
                  ref.read(zonesProvider.notifier).reload();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenericZoneListTile extends ConsumerWidget {
  const _GenericZoneListTile({
    super.key,
    required this.zone,
    required this.onZoomTo,
  });

  final MapZone zone;
  final ValueChanged<LatLng> onZoomTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedMapObjectProvider);
    final isSelected = selected?.kind == SelectedMapObjectKind.zone &&
        selected?.id == zone.id;

    return ColoredBox(
      color: _selectionHighlightColor(theme, isSelected),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            ref.read(selectedMapObjectProvider.notifier).clear();
            final center = rectangleZoneCenter(zone) ??
                circleZoneCenter(zone) ??
                lineZoneCenter(zone);
            if (center != null) {
              onZoomTo(center);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _parseColor(zone.color),
                  radius: 18,
                  child: const Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        zone.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _MapObjectActionBar(
          actions: [
            _MapObjectIconAction(
              tooltip: zone.visible ? l10n.sidebarHideZone : l10n.sidebarShowZone,
              icon: zone.visible ? Icons.visibility : Icons.visibility_off,
              toggled: zone.visible,
              isToggle: true,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapZone.updateZone(
                  zone.copyWith(visible: !zone.visible),
                );
                ref.read(zonesProvider.notifier).reload();
              },
            ),
            _MapObjectIconAction(
              tooltip: l10n.sidebarDeleteZone,
              icon: Icons.delete_outline,
              onPressed: () async {
                final client = ref.read(serverClientProvider);
                await client.mapZone.deleteZone(zone.id);
                ref.read(zonesProvider.notifier).reload();
              },
            ),
          ],
        ),
      ],
    ),
    );
  }
}

class _MapObjectActionBar extends StatelessWidget {
  const _MapObjectActionBar({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          children: actions,
        ),
      ),
    );
  }
}

class _MapObjectIconAction extends StatelessWidget {
  const _MapObjectIconAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.toggled = false,
    this.isToggle = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool toggled;
  final bool isToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      style: isToggle
          ? (toggled
              ? IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                )
              : IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.55),
                ))
          : IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
      icon: Icon(icon, size: 20),
    );
  }
}

Color _parseColor(String value) => parseMarkerColor(value);

Color _selectionHighlightColor(ThemeData theme, bool isSelected) {
  return isSelected
      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
      : Colors.transparent;
}
