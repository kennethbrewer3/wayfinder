import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/l10n/localized_labels.dart';
import '../models/marker_icon_categories.dart';
import '../models/marker_icon_category_catalog.dart';
import '../models/marker_icon_sort.dart';
import '../providers/marker_icon_providers.dart';

class MarkerIconCategoryField extends ConsumerWidget {
  const MarkerIconCategoryField({
    super.key,
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.watch(markerIconCategoryCatalogProvider).valueOrNull ??
        MarkerIconCategoryCatalog.fallback();
    final selectedValue = categories.contains(value)
        ? value
        : categories.defaultCategoryKey;

    return DropdownButtonFormField<String>(
      key: ValueKey(selectedValue),
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: l10n.markerIconsCategoryLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final category in categories.categories)
          DropdownMenuItem(
            value: category.key,
            child: Text(
              markerIconCategoryDisplayLabel(
                l10n,
                category.key,
                catalog: categories,
              ),
            ),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}

/// Groups catalog entries by category in display order.
Map<String, List<T>> groupMarkerIconsByCategory<T>({
  required Iterable<T> items,
  required String Function(T item) categoryFor,
  List<String>? categoryOrder,
  String Function(T item)? labelFor,
}) {
  final grouped = <String, List<T>>{};
  for (final item in items) {
    grouped.putIfAbsent(categoryFor(item), () => []).add(item);
  }

  final order = categoryOrder ?? MarkerIconCategories.orderedKeys;
  final ordered = <String, List<T>>{};
  for (final category in order) {
    final categoryItems = grouped.remove(category);
    if (categoryItems != null && categoryItems.isNotEmpty) {
      if (labelFor != null) {
        categoryItems.sort(
          (a, b) => compareMarkerIconDisplayLabels(labelFor(a), labelFor(b)),
        );
      }
      ordered[category] = categoryItems;
    }
  }
  for (final entry in grouped.entries) {
    final categoryItems = entry.value;
    if (labelFor != null) {
      categoryItems.sort(
        (a, b) => compareMarkerIconDisplayLabels(labelFor(a), labelFor(b)),
      );
    }
    ordered[entry.key] = categoryItems;
  }
  return ordered;
}
