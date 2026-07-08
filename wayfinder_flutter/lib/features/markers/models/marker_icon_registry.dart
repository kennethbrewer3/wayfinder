import 'package:flutter/material.dart';

import 'marker_icon_categories.dart';

const markerIconGlyphScaleMin = 0.5;
const markerIconGlyphScaleMax = 5.0;
const markerIconGlyphScaleDivisions = 45;
const defaultMarkerIconKey = 'my_location';

double clampMarkerIconGlyphScale(double scale) =>
    scale.clamp(markerIconGlyphScaleMin, markerIconGlyphScaleMax);

class MarkerIconOption {
  const MarkerIconOption({
    required this.key,
    required this.icon,
    required this.label,
    this.assetPath,
    this.svgUrl,
    this.emoji,
    this.coloredAsset = true,
    this.glyphScale = 1.0,
    this.category,
    this.iconBackgroundColor = '#FFFFFF',
  });

  final String key;
  final IconData icon;
  final String label;
  final String? assetPath;
  final String? svgUrl;
  final String? emoji;
  final bool coloredAsset;
  final double glyphScale;
  final String? category;
  final String iconBackgroundColor;

  String get resolvedCategory =>
      markerIconCategoryForKey(key, override: category);

  /// Bundled SVG path; every built-in icon has `assets/markers/{key}.svg`.
  String get resolvedAssetPath => assetPath ?? 'assets/markers/$key.svg';
}

