import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/constants.dart';
import '../../geocoding/providers/geocoding_providers.dart';
import '../../map/providers/map_providers.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../models/search_result.dart';
import '../providers/search_query_provider.dart';

List<SearchResult> combinedSearchResults(
  WidgetRef ref, {
  required AppLocalizations l10n,
  required String query,
}) {
  final markers = ref.read(markersProvider).valueOrNull ?? const [];
  final zones = ref.read(zonesProvider).valueOrNull ?? const [];
  return buildSearchResults(
    l10n: l10n,
    query: query,
    markers: markers,
    zones: zones,
  );
}

List<SearchResult> watchLocalSearchResults(
  WidgetRef ref,
  AppLocalizations l10n,
) {
  final query = ref.watch(
    debouncedMapSearchQueryProvider,
  );
  final markers = ref.watch(markersProvider).valueOrNull ?? const [];
  final zones = ref.watch(zonesProvider).valueOrNull ?? const [];

  return buildSearchResults(
    l10n: l10n,
    query: query,
    markers: markers,
    zones: zones,
  );
}

List<SearchResult> watchCombinedSearchResults(
  WidgetRef ref,
  AppLocalizations l10n,
) {
  final query = ref.watch(debouncedMapSearchQueryProvider);
  final local = watchLocalSearchResults(ref, l10n);
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
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(String query) async {
    final trimmed = query.trim();
    ref.read(sidebarProvider.notifier).setSearchQuery(trimmed);
    ref.read(debouncedMapSearchQueryProvider.notifier).submit(trimmed);
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(sidebarProvider.notifier).setSearchQuery('');
    ref.read(debouncedMapSearchQueryProvider.notifier).clear();
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      sidebarProvider.select((sidebar) => sidebar.searchQuery),
      (previous, next) {
        if (next.isEmpty && _controller.text.isNotEmpty) {
          _controller.clear();
        }
      },
    );

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: l10n.searchHint(_coordinateExample()),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: l10n.actionCancel,
                  onPressed: _clearSearch,
                ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                tooltip: l10n.actionSearch,
                onPressed: () => _submitSearch(_controller.text),
              ),
            ],
          ),
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (_) {
          // Hide stale results while editing; do not sync sidebar or reset text.
          ref.read(debouncedMapSearchQueryProvider.notifier).clear();
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
    final l10n = AppLocalizations.of(context)!;
    final results = watchCombinedSearchResults(ref, l10n);
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
    final l10n = AppLocalizations.of(context)!;
    final results = watchCombinedSearchResults(ref, l10n);
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
List<SearchResult> watchMapSearchResults(
  WidgetRef ref,
  AppLocalizations l10n,
) =>
    watchCombinedSearchResults(ref, l10n);
