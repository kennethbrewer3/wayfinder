import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../map/providers/map_providers.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../models/search_result.dart';

List<SearchResult> watchMapSearchResults(WidgetRef ref) {
  final sidebar = ref.watch(sidebarProvider);
  final markers = ref.watch(markersProvider).valueOrNull ?? const [];
  final zones = ref.watch(zonesProvider).valueOrNull ?? const [];

  return buildSearchResults(
    query: sidebar.searchQuery,
    markers: markers,
    zones: zones,
  );
}

SearchResult? pickPrimarySearchResult(List<SearchResult> results) {
  for (final result in results) {
    if (result.type == SearchResultType.coordinate) {
      return result;
    }
  }
  return results.isEmpty ? null : results.first;
}

class MapSearchField extends ConsumerWidget {
  const MapSearchField({
    super.key,
    this.onResultSelected,
  });

  final ValueChanged<SearchResult>? onResultSelected;

  void _submitSearch(WidgetRef ref, String query) {
    final callback = onResultSelected;
    if (callback == null) return;

    ref.read(sidebarProvider.notifier).setSearchQuery(query);
    final markers = ref.read(markersProvider).valueOrNull ?? const [];
    final zones = ref.read(zonesProvider).valueOrNull ?? const [];
    final result = pickPrimarySearchResult(
      buildSearchResults(
        query: query,
        markers: markers,
        zones: zones,
      ),
    );
    if (result != null) {
      callback(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebar = ref.watch(sidebarProvider);
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: TextField(
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText:
            'Search markers, zones, or lat, lng (e.g. ${_coordinateExample()})',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        suffixIcon: sidebar.searchQuery.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.clear,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                onPressed: () {
                  ref.read(sidebarProvider.notifier).setSearchQuery('');
                },
              ),
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (value) {
        ref.read(sidebarProvider.notifier).setSearchQuery(value);
      },
      textInputAction: TextInputAction.search,
      onSubmitted: (value) => _submitSearch(ref, value),
      ),
    );
  }
}

class MapSearchResults extends ConsumerWidget {
  const MapSearchResults({
    super.key,
    required this.onResultSelected,
  });

  final ValueChanged<SearchResult> onResultSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = watchMapSearchResults(ref);
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final result = results[index];
            return ListTile(
              dense: true,
              leading: Icon(_iconFor(result.type)),
              title: Text(result.label),
              subtitle: Text(result.subtitle),
              onTap: () => onResultSelected(result),
            );
          },
        ),
      ),
    ),
    );
  }
}

class MapSearchBar extends ConsumerWidget {
  const MapSearchBar({
    super.key,
    required this.onResultSelected,
  });

  final ValueChanged<SearchResult> onResultSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = watchMapSearchResults(ref);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MapSearchField(),
          if (results.isNotEmpty)
            MapSearchResults(onResultSelected: onResultSelected),
        ],
      ),
    );
  }
}

IconData _iconFor(SearchResultType type) {
  return switch (type) {
    SearchResultType.marker => Icons.place,
    SearchResultType.zone => Icons.layers,
    SearchResultType.coordinate => Icons.my_location,
  };
}

String _coordinateExample() {
  final lat = AppConstants.defaultLatitude.toStringAsFixed(3);
  final lng = AppConstants.defaultLongitude.toStringAsFixed(3);
  return '$lat, $lng';
}
