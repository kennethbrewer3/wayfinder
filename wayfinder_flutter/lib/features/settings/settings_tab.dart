/// Settings screen tabs and their URL path segments.
enum SettingsTab {
  general('general'),
  mapTiles('map-tiles'),
  geocoding('geocoding'),
  backup('backup');

  const SettingsTab(this.slug);

  final String slug;

  String get routePath => '/settings/$slug';

  static bool isValidSlug(String? slug) {
    if (slug == null || slug.isEmpty) {
      return false;
    }
    return SettingsTab.values.any((tab) => tab.slug == slug);
  }

  static SettingsTab fromSlug(String? slug) {
    return SettingsTab.values.firstWhere(
      (tab) => tab.slug == slug,
      orElse: () => SettingsTab.general,
    );
  }
}
