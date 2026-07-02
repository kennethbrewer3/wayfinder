import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

/// Transportation modes aligned with common APRS mobile symbols.
enum TrackTransportationMode {
  onFoot,
  horse,
  bike,
  motorcycle,
  atv,
  landVehicle,
  truck,
  bus,
  rv,
  train,
  ambulance,
  fireTruck,
  farmVehicle,
  canoe,
  watercraft,
  sailboat,
  aircraft,
  helicopter,
  glider,
  balloon;

  String toJson() => switch (this) {
        onFoot => 'onFoot',
        horse => 'horse',
        bike => 'bike',
        motorcycle => 'motorcycle',
        atv => 'atv',
        landVehicle => 'landVehicle',
        truck => 'truck',
        bus => 'bus',
        rv => 'rv',
        train => 'train',
        ambulance => 'ambulance',
        fireTruck => 'fireTruck',
        farmVehicle => 'farmVehicle',
        canoe => 'canoe',
        watercraft => 'watercraft',
        sailboat => 'sailboat',
        aircraft => 'aircraft',
        helicopter => 'helicopter',
        glider => 'glider',
        balloon => 'balloon',
      };

  static TrackTransportationMode fromJson(Object? raw) {
    return switch (raw) {
      'horse' => horse,
      'bike' => bike,
      'motorcycle' => motorcycle,
      'atv' => atv,
      'landVehicle' => landVehicle,
      'truck' => truck,
      'bus' => bus,
      'rv' => rv,
      'train' => train,
      'ambulance' => ambulance,
      'fireTruck' => fireTruck,
      'farmVehicle' => farmVehicle,
      'canoe' => canoe,
      'watercraft' => watercraft,
      'sailboat' => sailboat,
      'aircraft' => aircraft,
      'helicopter' => helicopter,
      'glider' => glider,
      'balloon' => balloon,
      _ => onFoot,
    };
  }

  TrackTrailStyle get trailStyle => switch (this) {
        onFoot || horse => TrackTrailStyle.footprints,
        bike || motorcycle || atv || farmVehicle => TrackTrailStyle.tread,
        landVehicle ||
        truck ||
        bus ||
        rv ||
        ambulance ||
        fireTruck =>
          TrackTrailStyle.road,
        train => TrackTrailStyle.railroad,
        canoe || watercraft || sailboat => TrackTrailStyle.wake,
        aircraft || helicopter || glider => TrackTrailStyle.flight,
        balloon => TrackTrailStyle.balloon,
      };

  FootprintTrailKind get footprintKind => switch (this) {
        horse => FootprintTrailKind.hoof,
        _ => FootprintTrailKind.foot,
      };

  TreadTrailKind get treadKind => switch (this) {
        farmVehicle => TreadTrailKind.tractor,
        motorcycle => TreadTrailKind.single,
        atv => TreadTrailKind.atv,
        _ => TreadTrailKind.bicycle,
      };

  RoadTrailKind get roadKind => switch (this) {
        truck || bus || rv || fireTruck => RoadTrailKind.wide,
        _ => RoadTrailKind.standard,
      };

  WakeTrailIntensity get wakeIntensity => switch (this) {
        sailboat => WakeTrailIntensity.light,
        watercraft => WakeTrailIntensity.wide,
        _ => WakeTrailIntensity.normal,
      };

  FlightTrailKind get flightKind => switch (this) {
        glider => FlightTrailKind.glider,
        helicopter => FlightTrailKind.helicopter,
        _ => FlightTrailKind.aircraft,
      };

  IconData get icon => switch (this) {
        onFoot => Icons.directions_walk,
        horse => Icons.pets,
        bike => Icons.directions_bike,
        motorcycle => Icons.two_wheeler,
        atv => Icons.sports_motorsports,
        landVehicle => Icons.directions_car,
        truck => Icons.local_shipping,
        bus => Icons.directions_bus,
        rv => Icons.rv_hookup,
        train => Icons.train,
        ambulance => Icons.local_hospital,
        fireTruck => Icons.fire_truck,
        farmVehicle => Icons.agriculture,
        canoe => Icons.kayaking,
        watercraft => Icons.directions_boat,
        sailboat => Icons.sailing,
        aircraft => Icons.flight,
        helicopter => Icons.air,
        glider => Icons.paragliding,
        balloon => Icons.air,
      };

  /// Marker icon key when this mode uses a custom SVG glyph.
  String? get markerIconKey => switch (this) {
        balloon => 'balloon',
        helicopter => 'helicopter',
        ambulance => 'ambulance',
        _ => null,
      };

  String label(AppLocalizations l10n) => switch (this) {
        onFoot => l10n.trackTransportationModeOnFoot,
        horse => l10n.trackTransportationModeHorse,
        bike => l10n.trackTransportationModeBike,
        motorcycle => l10n.trackTransportationModeMotorcycle,
        atv => l10n.trackTransportationModeAtv,
        landVehicle => l10n.trackTransportationModeLandVehicle,
        truck => l10n.trackTransportationModeTruck,
        bus => l10n.trackTransportationModeBus,
        rv => l10n.trackTransportationModeRv,
        train => l10n.trackTransportationModeTrain,
        ambulance => l10n.trackTransportationModeAmbulance,
        fireTruck => l10n.trackTransportationModeFireTruck,
        farmVehicle => l10n.trackTransportationModeFarmVehicle,
        canoe => l10n.trackTransportationModeCanoe,
        watercraft => l10n.trackTransportationModeWatercraft,
        sailboat => l10n.trackTransportationModeSailboat,
        aircraft => l10n.trackTransportationModeAircraft,
        helicopter => l10n.trackTransportationModeHelicopter,
        glider => l10n.trackTransportationModeGlider,
        balloon => l10n.trackTransportationModeBalloon,
      };
}

enum TrackTrailStyle {
  footprints,
  tread,
  road,
  railroad,
  wake,
  flight,
  balloon,
}

enum FootprintTrailKind {
  foot,
  hoof,
}

enum TreadTrailKind {
  bicycle,
  single,
  atv,
  tractor,
}

enum RoadTrailKind {
  standard,
  wide,
}

enum FlightTrailKind {
  aircraft,
  helicopter,
  glider,
}

enum WakeTrailIntensity {
  light,
  normal,
  wide,
}

IconData trackTransportationIcon(TrackTransportationMode mode) => mode.icon;
