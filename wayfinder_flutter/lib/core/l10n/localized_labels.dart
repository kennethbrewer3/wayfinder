import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../app/app_locale_choice.dart';
import '../../app/app_theme_choice.dart';
import '../../features/circles/models/circle_geometry.dart';
import '../../features/circles/models/circle_size_display.dart';
import '../../features/lines/models/angle_display_format.dart';
import '../../features/lines/models/line_arrow_density.dart';
import '../../features/lines/models/line_geometry.dart';
import '../../features/lines/models/measurement_units.dart';
import '../../features/lines/presentation/line_form_dialog.dart';
import '../../features/map/providers/map_providers.dart';
import '../../features/rectangles/models/rectangle_geometry.dart';
import '../../features/rectangles/models/rectangle_size_display.dart';
import '../../features/tracks/models/track_geometry.dart';

extension AppLocaleChoiceL10n on AppLocaleChoice {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AppLocaleChoice.system => l10n.languageSystem,
        AppLocaleChoice.en => l10n.languageEnglish,
        AppLocaleChoice.es => l10n.languageSpanish,
        AppLocaleChoice.fr => l10n.languageFrench,
      };
}

extension AppThemeFamilyL10n on AppThemeFamily {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AppThemeFamily.standard => l10n.themeFamilyStandard,
        AppThemeFamily.military => l10n.themeFamilyMilitary,
      };
}

extension AppThemeBrightnessL10n on AppThemeBrightness {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AppThemeBrightness.light => l10n.themeBrightnessLight,
        AppThemeBrightness.dark => l10n.themeBrightnessDark,
      };
}

extension AppThemeChoiceL10n on AppThemeChoice {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AppThemeChoice.light => l10n.themeBrightnessLight,
        AppThemeChoice.dark => l10n.themeBrightnessDark,
        AppThemeChoice.militaryLight => l10n.themeChoiceMilitaryLight,
        AppThemeChoice.militaryDark => l10n.themeChoiceMilitaryDark,
      };
}

extension MeasurementUnitsL10n on MeasurementUnits {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MeasurementUnits.metric => l10n.measurementMetric,
        MeasurementUnits.imperial => l10n.measurementImperial,
        MeasurementUnits.nautical => l10n.measurementNautical,
      };

  String localizedShortLabel(AppLocalizations l10n) => switch (this) {
        MeasurementUnits.metric => l10n.measurementMetricShort,
        MeasurementUnits.imperial => l10n.measurementImperialShort,
        MeasurementUnits.nautical => l10n.measurementNauticalShort,
      };
}

extension AngleDisplayFormatL10n on AngleDisplayFormat {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AngleDisplayFormat.decimal => l10n.angleFormatDecimal,
        AngleDisplayFormat.degreesMinutesSeconds => l10n.angleFormatDms,
      };

  String localizedShortLabel(AppLocalizations l10n) => switch (this) {
        AngleDisplayFormat.decimal => l10n.angleFormatDecimalShort,
        AngleDisplayFormat.degreesMinutesSeconds => l10n.angleFormatDmsShort,
      };
}

extension LineArrowDensityL10n on LineArrowDensity {
  String localizedLabel(AppLocalizations l10n) => switch (level) {
        1 => l10n.lineArrowDensitySparse,
        2 => l10n.lineArrowDensityLight,
        3 => l10n.lineArrowDensityBalanced,
        4 => l10n.lineArrowDensityFrequent,
        5 => l10n.lineArrowDensityDense,
        _ => l10n.lineArrowDensityBalanced,
      };
}

extension LineBorderPatternL10n on LineBorderPattern {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        LineBorderPattern.solid => l10n.lineBorderSolid,
        LineBorderPattern.dashed => l10n.lineBorderDashed,
      };
}