const markerIconOptions = <MarkerIconOption>[
  MarkerIconOption(
    key: 'my_location',
    icon: Icons.my_location,
    assetPath: 'assets/markers/my_location.svg',
    label: 'Location',
  ),
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
  MarkerIconOption(
    key: 'community_center',
    icon: Icons.groups,
    label: 'Community',
  ),
  MarkerIconOption(
    key: 'local_hospital',
    icon: Icons.local_hospital,
    assetPath: 'assets/markers/local_hospital.svg',
    label: 'Hospital',
  ),
  MarkerIconOption(
    key: 'directions_car',
    icon: Icons.directions_car,
    label: 'Vehicle',
  ),
  MarkerIconOption(
    key: 'directions_bike',
    icon: Icons.directions_bike,
    label: 'Bike',
  ),
  MarkerIconOption(key: 'hiking', icon: Icons.hiking, label: 'Trail'),
  MarkerIconOption(key: 'park', icon: Icons.park, label: 'Park'),
  MarkerIconOption(
    key: 'monument',
    icon: Icons.account_balance,
    label: 'Monument',
  ),
  MarkerIconOption(
    key: 'geocache',
    icon: Icons.travel_explore,
    label: 'Geocache',
  ),
  MarkerIconOption(key: 'flag', icon: Icons.flag, label: 'Flag'),
  MarkerIconOption(key: 'star', icon: Icons.star, label: 'Star'),
  MarkerIconOption(key: 'favorite', icon: Icons.favorite, label: 'Favorite'),
  MarkerIconOption(key: 'warning', icon: Icons.warning, label: 'Warning'),
  MarkerIconOption(key: 'info', icon: Icons.info, label: 'Info'),
  MarkerIconOption(key: 'camera', icon: Icons.camera_alt, label: 'Photo'),
  MarkerIconOption(key: 'pets', icon: Icons.pets, label: 'Pets'),
  MarkerIconOption(key: 'man', icon: Icons.man, label: 'Man'),
  MarkerIconOption(key: 'woman', icon: Icons.woman, label: 'Woman'),
  MarkerIconOption(key: 'boy', icon: Icons.boy, label: 'Boy'),
  MarkerIconOption(key: 'girl', icon: Icons.girl, label: 'Girl'),
  MarkerIconOption(
    key: 'cat',
    icon: Icons.pets,
    assetPath: 'assets/markers/cat.svg',
    label: 'Cat',
  ),
  MarkerIconOption(
    key: 'dog',
    icon: Icons.pets,
    assetPath: 'assets/markers/dog.svg',
    label: 'Dog',
  ),
  MarkerIconOption(
    key: 'cell_tower',
    icon: Icons.cell_tower,
    assetPath: 'assets/markers/cell_tower.svg',
    label: 'Cell tower',
  ),
  MarkerIconOption(
    key: 'radio_station',
    icon: Icons.radio,
    assetPath: 'assets/markers/radio_station.svg',
    label: 'Radio station',
  ),
  MarkerIconOption(
    key: 'weather_station',
    icon: Icons.device_thermostat,
    label: 'Weather station',
  ),
  MarkerIconOption(
    key: 'radio_repeater',
    icon: Icons.settings_input_antenna,
    label: 'Radio repeater',
  ),
  MarkerIconOption(key: 'water', icon: Icons.water_drop, label: 'Water'),
  MarkerIconOption(
    key: 'supply_cache',
    icon: Icons.inventory_2,
    label: 'Supply cache',
  ),
  MarkerIconOption(key: 'retreat', icon: Icons.cabin, label: 'Retreat'),
  MarkerIconOption(
    key: 'camp',
    icon: Icons.local_fire_department,
    label: 'Camp',
  ),
  MarkerIconOption(key: 'fuel', icon: Icons.local_gas_station, label: 'Fuel'),
  MarkerIconOption(key: 'gate', icon: Icons.fence, label: 'Gate'),
  MarkerIconOption(key: 'crossing', icon: Icons.add_road, label: 'Crossing'),
  MarkerIconOption(key: 'lookout', icon: Icons.visibility, label: 'Lookout'),
  MarkerIconOption(
    key: 'solar_power_plant',
    icon: Icons.solar_power,
    assetPath: 'assets/markers/solar_power_plant.svg',
    label: 'Power',
  ),
  MarkerIconOption(
    key: 'power_plant',
    icon: Icons.factory,
    label: 'Power plant',
  ),
  MarkerIconOption(
    key: 'nuclear_power_plant',
    icon: Icons.bolt,
    assetPath: 'assets/markers/nuclear_power_plant.svg',
    label: 'Nuclear power plant',
  ),
  MarkerIconOption(
    key: 'nuclear_weapons_facility',
    icon: Icons.warning,
    label: 'Nuclear weapons facility',
  ),
  MarkerIconOption(key: 'garden', icon: Icons.agriculture, label: 'Garden'),
  MarkerIconOption(key: 'staging', icon: Icons.local_parking, label: 'Staging'),
  MarkerIconOption(key: 'hazard', icon: Icons.dangerous, label: 'Hazard'),
  MarkerIconOption(
    key: 'restricted',
    icon: Icons.do_not_disturb_on,
    label: 'Restricted',
  ),
  MarkerIconOption(key: 'rally', icon: Icons.event, label: 'Rally point'),
  MarkerIconOption(key: 'workshop', icon: Icons.build, label: 'Workshop'),
  MarkerIconOption(key: 'boat', icon: Icons.directions_boat, label: 'Boat'),
  MarkerIconOption(
    key: 'port',
    icon: Icons.anchor,
    assetPath: 'assets/markers/port.svg',
    label: 'Port',
  ),
  MarkerIconOption(
    key: 'dock',
    icon: Icons.deck,
    assetPath: 'assets/markers/dock.svg',
    label: 'Lake dock',
  ),
  MarkerIconOption(key: 'ferry', icon: Icons.directions_ferry, label: 'Ferry'),
  MarkerIconOption(
    key: 'yacht',
    icon: Icons.directions_boat_filled,
    label: 'Yacht',
  ),
  MarkerIconOption(key: 'sailboat', icon: Icons.sailing, label: 'Sailboat'),
  MarkerIconOption(
    key: 'river_boat',
    icon: Icons.kayaking,
    label: 'River boat',
  ),
  MarkerIconOption(
    key: 'airstrip',
    icon: Icons.flight_takeoff,
    label: 'Airstrip / Airport',
  ),
  MarkerIconOption(key: 'defense', icon: Icons.shield, label: 'Defense'),
  MarkerIconOption(key: 'army_base', icon: Icons.fort, label: 'Army base'),
  MarkerIconOption(key: 'navy_base', icon: Icons.anchor, label: 'Navy base'),
  MarkerIconOption(
    key: 'marine_corps_base',
    icon: Icons.shield,
    assetPath: 'assets/markers/marine_corps_base.svg',
    label: 'Marine Corps base',
  ),
  MarkerIconOption(
    key: 'air_force_base',
    icon: Icons.flight,
    label: 'Air Force base',
  ),
  MarkerIconOption(
    key: 'space_force_base',
    icon: Icons.rocket_launch,
    label: 'Space Force base',
  ),
  MarkerIconOption(
    key: 'coast_guard_base',
    icon: Icons.waves,
    assetPath: 'assets/markers/coast_guard_base.svg',
    label: 'Coast Guard base',
  ),
  MarkerIconOption(key: 'hunting', icon: Icons.track_changes, label: 'Hunting'),
  MarkerIconOption(key: 'fishing', icon: Icons.set_meal, label: 'Fishing'),
  MarkerIconOption(key: 'foraging', icon: Icons.eco, label: 'Foraging'),
  MarkerIconOption(key: 'cave', icon: Icons.terrain, label: 'Cave'),
  MarkerIconOption(key: 'dead_zone', icon: Icons.wifi_off, label: 'Dead zone'),
  MarkerIconOption(
    key: 'evac_route',
    icon: Icons.alt_route,
    label: 'Evac route',
  ),
  MarkerIconOption(key: 'livestock', icon: Icons.warehouse, label: 'Livestock'),
  MarkerIconOption(key: 'pharmacy', icon: Icons.medication, label: 'Pharmacy'),
  MarkerIconOption(
    key: 'clinic',
    icon: Icons.medical_services,
    assetPath: 'assets/markers/clinic.svg',
    label: 'Clinic',
  ),
  MarkerIconOption(
    key: 'dentist',
    icon: Icons.healing,
    assetPath: 'assets/markers/dentist.svg',
    label: 'Dentist',
  ),
  MarkerIconOption(
    key: 'doctors_office',
    icon: Icons.medical_information,
    assetPath: 'assets/markers/doctors_office.svg',
    label: "Doctor's office",
  ),
  MarkerIconOption(
    key: 'eye_doctor',
    icon: Icons.visibility,
    assetPath: 'assets/markers/eye_doctor.svg',
    label: 'Eye doctor',
  ),
  MarkerIconOption(
    key: 'on_foot',
    icon: Icons.directions_walk,
    label: 'On foot',
  ),
  MarkerIconOption(
    key: 'horse',
    icon: Icons.pets,
    assetPath: 'assets/markers/horse.svg',
    coloredAsset: true,
    glyphScale: 0.94,
    label: 'Horse',
  ),
  MarkerIconOption(
    key: 'motorcycle',
    icon: Icons.two_wheeler,
    label: 'Motorcycle',
  ),
  MarkerIconOption(key: 'atv', icon: Icons.sports_motorsports, label: 'ATV'),
  MarkerIconOption(key: 'truck', icon: Icons.local_shipping, label: 'Truck'),
  MarkerIconOption(key: 'bus', icon: Icons.directions_bus, label: 'Bus'),
  MarkerIconOption(key: 'rv', icon: Icons.rv_hookup, label: 'RV'),
  MarkerIconOption(key: 'train', icon: Icons.train, label: 'Train'),
  MarkerIconOption(
    key: 'ambulance',
    icon: Icons.local_hospital,
    assetPath: 'assets/markers/ambulance.svg',
    label: 'Ambulance',
  ),
  MarkerIconOption(
    key: 'fire_truck',
    icon: Icons.fire_truck,
    label: 'Fire truck',
  ),
  MarkerIconOption(
    key: 'farm_vehicle',
    icon: Icons.agriculture,
    label: 'Farm vehicle',
  ),
  MarkerIconOption(key: 'canoe', icon: Icons.kayaking, label: 'Canoe'),
  MarkerIconOption(
    key: 'helicopter',
    icon: Icons.air,
    assetPath: 'assets/markers/helicopter.svg',
    label: 'Helicopter',
  ),
  MarkerIconOption(key: 'glider', icon: Icons.paragliding, label: 'Glider'),
  MarkerIconOption(
    key: 'balloon',
    icon: Icons.air,
    assetPath: 'assets/markers/balloon.svg',
    coloredAsset: true,
    label: 'Balloon',
  ),
  MarkerIconOption(
    key: 'fallout_shelter',
    icon: Icons.warning,
    assetPath: 'assets/markers/fallout_shelter.svg',
    label: 'Fallout shelter',
  ),
  MarkerIconOption(
    key: 'storm_shelter',
    icon: Icons.thunderstorm,
    assetPath: 'assets/markers/storm_shelter.svg',
    label: 'Storm shelter',
  ),
  MarkerIconOption(
    key: 'bunker',
    icon: Icons.fort,
    assetPath: 'assets/markers/bunker.svg',
    label: 'Bunker',
  ),
  MarkerIconOption(
    key: 'water_well',
    icon: Icons.water_drop,
    assetPath: 'assets/markers/water_well.svg',
    label: 'Water well',
  ),
  MarkerIconOption(
    key: 'cistern',
    icon: Icons.water,
    assetPath: 'assets/markers/cistern.svg',
    label: 'Cistern',
  ),
  MarkerIconOption(
    key: 'root_cellar',
    icon: Icons.warehouse,
    assetPath: 'assets/markers/root_cellar.svg',
    label: 'Root cellar',
  ),
  MarkerIconOption(
    key: 'greenhouse',
    icon: Icons.yard,
    assetPath: 'assets/markers/greenhouse.svg',
    label: 'Greenhouse',
  ),
  MarkerIconOption(
    key: 'fuel_depot',
    icon: Icons.oil_barrel,
    assetPath: 'assets/markers/fuel_depot.svg',
    label: 'Fuel depot',
  ),
  MarkerIconOption(
    key: 'wind_turbine',
    icon: Icons.wind_power,
    assetPath: 'assets/markers/wind_turbine.svg',
    label: 'Wind turbine',
  ),
  MarkerIconOption(
    key: 'ham_shack',
    icon: Icons.radio,
    assetPath: 'assets/markers/ham_shack.svg',
    label: 'Ham shack',
  ),
  MarkerIconOption(
    key: 'security_post',
    icon: Icons.videocam,
    assetPath: 'assets/markers/security_post.svg',
    label: 'Security post',
  ),
  MarkerIconOption(
    key: 'medical_cache',
    icon: Icons.medical_services,
    assetPath: 'assets/markers/medical_cache.svg',
    label: 'Medical cache',
  ),
  MarkerIconOption(
    key: 'firewood_cache',
    icon: Icons.fireplace,
    assetPath: 'assets/markers/firewood_cache.svg',
    label: 'Firewood cache',
  ),
  MarkerIconOption(
    key: 'grain_silo',
    icon: Icons.grain,
    assetPath: 'assets/markers/grain_silo.svg',
    label: 'Grain silo',
  ),
  MarkerIconOption(
    key: 'safe_room',
    icon: Icons.lock,
    assetPath: 'assets/markers/safe_room.svg',
    label: 'Safe room',
  ),
  MarkerIconOption(
    key: 'decon_station',
    icon: Icons.shower,
    assetPath: 'assets/markers/decon_station.svg',
    label: 'Decon station',
  ),
  MarkerIconOption(
    key: 'ammo_cache',
    icon: Icons.inventory_2,
    assetPath: 'assets/markers/ammo_cache.svg',
    label: 'Ammo cache',
  ),
  MarkerIconOption(
    key: 'police_department',
    icon: Icons.local_police,
    label: 'Police department',
  ),
  MarkerIconOption(
    key: 'post_office',
    icon: Icons.local_post_office,
    label: 'Post office',
  ),
  MarkerIconOption(
    key: 'armory',
    icon: Icons.security,
    assetPath: 'assets/markers/armory.svg',
    label: 'Armory',
  ),
  MarkerIconOption(
    key: 'prison',
    icon: Icons.gavel,
    assetPath: 'assets/markers/prison.svg',
    label: 'Prison',
  ),
  MarkerIconOption(
    key: 'jail',
    icon: Icons.lock,
    assetPath: 'assets/markers/jail.svg',
    label: 'Jail',
  ),
  MarkerIconOption(
    key: 'college',
    icon: Icons.cast_for_education,
    label: 'College',
  ),
  MarkerIconOption(
    key: 'fire_station',
    icon: Icons.fire_hydrant,
    label: 'Fire station',
  ),
  MarkerIconOption(
    key: 'courthouse',
    icon: Icons.balance,
    label: 'Courthouse',
  ),
  MarkerIconOption(
    key: 'library',
    icon: Icons.local_library,
    label: 'Library',
  ),
  MarkerIconOption(key: 'bank', icon: Icons.savings, label: 'Bank'),
  MarkerIconOption(
    key: 'cemetery',
    icon: Icons.church,
    assetPath: 'assets/markers/cemetery.svg',
    label: 'Cemetery',
  ),
];

