import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import '../core/wayfinder_env.dart';
import 'tide_harmonic_predict.dart';

/// Filesystem catalog of coastal tide packs under [root].
class TideStorage {
  TideStorage._(this._root);

  static TideStorage? _instance;

  static TideStorage get instance {
    _instance ??= TideStorage._(Directory(WayfinderEnv.tidesStoragePath));
    return _instance!;
  }

  static void configure(String path) {
    _instance = TideStorage._(Directory(path));
  }

  factory TideStorage() => instance;

  final Directory _root;

  Directory get root => _root;

  static final RegExp _validPackId = RegExp(r'^[a-z0-9][a-z0-9_-]{0,63}$');

  static bool isValidPackId(String id) => _validPackId.hasMatch(id);

  Future<bool> ensureReady() async {
    if (_root.existsSync()) {
      return true;
    }
    try {
      await _root.create(recursive: true);
      return true;
    } on FileSystemException {
      return false;
    }
  }

  Directory packDir(String packId) {
    _requireValidPackId(packId);
    return Directory('${_root.path}/$packId');
  }

  File get _catalogFile => File('${_root.path}/catalog.json');

  Future<List<TidePackRecord>> listPacks() async {
    await ensureReady();
    if (!_root.existsSync()) {
      return const [];
    }
    final packs = <TidePackRecord>[];
    for (final entity in _root.listSync(followLinks: false)) {
      if (entity is! Directory) {
        continue;
      }
      final id = _basename(entity.path);
      if (id.startsWith('.') || !isValidPackId(id)) {
        continue;
      }
      final pack = await loadPack(id);
      if (pack != null) {
        packs.add(pack);
      }
    }
    packs.sort((a, b) => a.importedAt.compareTo(b.importedAt));
    await _writeCatalog(packs);
    return packs;
  }

  Future<TidePackRecord?> loadPack(String packId) async {
    if (!isValidPackId(packId)) {
      return null;
    }
    final dir = packDir(packId);
    final manifestFile = File('${dir.path}/manifest.json');
    final stationsFile = File('${dir.path}/stations.json');
    if (!manifestFile.existsSync() || !stationsFile.existsSync()) {
      return null;
    }

    try {
      final manifestJson =
          jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
      final stationsJson = jsonDecode(await stationsFile.readAsString());
      final stationsList = stationsJson is List
          ? stationsJson
          : (stationsJson as Map<String, dynamic>)['stations'] as List<dynamic>;

      final stations = stationsList
          .cast<Map<String, dynamic>>()
          .map(TideStationRecord.fromJson)
          .toList();

      final sizeBytes = await _directorySizeBytes(dir);
      return TidePackRecord.fromManifestJson(
        manifestJson,
        stations: stations,
        sizeBytes: sizeBytes,
      );
    } on Object {
      return null;
    }
  }

  Future<TidePackRecord> savePack(TidePackRecord pack) async {
    _requireValidPackId(pack.id);
    await ensureReady();
    final dir = packDir(pack.id);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final manifestFile = File('${dir.path}/manifest.json');
    final stationsFile = File('${dir.path}/stations.json');
    await manifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(pack.toManifestJson()),
      flush: true,
    );
    await stationsFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'stations': pack.stations.map((s) => s.toJson()).toList(),
      }),
      flush: true,
    );

    final sizeBytes = await _directorySizeBytes(dir);
    final saved = pack.copyWith(sizeBytes: sizeBytes);
    await listPacks();
    return saved;
  }

  Future<bool> deletePack(String packId) async {
    if (!isValidPackId(packId)) {
      return false;
    }
    final dir = packDir(packId);
    if (!dir.existsSync()) {
      await listPacks();
      return false;
    }
    await dir.delete(recursive: true);
    await listPacks();
    return true;
  }

  Future<TidePackRecord> setPackActive(String packId, bool active) async {
    final pack = await loadPack(packId);
    if (pack == null) {
      throw FormatException('Tide pack not found: $packId');
    }
    final updated = pack.copyWith(isActive: active);
    return savePack(updated);
  }

  Future<List<TidePackRecord>> listActivePacks() async {
    final packs = await listPacks();
    return packs.where((p) => p.isActive).toList();
  }

  /// Nearest station among [packs] using haversine distance (meters).
  ({TidePackRecord pack, TideStationRecord station, double distanceMeters})?
      nearestStation(
    List<TidePackRecord> packs, {
    required double latitude,
    required double longitude,
  }) {
    TidePackRecord? bestPack;
    TideStationRecord? bestStation;
    var bestDistance = double.infinity;

    for (final pack in packs) {
      for (final station in pack.stations) {
        final d = haversineMeters(
          latitude,
          longitude,
          station.lat,
          station.lng,
        );
        if (d < bestDistance) {
          bestDistance = d;
          bestPack = pack;
          bestStation = station;
        }
      }
    }

    if (bestPack == null || bestStation == null) {
      return null;
    }
    return (
      pack: bestPack,
      station: bestStation,
      distanceMeters: bestDistance,
    );
  }

  static double haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusM = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  void _requireValidPackId(String packId) {
    if (!isValidPackId(packId)) {
      throw FormatException(
        'Invalid tide pack id "$packId". '
        'Use lowercase letters, digits, hyphens, and underscores.',
      );
    }
  }

  Future<void> _writeCatalog(List<TidePackRecord> packs) async {
    await ensureReady();
    final payload = {
      'packs': packs.map((p) => p.toCatalogJson()).toList(),
    };
    await _catalogFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
  }

  Future<int> _directorySizeBytes(Directory dir) async {
    var total = 0;
    if (!dir.existsSync()) {
      return 0;
    }
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  static String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? path : parts.last;
  }

  static double _toRadians(double deg) => deg * math.pi / 180.0;
}