extension RectangleSizeDisplayL10n on RectangleSizeDisplay {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        RectangleSizeDisplay.dimensions => l10n.rectangleSizeDimensions,
        RectangleSizeDisplay.area => l10n.rectangleSizeArea,
        RectangleSizeDisplay.none => l10n.rectangleSizeNone,
      };

  String localizedShortLabel(AppLocalizations l10n) => switch (this) {
        RectangleSizeDisplay.dimensions => l10n.rectangleSizeDimensionsShort,
        RectangleSizeDisplay.area => l10n.rectangleSizeArea,
        RectangleSizeDisplay.none => l10n.rectangleSizeNone,
      };
}

extension RectangleCreationModeL10n on RectangleCreationMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        RectangleCreationMode.centerExtent => l10n.rectangleModeCenter,
        RectangleCreationMode.corners => l10n.rectangleModeCorners,
      };
}

extension CircleSizeDisplayL10n on CircleSizeDisplay {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        CircleSizeDisplay.radius => l10n.circleSizeRadius,
        CircleSizeDisplay.diameter => l10n.circleSizeDiameter,
        CircleSizeDisplay.none => l10n.circleSizeNone,
      };

  String localizedShortLabel(AppLocalizations l10n) =>
      localizedLabel(l10n);

  String localizedToggleTooltip(AppLocalizations l10n) => switch (this) {
        CircleSizeDisplay.radius => l10n.circleSizeToggleRadius,
        CircleSizeDisplay.diameter => l10n.circleSizeToggleDiameter,
        CircleSizeDisplay.none => l10n.circleSizeToggleNone,
      };
}

extension MarkerSortFieldL10n on MarkerSortField {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MarkerSortField.name => l10n.sortName,
        MarkerSortField.hue => l10n.sortHue,
        MarkerSortField.icon => l10n.sortIcon,
        MarkerSortField.visibility => l10n.sortVisibility,
      };
}

extension ZoneSortFieldL10n on ZoneSortField {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ZoneSortField.name => l10n.sortName,
        ZoneSortField.hue => l10n.sortHue,
        ZoneSortField.type => l10n.sortType,
        ZoneSortField.visibility => l10n.sortVisibility,
      };
}