IconData markerIconData(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.icon;
    }
  }
  return Icons.my_location;
}

String markerIconLabel(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.label;
    }
  }
  return 'Location';
}

String normalizeMarkerIcon(String iconName) {
  final normalized = iconName == 'place' ? defaultMarkerIconKey : iconName;
  for (final option in markerIconOptions) {
    if (option.key == normalized) {
      return option.key;
    }
  }
  return defaultMarkerIconKey;
}

MarkerIconOption? markerIconOption(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option;
    }
  }
  return null;
}

String? markerIconAsset(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.resolvedAssetPath;
    }
  }
  return null;
}

String? markerIconEmoji(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.emoji;
    }
  }
  return null;
}

double markerIconGlyphScale(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.glyphScale;
    }
  }
  return 1.0;
}

bool markerIconColoredAsset(String iconName) {
  for (final option in markerIconOptions) {
    if (option.key == iconName) {
      return option.coloredAsset;
    }
  }
  return true;
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
    'clinic': 'clinic',
    'dentist': 'dentist',
    'doctor': 'doctors_office',
    'doctors office': 'doctors_office',
    "doctor's office": 'doctors_office',
    'eye doctor': 'eye_doctor',
    'optometrist': 'eye_doctor',
    'ophthalmologist': 'eye_doctor',
    'car': 'directions_car',
    'bike': 'directions_bike',
    'trail': 'hiking',
    'park': 'park',
    'monument': 'monument',
    'memorial': 'monument',
    'geocache': 'geocache',
    'geo cache': 'geocache',
    'water': 'water',
    'spring': 'water',
    'water well': 'water_well',
    'well': 'water_well',
    'drilled well': 'water_well',
    'hand pump': 'water_well',
    'cistern': 'cistern',
    'rain barrel': 'cistern',
    'rainwater': 'cistern',
    'root cellar': 'root_cellar',
    'cellar': 'root_cellar',
    'pantry': 'root_cellar',
    'greenhouse': 'greenhouse',
    'fuel depot': 'fuel_depot',
    'bulk fuel': 'fuel_depot',
    'fuel storage': 'fuel_depot',
    'propane tank': 'fuel_depot',
    'wind turbine': 'wind_turbine',
    'wind power': 'wind_turbine',
    'ham shack': 'ham_shack',
    'ham radio': 'ham_shack',
    'radio shack': 'ham_shack',
    'security post': 'security_post',
    'security camera': 'security_post',
    'guard post': 'security_post',
    'medical cache': 'medical_cache',
    'first aid cache': 'medical_cache',
    'trauma kit': 'medical_cache',
    'firewood': 'firewood_cache',
    'wood pile': 'firewood_cache',
    'grain silo': 'grain_silo',
    'silo': 'grain_silo',
    'safe room': 'safe_room',
    'panic room': 'safe_room',
    'decon': 'decon_station',
    'decon station': 'decon_station',
    'decontamination': 'decon_station',
    'ammo cache': 'ammo_cache',
    'ammunition': 'ammo_cache',
    'fallout shelter': 'fallout_shelter',
    'nuclear shelter': 'fallout_shelter',
    'civil defense': 'fallout_shelter',
    'storm shelter': 'storm_shelter',
    'tornado shelter': 'storm_shelter',
    'hurricane shelter': 'storm_shelter',
    'bunker': 'bunker',
    'underground shelter': 'bunker',
    'police': 'police_department',
    'police department': 'police_department',
    'police station': 'police_department',
    'sheriff': 'police_department',
    'post office': 'post_office',
    'usps': 'post_office',
    'armory': 'armory',
    'national guard armory': 'armory',
    'prison': 'prison',
    'penitentiary': 'prison',
    'correctional facility': 'prison',
    'jail': 'jail',
    'county jail': 'jail',
    'college': 'college',
    'university': 'college',
    'campus': 'college',
    'fire station': 'fire_station',
    'firehouse': 'fire_station',
    'courthouse': 'courthouse',
    'court house': 'courthouse',
    'library': 'library',
    'public library': 'library',
    'bank': 'bank',
    'credit union': 'bank',
    'cemetery': 'cemetery',
    'graveyard': 'cemetery',
    'burial ground': 'cemetery',
    'supply cache': 'supply_cache',
    'stash': 'supply_cache',
    'retreat': 'retreat',
    'bug out': 'retreat',
    'bol': 'retreat',
    'camp': 'camp',
    'bivouac': 'camp',
    'fuel': 'fuel',
    'gas': 'fuel',
    'propane': 'fuel',
    'gate': 'gate',
    'checkpoint': 'gate',
    'roadblock': 'gate',
    'crossing': 'crossing',
    'bridge': 'crossing',
    'ford': 'crossing',
    'lookout': 'lookout',
    'observation': 'lookout',
    'overwatch': 'lookout',
    'solar': 'solar_power_plant',
    'generator': 'solar_power_plant',
    'power': 'solar_power_plant',
    'power plant': 'power_plant',
    'generating station': 'power_plant',
    'coal plant': 'power_plant',
    'nuclear power': 'nuclear_power_plant',
    'nuclear plant': 'nuclear_power_plant',
    'nuclear reactor': 'nuclear_power_plant',
    'nuclear weapons': 'nuclear_weapons_facility',
    'nuclear assembly': 'nuclear_weapons_facility',
    'nuclear disassembly': 'nuclear_weapons_facility',
    'weapons facility': 'nuclear_weapons_facility',
    'garden': 'garden',
    'staging': 'staging',
    'parking': 'staging',
    'hazard': 'hazard',
    'danger': 'hazard',
    'restricted': 'restricted',
    'no entry': 'restricted',
    'rally': 'rally',
    'meet up': 'rally',
    'rendezvous': 'rally',
    'workshop': 'workshop',
    'repair': 'workshop',
    'boat': 'boat',
    'marina': 'boat',
    'port': 'port',
    'harbor': 'port',
    'harbour': 'port',
    'seaport': 'port',
    'dock': 'dock',
    'pier': 'dock',
    'wharf': 'port',
    'lake dock': 'dock',
    'boat dock': 'dock',
    'ferry': 'ferry',
    'ferry terminal': 'ferry',
    'yacht': 'yacht',
    'yacht club': 'yacht',
    'sailboat': 'sailboat',
    'sail boat': 'sailboat',
    'sailing club': 'sailboat',
    'river boat': 'river_boat',
    'riverboat': 'river_boat',
    'towboat': 'river_boat',
    'barge': 'river_boat',
    'airstrip': 'airstrip',
    'airfield': 'airstrip',
    'airport': 'airstrip',
    'landing zone': 'airstrip',
    'defense': 'defense',
    'defensive': 'defense',
    'army base': 'army_base',
    'army post': 'army_base',
    'fort': 'army_base',
    'naval base': 'navy_base',
    'navy base': 'navy_base',
    'naval station': 'navy_base',
    'marine corps': 'marine_corps_base',
    'marines': 'marine_corps_base',
    'mcas': 'marine_corps_base',
    'air force base': 'air_force_base',
    'afb': 'air_force_base',
    'space force': 'space_force_base',
    'coast guard': 'coast_guard_base',
    'uscg': 'coast_guard_base',
    'hunting': 'hunting',
    'trap': 'hunting',
    'fishing': 'fishing',
    'foraging': 'foraging',
    'forage': 'foraging',
    'berries': 'foraging',
    'berry': 'foraging',
    'cave': 'cave',
    'dead zone': 'dead_zone',
    'no signal': 'dead_zone',
    'evac': 'evac_route',
    'evacuation': 'evac_route',
    'livestock': 'livestock',
    'barn': 'livestock',
    'pharmacy': 'pharmacy',
    'meds': 'pharmacy',
    'on foot': 'on_foot',
    'walking': 'on_foot',
    'walker': 'on_foot',
    'jogger': 'on_foot',
    'horse': 'horse',
    'horseback': 'horse',
    'motorcycle': 'motorcycle',
    'motorbike': 'motorcycle',
    'atv': 'atv',
    'quad': 'atv',
    'four wheeler': 'atv',
    'truck': 'truck',
    'semi': 'truck',
    '18 wheeler': 'truck',
    'bus': 'bus',
    'rv': 'rv',
    'recreational vehicle': 'rv',
    'camper': 'rv',
    'train': 'train',
    'railroad': 'train',
    'rail': 'train',
    'ambulance': 'ambulance',
    'ems': 'ambulance',
    'fire truck': 'fire_truck',
    'fire engine': 'fire_truck',
    'farm vehicle': 'farm_vehicle',
    'tractor': 'farm_vehicle',
    'canoe': 'canoe',
    'kayak': 'canoe',
    'helicopter': 'helicopter',
    'helo': 'helicopter',
    'chopper': 'helicopter',
    'glider': 'glider',
    'balloon': 'balloon',
    'hot air balloon': 'balloon',
    'flag': 'flag',
    'star': 'star',
    'pet': 'pets',
    'pets': 'pets',
    'man': 'man',
    'woman': 'woman',
    'boy': 'boy',
    'girl': 'girl',
    'dad': 'man',
    'father': 'man',
    'mom': 'woman',
    'mother': 'woman',
    'son': 'boy',
    'daughter': 'girl',
    'cat': 'cat',
    'kitten': 'cat',
    'dog': 'dog',
    'puppy': 'dog',
    'repeater': 'radio_repeater',
    'radio repeater': 'radio_repeater',
    'tower': 'cell_tower',
    'cell tower': 'cell_tower',
    'radio tower': 'radio_station',
    'radio station': 'radio_station',
    'broadcast': 'radio_station',
    'radio': 'radio_repeater',
    'weather station': 'weather_station',
    'weather': 'weather_station',
    'wx station': 'weather_station',
    'meteo': 'weather_station',
  };

  for (final entry in suggestions.entries) {
    if (normalized.contains(entry.key)) {
      return entry.value;
    }
  }
  return null;
}
