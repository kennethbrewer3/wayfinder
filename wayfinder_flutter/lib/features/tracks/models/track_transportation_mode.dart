import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

enum TrackTransportationMode {
  onFoot,
  bike,
  landVehicle,
  watercraft,
  aircraft;

  String toJson() => switch (this) {
        onFoot => 'onFoot',
        bike => 'bike',
        landVehicle => 'landVehicle',
        watercraft => 'watercraft',
        aircraft => 'aircraft',
      };

  static TrackTransportationMode fromJson(Object? raw) {
    return switch (raw) {
      'bike' => bike,
      'landVehicle' => landVehicle,
      'watercraft' => watercraft,
      'aircraft' => aircraft,
      _ => onFoot,
    };
  }

  IconData get icon => switch (this) {
        onFoot => Icons.directions_walk,
        bike => Icons.directions_bike,
        landVehicle => Icons.directions_car,
        watercraft => Icons.directions_boat,
        aircraft => Icons.flight,
      };

  String label(AppLocalizations l10n) => switch (this) {
        onFoot => l10n.trackTransportationModeOnFoot,
        bike => l10n.trackTransportationModeBike,
        landVehicle => l10n.trackTransportationModeLandVehicle,
        watercraft => l10n.trackTransportationModeWatercraft,
        aircraft => l10n.trackTransportationModeAircraft,
      };
}

IconData trackTransportationIcon(TrackTransportationMode mode) => mode.icon;