String localizedMarkerIconLabel(AppLocalizations l10n, String iconKey) {
  return switch (iconKey) {
    'place' => l10n.markerIconPlace,
    'home' => l10n.markerIconHome,
    'house' => l10n.markerIconHouse,
    'apartment' => l10n.markerIconApartment,
    'work' => l10n.markerIconWork,
    'school' => l10n.markerIconSchool,
    'store' => l10n.markerIconStore,
    'restaurant' => l10n.markerIconFood,
    'local_cafe' => l10n.markerIconCafe,
    'hotel' => l10n.markerIconHotel,
    'church' => l10n.markerIconChurch,
    'mosque' => l10n.markerIconMosque,
    'community_center' => l10n.markerIconCommunity,
    'local_hospital' => l10n.markerIconMedical,
    'directions_car' => l10n.markerIconVehicle,
    'directions_bike' => l10n.markerIconBike,
    'hiking' => l10n.markerIconTrail,
    'park' => l10n.markerIconPark,
    'monument' => l10n.markerIconMonument,
    'geocache' => l10n.markerIconGeocache,
    'flag' => l10n.markerIconFlag,
    'star' => l10n.markerIconStar,
    'favorite' => l10n.markerIconFavorite,
    'warning' => l10n.markerIconWarning,
    'info' => l10n.markerIconInfo,
    'my_location' => l10n.markerIconLocation,
    'camera' => l10n.markerIconPhoto,
    'pets' => l10n.markerIconPets,
    'man' => l10n.markerIconMan,
    'woman' => l10n.markerIconWoman,
    'boy' => l10n.markerIconBoy,
    'girl' => l10n.markerIconGirl,
    'cat' => l10n.markerIconCat,
    'dog' => l10n.markerIconDog,
    'cell_tower' => l10n.markerIconRadioTower,
    'weather_station' => l10n.markerIconWeatherStation,
    'radio_repeater' => l10n.markerIconRadioRepeater,
    'water' => l10n.markerIconWater,
    'supply_cache' => l10n.markerIconSupplyCache,
    'retreat' => l10n.markerIconRetreat,
    'camp' => l10n.markerIconCamp,
    'fuel' => l10n.markerIconFuel,
    'gate' => l10n.markerIconGate,
    'crossing' => l10n.markerIconCrossing,
    'lookout' => l10n.markerIconLookout,
    'power' => l10n.markerIconPower,
    'power_plant' => l10n.markerIconPowerPlant,
    'nuclear_power_plant' => l10n.markerIconNuclearPowerPlant,
    'nuclear_weapons_facility' => l10n.markerIconNuclearWeaponsFacility,
    'garden' => l10n.markerIconGarden,
    'staging' => l10n.markerIconStaging,
    'hazard' => l10n.markerIconHazard,
    'restricted' => l10n.markerIconRestricted,
    'rally' => l10n.markerIconRally,
    'workshop' => l10n.markerIconWorkshop,
    'boat' => l10n.markerIconBoat,
    'port' => l10n.markerIconPort,
    'dock' => l10n.markerIconDock,
    'ferry' => l10n.markerIconFerry,
    'yacht' => l10n.markerIconYacht,
    'sailboat' => l10n.markerIconSailboat,
    'river_boat' => l10n.markerIconRiverBoat,
    'airstrip' => l10n.markerIconAirstrip,
    'defense' => l10n.markerIconDefense,
    'army_base' => l10n.markerIconArmyBase,
    'navy_base' => l10n.markerIconNavyBase,
    'marine_corps_base' => l10n.markerIconMarineCorpsBase,
    'air_force_base' => l10n.markerIconAirForceBase,
    'space_force_base' => l10n.markerIconSpaceForceBase,
    'coast_guard_base' => l10n.markerIconCoastGuardBase,
    'hunting' => l10n.markerIconHunting,
    'fishing' => l10n.markerIconFishing,
    'cave' => l10n.markerIconCave,
    'dead_zone' => l10n.markerIconDeadZone,
    'evac_route' => l10n.markerIconEvacRoute,
    'livestock' => l10n.markerIconLivestock,
    'pharmacy' => l10n.markerIconPharmacy,
    'on_foot' => l10n.markerIconOnFoot,
    'horse' => l10n.markerIconHorse,
    'motorcycle' => l10n.markerIconMotorcycle,
    'atv' => l10n.markerIconAtv,
    'truck' => l10n.markerIconTruck,
    'bus' => l10n.markerIconBus,
    'rv' => l10n.markerIconRv,
    'train' => l10n.markerIconTrain,
    'ambulance' => l10n.markerIconAmbulance,
    'fire_truck' => l10n.markerIconFireTruck,
    'farm_vehicle' => l10n.markerIconFarmVehicle,
    'canoe' => l10n.markerIconCanoe,
    'helicopter' => l10n.markerIconHelicopter,
    'glider' => l10n.markerIconGlider,
    'balloon' => l10n.markerIconBalloon,
    _ => l10n.markerIconPlace,
  };
}

String localizedZoneTypeLabel(AppLocalizations l10n, String type) {
  return switch (type) {
    lineZoneType => l10n.mapObjectTypeLine,
    trackZoneType => l10n.mapObjectTypeTrack,
    circleZoneType => l10n.mapObjectTypeCircle,
    rectangleZoneType => l10n.mapObjectTypeRectangle,
    _ => type,
  };
}

String localizedMarkerNameGroupLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    '0-9' => l10n.sortGroupDigits,
    '#' => l10n.sortGroupOther,
    _ => key,
  };
}

String localizedVisibilityGroupLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'visible' => l10n.sortGroupVisible,
    'hidden' => l10n.sortGroupHidden,
    _ => key,
  };
}
