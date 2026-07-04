import 'package:wayfinder_client/wayfinder_client.dart';

import 'marker_icon_categories.dart';

/// Runtime marker icon categories loaded from the server.
class MarkerIconCategoryCatalog {
  const MarkerIconCategoryCatalog(this.categories);

  final List<MarkerIconCategoryDefinition> categories;

  static const _fallbackLabels = {
    MarkerIconCategories.general: 'General',
    MarkerIconCategories.places: 'Places & buildings',
    MarkerIconCategories.transportation: 'Transportation',
    MarkerIconCategories.peopleAnimals: 'People & animals',
    MarkerIconCategories.infrastructure: 'Infrastructure',
    MarkerIconCategories.emergency: 'Emergency & medical',
    MarkerIconCategories.military: 'Military & defense',
    MarkerIconCategories.shelterPreparedness: 'Shelter & preparedness',
    MarkerIconCategories.recreation: 'Recreation & outdoors',
    MarkerIconCategories.agriculture: 'Agriculture',
    MarkerIconCategories.custom: 'Custom',
  };

  factory MarkerIconCategoryCatalog.fallback() {
    return MarkerIconCategoryCatalog([
      for (var i = 0; i < MarkerIconCategories.orderedKeys.length; i++)
        MarkerIconCategoryDefinition(
          key: MarkerIconCategories.orderedKeys[i],
          label: _fallbackLabels[MarkerIconCategories.orderedKeys[i]] ??
              MarkerIconCategories.orderedKeys[i],
          sortOrder: i,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
    ]);
  }

  List<String> get orderedKeys =>
      categories.map((category) => category.key).toList(growable: false);

  String labelFor(String key) {
    for (final category in categories) {
      if (category.key == key) {
        return category.label;
      }
    }
    return _fallbackLabels[key] ?? key;
  }

  bool contains(String key) => categories.any((category) => category.key == key);

  String get defaultCategoryKey =>
      categories
          .where((category) => category.key == MarkerIconCategories.custom)
          .map((category) => category.key)
          .firstOrNull ??
      categories.firstOrNull?.key ??
      MarkerIconCategories.custom;
}
