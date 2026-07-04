import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../layers/map_layer_bootstrap.dart';
import '../markers/marker_icon_backup.dart';
import '../settings/app_settings_backup.dart';
import '../settings/app_settings_store.dart';
import '../pmtiles/pmtiles_catalog_sync.dart';
import '../pmtiles/pmtiles_storage.dart';
import '../web/rest/rest_json.dart';

const mapDataBackupVersion = 3;

const supportedMapDataBackupVersions = {1, 2, 3};

/// Full map structure export (layers, markers, zones).
Future<Map<String, dynamic>> exportMapDataBundle(Session session) async {
  final layers = await listLayersEnsuringDefault(session);
  final markers = await MapMarker.db.find(
    session,
    orderBy: (t) => t.name,
  );
  final zones = await MapZone.db.find(
    session,
    orderByList: (t) => [Order(column: t.name), Order(column: t.id)],
  );

  final markerIcons = await exportMarkerIconBackup(session);
  final settings = await AppSettingsStore.getOrCreate(session);

  return {
    'version': mapDataBackupVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'appSettings': exportAppSettingsBackup(settings),
    'layers': RestJson.encodeModels(layers),
    'markers': RestJson.encodeModels(markers),
    'zones': RestJson.encodeModels(zones),
    ...markerIcons,
  };
}

class MapDataRestoreCounts {
  const MapDataRestoreCounts({
    required this.layers,
    required this.markers,
    required this.zones,
    this.markerIconCategories = 0,
    this.markerIcons = 0,
  });

  final int layers;
  final int markers;
  final int zones;
  final int markerIconCategories;
  final int markerIcons;

  Map<String, dynamic> toJson() => {
    'layers': layers,
    'markers': markers,
    'zones': zones,
    'markerIconCategories': markerIconCategories,
    'markerIcons': markerIcons,
  };
}

/// Replaces all layers, markers, and zones with the backup payload.
Future<MapDataRestoreCounts> restoreMapDataBundle(
  Session session,
  Map<String, dynamic> body,
) async {
  final version = body['version'];
  if (version is! int || !supportedMapDataBackupVersions.contains(version)) {
    throw FormatException(
      'Unsupported backup version: $version (expected one of $supportedMapDataBackupVersions)',
    );
  }

  var layers = _parseModelList(
    body['layers'],
    fieldName: 'layers',
    fromJson: MapLayer.fromJson,
  );
  final markers = _parseModelList(
    body['markers'],
    fieldName: 'markers',
    fromJson: MapMarker.fromJson,
  );
  final zones = _parseModelList(
    body['zones'],
    fieldName: 'zones',
    fromJson: MapZone.fromJson,
  );

  if (layers.isEmpty) {
    final now = DateTime.now().toUtc();
    layers = [
      MapLayer(
        id: defaultMapLayerId,
        name: 'Default',
        sortOrder: 0,
        visible: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  final layerIds = layers.map((layer) => layer.id).toSet();
  final fallbackLayerId = layers.first.id;

  final normalizedMarkers = [
    for (final marker in markers)
      marker.layerId == null || !layerIds.contains(marker.layerId)
          ? marker.copyWith(layerId: fallbackLayerId)
          : marker,
  ];
  final normalizedZones = [
    for (final zone in zones)
      zone.layerId == null || !layerIds.contains(zone.layerId)
          ? zone.copyWith(layerId: fallbackLayerId)
          : zone,
  ];

  final iconCounts =
      version >= 2 &&
          (body.containsKey('markerIconCategories') ||
              body.containsKey('markerIcons'))
      ? await restoreMarkerIconBackup(session, body)
      : const MarkerIconRestoreCounts(categories: 0, icons: 0);

  if (version >= 3 && body['appSettings'] is Map<String, dynamic>) {
    await restoreAppSettingsBackup(
      session,
      body['appSettings'] as Map<String, dynamic>,
    );
    final settings = await AppSettingsStore.getOrCreate(session);
    PmtilesStorage.configure(
      AppSettingsStore.effectivePmtilesStoragePath(settings),
    );
    await PmtilesStorage().ensureReady();
    await PmtilesCatalogSync.sync(session);
  }

  final mapCounts = await session.db.transaction((transaction) async {
    final existingMarkers = await MapMarker.db.find(
      session,
      transaction: transaction,
    );
    if (existingMarkers.isNotEmpty) {
      await MapMarker.db.delete(
        session,
        existingMarkers,
        transaction: transaction,
      );
    }

    final existingZones = await MapZone.db.find(
      session,
      transaction: transaction,
    );
    if (existingZones.isNotEmpty) {
      await MapZone.db.delete(
        session,
        existingZones,
        transaction: transaction,
      );
    }

    final existingLayers = await MapLayer.db.find(
      session,
      transaction: transaction,
    );
    if (existingLayers.isNotEmpty) {
      await MapLayer.db.delete(
        session,
        existingLayers,
        transaction: transaction,
      );
    }

    for (final layer in layers) {
      await MapLayer.db.insertRow(session, layer, transaction: transaction);
    }
    for (final marker in normalizedMarkers) {
      await MapMarker.db.insertRow(session, marker, transaction: transaction);
    }
    for (final zone in normalizedZones) {
      await MapZone.db.insertRow(session, zone, transaction: transaction);
    }

    return MapDataRestoreCounts(
      layers: layers.length,
      markers: normalizedMarkers.length,
      zones: normalizedZones.length,
    );
  });

  return MapDataRestoreCounts(
    layers: mapCounts.layers,
    markers: mapCounts.markers,
    zones: mapCounts.zones,
    markerIconCategories: iconCounts.categories,
    markerIcons: iconCounts.icons,
  );
}

List<T> _parseModelList<T>(
  Object? raw, {
  required String fieldName,
  required T Function(Map<String, dynamic>) fromJson,
}) {
  if (raw is! List) {
    throw FormatException('Field "$fieldName" must be a JSON array');
  }

  return [
    for (final entry in raw)
      if (entry is Map<String, dynamic>)
        fromJson(entry)
      else
        throw FormatException(
          'Each entry in "$fieldName" must be a JSON object',
        ),
  ];
}
