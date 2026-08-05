import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

/// First-class resource map classification stored on [MapMarker.resourceType].
enum MarkerResourceType {
  spring('spring'),
  well('well'),
  cache('cache'),
  fuel('fuel'),
  clinic('clinic');

  const MarkerResourceType(this.wireValue);

  final String wireValue;

  static MarkerResourceType? tryParse(String? raw) {
    final trimmed = raw?.trim().toLowerCase();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    for (final type in MarkerResourceType.values) {
      if (type.wireValue == trimmed) {
        return type;
      }
    }
    return null;
  }
}

String markerResourceTypeLabel(
  AppLocalizations l10n,
  MarkerResourceType type,
) {
  return switch (type) {
    MarkerResourceType.spring => l10n.markerResourceTypeSpring,
    MarkerResourceType.well => l10n.markerResourceTypeWell,
    MarkerResourceType.cache => l10n.markerResourceTypeCache,
    MarkerResourceType.fuel => l10n.markerResourceTypeFuel,
    MarkerResourceType.clinic => l10n.markerResourceTypeClinic,
  };
}

String markerResourceTypeFilterLabel(
  AppLocalizations l10n,
  MarkerResourceType type,
) {
  return switch (type) {
    MarkerResourceType.spring => l10n.sidebarFilterResourceSpring,
    MarkerResourceType.well => l10n.sidebarFilterResourceWell,
    MarkerResourceType.cache => l10n.sidebarFilterResourceCache,
    MarkerResourceType.fuel => l10n.sidebarFilterResourceFuel,
    MarkerResourceType.clinic => l10n.sidebarFilterResourceClinic,
  };
}

IconData markerResourceTypeIcon(MarkerResourceType type) {
  return switch (type) {
    MarkerResourceType.spring => Icons.water_drop_outlined,
    MarkerResourceType.well => Icons.water_outlined,
    MarkerResourceType.cache => Icons.inventory_2_outlined,
    MarkerResourceType.fuel => Icons.local_gas_station_outlined,
    MarkerResourceType.clinic => Icons.local_hospital_outlined,
  };
}

/// Default map icon key when assigning a resource type.
String defaultIconForResourceType(MarkerResourceType type) {
  return switch (type) {
    MarkerResourceType.spring => 'water',
    MarkerResourceType.well => 'water_well',
    MarkerResourceType.cache => 'supply_cache',
    MarkerResourceType.fuel => 'fuel_depot',
    MarkerResourceType.clinic => 'clinic',
  };
}

/// Infer a resource type from an existing marker icon (legacy backfill).
MarkerResourceType? resourceTypeSuggestedForIcon(String? icon) {
  return switch (icon) {
    'water' => MarkerResourceType.spring,
    'water_well' => MarkerResourceType.well,
    'supply_cache' ||
    'medical_cache' ||
    'ammo_cache' => MarkerResourceType.cache,
    'fuel' || 'fuel_depot' => MarkerResourceType.fuel,
    'clinic' => MarkerResourceType.clinic,
    _ => null,
  };
}

/// Persisted resource type only (icon inference is form UX, not filter truth).
MarkerResourceType? markerResourceTypeOf(MapMarker marker) {
  return MarkerResourceType.tryParse(marker.resourceType);
}

bool markerMatchesResourceTypeFilter(
  MapMarker marker,
  Set<MarkerResourceType> selected,
) {
  if (selected.isEmpty) {
    return true;
  }
  final type = markerResourceTypeOf(marker);
  return type != null && selected.contains(type);
}