class TidePackRecord {
  const TidePackRecord({
    required this.id,
    required this.name,
    required this.source,
    required this.datum,
    required this.units,
    required this.stationCount,
    required this.sizeBytes,
    required this.importedAt,
    required this.isActive,
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
    required this.stations,
  });

  final String id;
  final String name;
  final String source;
  final String datum;
  final String units;
  final int stationCount;
  final int sizeBytes;
  final DateTime importedAt;
  final bool isActive;
  final double minLatitude;
  final double minLongitude;
  final double maxLatitude;
  final double maxLongitude;
  final List<TideStationRecord> stations;

  TidePackRecord copyWith({
    bool? isActive,
    int? sizeBytes,
    int? stationCount,
    List<TideStationRecord>? stations,
  }) {
    return TidePackRecord(
      id: id,
      name: name,
      source: source,
      datum: datum,
      units: units,
      stationCount: stationCount ?? this.stationCount,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      importedAt: importedAt,
      isActive: isActive ?? this.isActive,
      minLatitude: minLatitude,
      minLongitude: minLongitude,
      maxLatitude: maxLatitude,
      maxLongitude: maxLongitude,
      stations: stations ?? this.stations,
    );
  }

  factory TidePackRecord.fromManifestJson(
    Map<String, dynamic> json, {
    required List<TideStationRecord> stations,
    required int sizeBytes,
  }) {
    final bbox = json['bbox'] as Map<String, dynamic>?;
    return TidePackRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      source: json['source'] as String? ?? 'NOAA CO-OPS',
      datum: json['datum'] as String? ?? 'MLLW',
      units: json['units'] as String? ?? 'meters',
      stationCount:
          (json['stationCount'] as num?)?.toInt() ?? stations.length,
      sizeBytes: sizeBytes,
      importedAt: DateTime.parse(
        (json['importedAt'] ?? json['addedAt']) as String,
      ).toUtc(),
      isActive: json['isActive'] as bool? ?? false,
      minLatitude: (json['minLatitude'] as num? ?? bbox?['minLat'] as num?)
              ?.toDouble() ??
          0,
      minLongitude: (json['minLongitude'] as num? ?? bbox?['minLng'] as num?)
              ?.toDouble() ??
          0,
      maxLatitude: (json['maxLatitude'] as num? ?? bbox?['maxLat'] as num?)
              ?.toDouble() ??
          0,
      maxLongitude: (json['maxLongitude'] as num? ?? bbox?['maxLng'] as num?)
              ?.toDouble() ??
          0,
      stations: stations,
    );
  }

  Map<String, dynamic> toManifestJson() => {
        'id': id,
        'name': name,
        'source': source,
        'datum': datum,
        'units': units,
        'bbox': {
          'minLat': minLatitude,
          'minLng': minLongitude,
          'maxLat': maxLatitude,
          'maxLng': maxLongitude,
        },
        'importedAt': importedAt.toUtc().toIso8601String(),
        'stationCount': stationCount,
        'isActive': isActive,
      };

  Map<String, dynamic> toCatalogJson() => {
        ...toManifestJson(),
        'minLatitude': minLatitude,
        'minLongitude': minLongitude,
        'maxLatitude': maxLatitude,
        'maxLongitude': maxLongitude,
        'sizeBytes': sizeBytes,
        'addedAt': importedAt.toUtc().toIso8601String(),
      };
}

class TideStationRecord {
  const TideStationRecord({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.timezone,
    required this.meanLevelMeters,
    required this.constituents,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String timezone;
  final double meanLevelMeters;
  final List<TideConstituent> constituents;

  factory TideStationRecord.fromJson(Map<String, dynamic> json) {
    final constituentsJson =
        (json['constituents'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    return TideStationRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? 'UTC',
      meanLevelMeters: (json['meanLevelMeters'] as num?)?.toDouble() ?? 0,
      constituents: [
        for (final c in constituentsJson)
          TideConstituent(
            name: c['name'] as String,
            amplitudeMeters: (c['amplitudeMeters'] as num).toDouble(),
            phaseGmtDeg: (c['phaseGmtDeg'] as num).toDouble(),
            speedDegPerHour: (c['speedDegPerHour'] as num).toDouble(),
          ),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'timezone': timezone,
        'meanLevelMeters': meanLevelMeters,
        'constituents': [
          for (final c in constituents)
            {
              'name': c.name,
              'amplitudeMeters': c.amplitudeMeters,
              'phaseGmtDeg': c.phaseGmtDeg,
              'speedDegPerHour': c.speedDegPerHour,
            },
        ],
      };
}
