/// Default marker icon categories seeded when the table is empty.
abstract final class MarkerIconCategorySeed {
  static const defaultCategoryKey = 'custom';

  static const defaults = [
    (key: 'general', label: 'General', sortOrder: 0),
    (key: 'places', label: 'Places & buildings', sortOrder: 1),
    (key: 'transportation', label: 'Transportation', sortOrder: 2),
    (key: 'people_animals', label: 'People & animals', sortOrder: 3),
    (key: 'infrastructure', label: 'Infrastructure', sortOrder: 4),
    (key: 'emergency', label: 'Emergency & medical', sortOrder: 5),
    (key: 'military', label: 'Military & defense', sortOrder: 6),
    (
      key: 'shelter_preparedness',
      label: 'Shelter & preparedness',
      sortOrder: 7,
    ),
    (key: 'recreation', label: 'Recreation & outdoors', sortOrder: 8),
    (key: 'agriculture', label: 'Agriculture', sortOrder: 9),
    (key: defaultCategoryKey, label: 'Custom', sortOrder: 10),
  ];
}
