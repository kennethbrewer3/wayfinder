/// Curated US coastal region bbox for NOAA tide pack import.
class TideCoastalRegionDef {
  const TideCoastalRegionDef({
    required this.id,
    required this.name,
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
  });

  final String id;
  final String name;
  final double minLatitude;
  final double minLongitude;
  final double maxLatitude;
  final double maxLongitude;

  double get centerLatitude => (minLatitude + maxLatitude) / 2;
  double get centerLongitude => (minLongitude + maxLongitude) / 2;
}

/// Curated US coastal regions for NOAA tide pack import.
abstract final class TideCoastalRegions {
  static const List<TideCoastalRegionDef> all = [
    TideCoastalRegionDef(
      id: 'mid-atlantic',
      name: 'Mid-Atlantic',
      minLatitude: 36.5,
      minLongitude: -77.5,
      maxLatitude: 41.5,
      maxLongitude: -72.0,
    ),
    TideCoastalRegionDef(
      id: 'new-england',
      name: 'New England',
      minLatitude: 40.5,
      minLongitude: -72.5,
      maxLatitude: 45.5,
      maxLongitude: -66.0,
    ),
    TideCoastalRegionDef(
      id: 'southeast',
      name: 'Southeast',
      minLatitude: 25.0,
      minLongitude: -82.0,
      maxLatitude: 36.5,
      maxLongitude: -75.0,
    ),
    TideCoastalRegionDef(
      id: 'gulf',
      name: 'Gulf',
      minLatitude: 24.0,
      minLongitude: -98.0,
      maxLatitude: 31.0,
      maxLongitude: -81.5,
    ),
    TideCoastalRegionDef(
      id: 'west-coast-ca',
      name: 'West Coast CA',
      minLatitude: 32.0,
      minLongitude: -125.0,
      maxLatitude: 42.0,
      maxLongitude: -116.0,
    ),
    TideCoastalRegionDef(
      id: 'pacific-nw',
      name: 'Pacific NW',
      minLatitude: 42.0,
      minLongitude: -125.5,
      maxLatitude: 49.0,
      maxLongitude: -122.0,
    ),
    TideCoastalRegionDef(
      id: 'alaska-south-central',
      name: 'Alaska south-central',
      minLatitude: 55.0,
      minLongitude: -155.0,
      maxLatitude: 62.0,
      maxLongitude: -140.0,
    ),
    TideCoastalRegionDef(
      id: 'hawaii',
      name: 'Hawaii',
      minLatitude: 18.5,
      minLongitude: -161.0,
      maxLatitude: 22.5,
      maxLongitude: -154.0,
    ),
    TideCoastalRegionDef(
      id: 'puerto-rico',
      name: 'Puerto Rico',
      minLatitude: 17.8,
      minLongitude: -67.4,
      maxLatitude: 18.6,
      maxLongitude: -65.2,
    ),
  ];

  static TideCoastalRegionDef? byId(String id) {
    final key = id.trim().toLowerCase();
    for (final region in all) {
      if (region.id == key) {
        return region;
      }
    }
    return null;
  }
}
