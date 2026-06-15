import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/providers/map_providers.dart';
import '../models/search_result.dart';
import '../../markers/providers/markers_provider.dart';

class MapSearchBar extends ConsumerWidget {
  const MapSearchBar({
    super.key,
    required this.onResultSelected,
  });

  final ValueChanged<SearchResult> onResultSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebar = ref.watch(sidebarProvider);
    final markersAsync = ref.watch(markersProvider);
    final zonesAsync = ref.watch(zonesProvider);

    final results = markersAsync.maybeWhen(
      data: (markers) => zonesAsync.maybeWhen(
        data: (zones) => buildSearchResults(
          query: sidebar.searchQuery,
          markers: markers,
          zones: zones,
        ),
        orElse: () => const <SearchResult>[],
      ),
      orElse: () => const <SearchResult>[],
    );

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search markers, zones, or coordinates',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: sidebar.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        ref.read(sidebarProvider.notifier).setSearchQuery('');
                      },
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              ref.read(sidebarProvider.notifier).setSearchQuery(value);
            },
          ),
          if (results.isNotEmpty)
            ConstrainedBox(
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
        ],
      ),
    );
  }

  IconData _iconFor(SearchResultType type) {
    return switch (type) {
      SearchResultType.marker => Icons.place,
      SearchResultType.zone => Icons.layers,
      SearchResultType.coordinate => Icons.my_location,
    };
  }
}
