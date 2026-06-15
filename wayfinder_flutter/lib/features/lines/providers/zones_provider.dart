import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../models/line_geometry.dart';

class ZonesNotifier extends AsyncNotifier<List<MapZone>> {
  @override
  Future<List<MapZone>> build() async {
    return _fetchZones();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchZones);
  }

  Future<List<MapZone>> _fetchZones() async {
    AppLogger.logZones.debug('📡 Fetching zones from server');
    try {
      final client = ref.read(serverClientProvider);
      final zones = await client.mapZone.listZones();
      AppLogger.logZones.success(
        '📡 Zones loaded',
        data: 'count=${zones.length}',
      );
      return zones;
    } catch (error, stackTrace) {
      AppLogger.logZones.error(
        '📡 Failed to load zones',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  MapZone? zoneById(UuidValue zoneId) {
    final zones = state.valueOrNull;
    if (zones == null) {
      return null;
    }
    for (final zone in zones) {
      if (zone.id == zoneId) {
        return zone;
      }
    }
    return null;
  }

  Future<void> toggleLineNameLabel(UuidValue zoneId) {
    return _toggleLineLabel(
      zoneId: zoneId,
      toggle: (geometry) =>
          geometry.copyWith(showNameLabel: !geometry.showNameLabel),
    );
  }

  Future<void> toggleLineDistanceLabel(UuidValue zoneId) {
    return _toggleLineLabel(
      zoneId: zoneId,
      toggle: (geometry) =>
          geometry.copyWith(showDistanceLabel: !geometry.showDistanceLabel),
    );
  }

  Future<void> _toggleLineLabel({
    required UuidValue zoneId,
    required LineGeometry Function(LineGeometry geometry) toggle,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final index = current.indexWhere((zone) => zone.id == zoneId);
    if (index < 0) {
      return;
    }

    final zone = current[index];
    final geometry = LineGeometry.fromZone(zone);
    if (geometry == null || !geometry.isValid) {
      return;
    }

    final updatedZone = updateZoneLineGeometry(zone, toggle(geometry));
    final previousState = state;

    state = AsyncData([
      for (var i = 0; i < current.length; i++)
        if (i == index) updatedZone else current[i],
    ]);

    try {
      final client = ref.read(serverClientProvider);
      await client.mapZone.updateZone(updatedZone);
    } catch (error, stackTrace) {
      AppLogger.logZones.error(
        '📡 Failed to toggle line label',
        error: error,
        stackTrace: stackTrace,
      );
      state = previousState;
    }
  }
}

final zonesProvider = AsyncNotifierProvider<ZonesNotifier, List<MapZone>>(
  ZonesNotifier.new,
);
