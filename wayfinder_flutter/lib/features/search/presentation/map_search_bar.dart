import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../geocoding/data/geocoding_repository.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import '../../map/providers/map_providers.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../models/search_result.dart';
import '../providers/search_query_provider.dart';

List<SearchResult> combinedSearchResults(
  WidgetRef ref, {
  required String query,
}) {
  final markers = ref.read(markersProvider).valueOrNull ?? const [];
  final zones = ref.read(zonesProvider).valueOrNull ?? const [];
  return buildSearchResults(
    query: query,
    markers: markers,
    zones: zones,
  );
}

List<SearchResult> watchLocalSearchResults(WidgetRef ref) {
  final query = ref.watch(
    debouncedMapSearchQueryProvider,
  );
  final markers = ref.watch(markersProvider).valueOrNull ?? const [];
  final zones = ref.watch(zonesProvider).valueOrNull ?? const [];

  return buildSearchResults(
    query: query,
    markers: markers,
    zones: zones,
  );
}

List<SearchResult> watchCombinedSearchResults(WidgetRef ref) {
  final query = ref.watch(debouncedMapSearchQueryProvider);
  final local = watchLocalSearchResults(ref);
  final trimmed = query.trim();
  if (trimmed.length < mapSearchMinGeocodingLength) {
    return local;
  }

  final geocodingAsync = ref.watch(geocodingSearchProvider(trimmed));
  final places = geocodingAsync.valueOrNull ?? const [];
  return [
    ...local,
    ...places.map(geocodingPlaceToSearchResult),
  ];
}

SearchResult? pickPrimarySearchResult(List<SearchResult> results) {
  for (final type in [
    SearchResultType.coordinate,
    SearchResultType.address,
    SearchResultType.place,
    SearchResultType.marker,
    SearchResultType.zone,
  ]) {
    for (final result in results) {
      if (result.type == type) {
        return result;
      }
    }
  }
  return null;
}

class MapSearchField extends ConsumerStatefulWidget {
  const MapSearchField({
    super.key,
    this.onResultSelected,
  });

  final ValueChanged<SearchResult>? onResultSelected;

  @override
  ConsumerState<MapSearchField> createState() => _MapSearchFieldState();
}

class _MapSearchFieldState extends ConsumerState<MapSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(sidebarProvider).searchQuery,
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(String query) async {
    final callback = widget.onResultSelected;
    if (callback == null) return;

    ref.read(sidebarProvider.notifier).setSearchQuery(query);
    ref.read(debouncedMapSearchQueryProvider.notifier).flush(query);

    final trimmed = query.trim();
    var results = combinedSearchResults(ref, query: trimmed);
    if (trimmed.length >= mapSearchMinGeocodingLength) {
      final places =
          await ref.read(geocodingRepositoryProvider).searchPlaces(trimmed);
      results = [
        ...results.where((result) => result.type != SearchResultType.place),
        ...places.map(geocodingPlaceToSearchResult),
      ];
    }

    final result = pickPrimarySearchResult(results);
    if (result != null) {
      callback(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      sidebarProvider.select((sidebar) => sidebar.searchQuery),
      (previous, next) {
        if (_controller.text == next) {
          return;
        }
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      },
    );

    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText:
              'Search places, markers, zones, or lat, lng (e.g. ${_coordinateExample()})',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(sidebarProvider.notifier).setSearchQuery('');
                    ref.read(debouncedMapSearchQueryProvider.notifier).flush('');
                    _focusNode.requestFocus();
                  },
                ),
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          ref.read(sidebarProvider.notifier).setSearchQuery(value);
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        onSubmitted: _submitSearch,
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
    final results = watchCombinedSearchResults(ref);
    final query = ref.watch(debouncedMapSearchQueryProvider).trim();
    final geocodingLoading = query.length >= mapSearchMinGeocodingLength &&
        ref.watch(geocodingSearchProvider(query)).isLoading;

    if (results.isEmpty && !geocodingLoading) {
      return const SizedBox.shrink();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (geocodingLoading)
                const LinearProgressIndicator(minHeight: 2),
              if (results.isNotEmpty)
                Flexible(
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
    final results = watchCombinedSearchResults(ref);
    final query = ref.watch(debouncedMapSearchQueryProvider).trim();
    final geocodingLoading = query.length >= mapSearchMinGeocodingLength &&
        ref.watch(geocodingSearchProvider(query)).isLoading;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MapSearchField(),
          if (geocodingLoading || results.isNotEmpty)
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
    SearchResultType.place => Icons.location_city,
    SearchResultType.address => Icons.home_outlined,
  };
}

String _coordinateExample() {
  final lat = AppConstants.defaultLatitude.toStringAsFixed(3);
  final lng = AppConstants.defaultLongitude.toStringAsFixed(3);
  return '$lat, $lng';
}

/// Backwards-compatible alias used by older call sites.
List<SearchResult> watchMapSearchResults(WidgetRef ref) =>
    watchCombinedSearchResults(ref);
