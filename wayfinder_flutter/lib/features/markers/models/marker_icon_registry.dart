import 'package:flutter/material.dart';

class MarkerIconOption {
  const MarkerIconOption({
    required this.key,
    required this.icon,
    required this.label,
  });

  final String key;
  final IconData icon;
  final String label;
}

const markerIconOptions = <MarkerIconOption>[
  MarkerIconOption(key: 'place', icon: Icons.place, label: 'Place'),
  MarkerIconOption(key: 'home', icon: Icons.home, label: 'Home'),
  MarkerIconOption(key: 'house', icon: Icons.house, label: 'House'),
  MarkerIconOption(key: 'apartment', icon: Icons.apartment, label: 'Apartment'),
  MarkerIconOption(key: 'work', icon: Icons.work, label: 'Work'),
  MarkerIconOption(key: 'school', icon: Icons.school, label: 'School'),
  MarkerIconOption(key: 'store', icon: Icons.store, label: 'Store'),
  MarkerIconOption(key: 'restaurant', icon: Icons.restaurant, label: 'Food'),
  MarkerIconOption(key: 'local_cafe', icon: Icons.local_cafe, label: 'Cafe'),
  MarkerIconOption(key: 'hotel', icon: Icons.hotel, label: 'Hotel'),
  MarkerIconOption(key: 'church', icon: Icons.church, label: 'Church'),
  MarkerIconOption(key: 'mosque', icon: Icons.mosque, label: 'Mosque'),
  MarkerIconOption(key: 'community_center', icon: Icons.groups, label: 'Community'),
  MarkerIconOption(key: 'local_hospital', icon: Icons.local_hospital, label: 'Medical'),
  MarkerIconOption(key: 'directions_car', icon: Icons.directions_car, label: 'Vehicle'),
  MarkerIconOption(key: 'directions_bike', icon: Icons.directions_bike, label: 'Bike'),
  MarkerIconOption(key: 'hiking', icon: Icons.hiking, label: 'Trail'),
  MarkerIconOption(key: 'park', icon: Icons.park, label: 'Park'),
  MarkerIconOption(key: 'flag', icon: Icons.flag, label: 'Flag'),
  MarkerIconOption(key: 'star', icon: Icons.star, label: 'Star'),
  MarkerIconOption(key: 'favorite', icon: Icons.favorite, label: 'Favorite'),
  MarkerIconOption(key: 'warning', icon: Icons.warning, label: 'Warning'),
  MarkerIconOption(key: 'info', icon: Icons.info, label: 'Info'),
  MarkerIconOption(key: 'my_location', icon: Icons.my_location, label: 'Location'),
  MarkerIconOption(key: 'camera', icon: Icons.camera_alt, label: 'Photo'),
  MarkerIconOption(key: 'pets', icon: Icons.pets, label: 'Pets'),
  MarkerIconOption(key: 'cell_tower', icon: Icons.cell_tower, label: 'Radio tower'),
  MarkerIconOption(
    key: 'radio_repeater',
    icon: Icons.settings_input_antenna,
    label: 'Radio repeater',
  ),
];

IconData markerIconData(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.icon;
    }
  }
  return Icons.place;
}

String markerIconLabel(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.label;
    }
  }
  return 'Place';
}

String normalizeMarkerIcon(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.key;
    }
  }
  return 'place';
}

MarkerIconOption? markerIconOption(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option;
    }
  }
  return null;
}

String? suggestMarkerIconForName(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }

  const suggestions = <String, String>{
    'home': 'home',
    'house': 'house',
    'apartment': 'apartment',
    'work': 'work',
    'office': 'work',
    'school': 'school',
    'store': 'store',
    'shop': 'store',
    'restaurant': 'restaurant',
    'cafe': 'local_cafe',
    'coffee': 'local_cafe',
    'hotel': 'hotel',
    'church': 'church',
    'chapel': 'church',
    'cathedral': 'church',
    'mosque': 'mosque',
    'community center': 'community_center',
    'community centre': 'community_center',
    'community': 'community_center',
    'hospital': 'local_hospital',
    'medical': 'local_hospital',
    'car': 'directions_car',
    'bike': 'directions_bike',
    'trail': 'hiking',
    'park': 'park',
    'flag': 'flag',
    'star': 'star',
    'pet': 'pets',
    'pets': 'pets',
    'repeater': 'radio_repeater',
    'radio repeater': 'radio_repeater',
    'tower': 'cell_tower',
    'radio tower': 'cell_tower',
    'radio': 'radio_repeater',
  };

  for (final entry in suggestions.entries) {
    if (normalized.contains(entry.key)) {
      return entry.value;
    }
  }
  return null;
}
