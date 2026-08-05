import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../layers/map_layer_bootstrap.dart';
import '../markers/marker_attachment_backup.dart';
import '../markers/marker_attachment_service.dart';
import '../markers/marker_icon_backup.dart';
import '../settings/app_settings_backup.dart';
import '../settings/app_settings_store.dart';
import '../pmtiles/pmtiles_catalog_sync.dart';
import '../pmtiles/pmtiles_storage.dart';
import '../web/rest/rest_json.dart';

const mapDataBackupVersion = 7;

const supportedMapDataBackupVersions = {1, 2, 3, 4, 5, 6, 7};

/// Full map structure export (layers, markers, zones, seasonal overlays, watch
/// log, comms plans).
Future<Map<String, dynamic>> exportMapDataBundle(Session session) async {
  final layers = await listLayersEnsuringDefault(session);
  final markers = await MapMarker.db.find(
    session,
    where: (t) => t.deletedAt.equals(null),
    orderBy: (t) => t.name,
  );
  final zones = await MapZone.db.find(
    session,
    where: (t) => t.deletedAt.equals(null),
    orderByList: (t) => [Order(column: t.name), Order(column: t.id)],
  );
  final seasonalOverlays = await SeasonalOverlay.db.find(
    session,
    orderBy: (t) => t.sortOrder,
  );
  final watchLogEntries = await WatchLogEntry.db.find(
    session,
    orderBy: (t) => t.occurredAt,
    orderDescending: true,
  );
  final commsPlans = await CommsPlan.db.find(
    session,
    orderBy: (t) => t.sortOrder,
  );

  final markerIcons = await exportMarkerIconBackup(session);
  final markerAttachments = await exportMarkerAttachmentBackup(session);
  final settings = await AppSettingsStore.getOrCreate(session);

  return {
    'version': mapDataBackupVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'appSettings': exportAppSettingsBackup(settings),
    'layers': RestJson.encodeModels(layers),
    'markers': RestJson.encodeModels(markers),
    'zones': RestJson.encodeModels(zones),
    'seasonalOverlays': RestJson.encodeModels(seasonalOverlays),
    'watchLogEntries': RestJson.encodeModels(watchLogEntries),
    'commsPlans': RestJson.encodeModels(commsPlans),
    ...markerIcons,
    ...markerAttachments,
  };
}

class MapDataRestoreCounts {
  const MapDataRestoreCounts({
    required this.layers,
    required this.markers,
    required this.zones,
    this.seasonalOverlays = 0,
    this.watchLogEntries = 0,
    this.commsPlans = 0,
    this.markerIconCategories = 0,
    this.markerIcons = 0,
    this.markerAttachments = 0,
  });

  final int layers;
  final int markers;
  final int zones;
  final int seasonalOverlays;
  final int watchLogEntries;
  final int commsPlans;
  final int markerIconCategories;
  final int markerIcons;
  final int markerAttachments;

  Map<String, dynamic> toJson() => {
    'layers': layers,
    'markers': markers,
    'zones': zones,
    'seasonalOverlays': seasonalOverlays,
    'watchLogEntries': watchLogEntries,
    'commsPlans': commsPlans,
    'markerIconCategories': markerIconCategories,
    'markerIcons': markerIcons,
    'markerAttachments': markerAttachments,
  };
}

/// Replaces all layers, markers, zones, seasonal overlays, and watch log.
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
  final seasonalOverlays = version >= 4
      ? _parseModelList(
          body['seasonalOverlays'] ?? const <dynamic>[],
          fieldName: 'seasonalOverlays',
          fromJson: SeasonalOverlay.fromJson,
        )
      : const <SeasonalOverlay>[];
  final watchLogEntries = version >= 5
      ? _parseModelList(
          body['watchLogEntries'] ?? const <dynamic>[],
          fieldName: 'watchLogEntries',
          fromJson: WatchLogEntry.fromJson,
        )
      : const <WatchLogEntry>[];
  final commsPlans = version >= 7
      ? _parseModelList(
          body['commsPlans'] ?? const <dynamic>[],
          fieldName: 'commsPlans',
          fromJson: CommsPlan.fromJson,
        )
      : const <CommsPlan>[];

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

    final existingOverlays = await SeasonalOverlay.db.find(
      session,
      transaction: transaction,
    );
    if (existingOverlays.isNotEmpty) {
      await SeasonalOverlay.db.delete(
        session,
        existingOverlays,
        transaction: transaction,
      );
    }

    final existingWatchLog = await WatchLogEntry.db.find(
      session,
      transaction: transaction,
    );
    if (existingWatchLog.isNotEmpty) {
      await WatchLogEntry.db.delete(
        session,
        existingWatchLog,
        transaction: transaction,
      );
    }

    final existingCommsPlans = await CommsPlan.db.find(
      session,
      transaction: transaction,
    );
    if (existingCommsPlans.isNotEmpty) {
      await CommsPlan.db.delete(
        session,
        existingCommsPlans,
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
    for (final overlay in seasonalOverlays) {
      await SeasonalOverlay.db.insertRow(
        session,
        overlay,
        transaction: transaction,
      );
    }
    for (final entry in watchLogEntries) {
      await WatchLogEntry.db.insertRow(
        session,
        entry,
        transaction: transaction,
      );
    }
    for (final plan in commsPlans) {
      await CommsPlan.db.insertRow(
        session,
        plan,
        transaction: transaction,
      );
    }

    return MapDataRestoreCounts(
      layers: layers.length,
      markers: normalizedMarkers.length,
      zones: normalizedZones.length,
      seasonalOverlays: seasonalOverlays.length,
      watchLogEntries: watchLogEntries.length,
      commsPlans: commsPlans.length,
    );
  });

  // Clear existing photos; zip restore re-imports `marker-attachments/` after
  // this returns. JSON-only restore leaves markers without photos.
  await MarkerAttachmentService.deleteAll(session);

  return MapDataRestoreCounts(
    layers: mapCounts.layers,
    markers: mapCounts.markers,
    zones: mapCounts.zones,
    seasonalOverlays: mapCounts.seasonalOverlays,
    watchLogEntries: mapCounts.watchLogEntries,
    commsPlans: mapCounts.commsPlans,
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
