import 'dart:convert';

import 'package:flutter/services.dart';

/// A downloadable remote `.pmtiles` pack (basemap or DEM).
class RemotePmtilesPack {
  const RemotePmtilesPack({
    required this.id,
    required this.name,
    required this.title,
    required this.url,
    required this.kind,
    this.bytes,
    this.description,
    this.sourceLabel,
    this.extractBbox,
  });

  final String id;
  final String name;
  final String title;
  final String url;
  final RemotePmtilesKind kind;
  final int? bytes;
  final String? description;
  final String? sourceLabel;

  /// When set, the server runs `pmtiles extract --bbox=…` from [url]
  /// instead of downloading the whole remote archive.
  /// Order: minLon, minLat, maxLon, maxLat.
  final List<double>? extractBbox;

  bool get isDem => kind == RemotePmtilesKind.dem;

  bool get isDemExtract =>
      isDem && extractBbox != null && extractBbox!.length == 4;

  factory RemotePmtilesPack.fromJson(Map<String, dynamic> json) {
    List<double>? bbox;
    final rawBbox = json['extractBbox'] ?? json['bbox'];
    if (rawBbox is List && rawBbox.length == 4) {
      bbox = [
        for (final item in rawBbox)
          if (item is num) item.toDouble(),
      ];
      if (bbox.length != 4) {
        bbox = null;
      }
    }
    return RemotePmtilesPack(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      kind: RemotePmtilesKind.fromWire(json['kind'] as String? ?? 'basemap'),
      bytes: (json['bytes'] as num?)?.toInt(),
      description: json['description'] as String?,
      sourceLabel: json['sourceLabel'] as String?,
      extractBbox: bbox,
    );
  }
}

enum RemotePmtilesKind {
  basemap,
  dem;

  static RemotePmtilesKind fromWire(String raw) {
    return switch (raw.toLowerCase()) {
      'dem' || 'elevation' || 'terrarium' => RemotePmtilesKind.dem,
      _ => RemotePmtilesKind.basemap,
    };
  }
}

const nomadPmtilesCatalogAsset = 'assets/map/nomad_pmtiles_catalog.json';
const usStateDemRegionsAsset = 'assets/map/us_state_dem_regions.json';

/// Bundled Project NOMAD US-state Protomaps extracts + regional DEM extracts.
///
/// NOMAD packs: https://github.com/Crosstalk-Solutions/project-nomad-maps
/// DEM: Mapterhorn Terrarium via server-side `pmtiles extract`.
Future<List<RemotePmtilesPack>> loadRemotePmtilesCatalog() async {
  final packs = <RemotePmtilesPack>[..._demCatalogExtras];
  await _loadJsonPacks(nomadPmtilesCatalogAsset, packs);
  await _loadJsonPacks(usStateDemRegionsAsset, packs);

  packs.sort((a, b) {
    final kindCmp = a.kind.index.compareTo(b.kind.index);
    if (kindCmp != 0) {
      return kindCmp;
    }
    // Regional DEM extracts before the full-planet option.
    final aExtract = a.isDemExtract ? 0 : 1;
    final bExtract = b.isDemExtract ? 0 : 1;
    final extractCmp = aExtract.compareTo(bExtract);
    if (extractCmp != 0) {
      return extractCmp;
    }
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
  return packs;
}

Future<void> _loadJsonPacks(
  String assetPath,
  List<RemotePmtilesPack> packs,
) async {
  try {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return;
    }
    for (final item in decoded) {
      if (item is Map) {
        packs.add(RemotePmtilesPack.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  } catch (error, stackTrace) {
    assert(() {
      // ignore: avoid_print
      print('Failed to load $assetPath: $error\n$stackTrace');
      return true;
    }());
  }
}

const _demCatalogExtras = <RemotePmtilesPack>[
  RemotePmtilesPack(
    id: 'mapterhorn-terrarium-planet',
    name: 'mapterhorn-terrarium-z12.pmtiles',
    title: 'Mapterhorn Terrarium (planet z0–12)',
    url: 'https://download.mapterhorn.com/planet.pmtiles',
    kind: RemotePmtilesKind.dem,
    sourceLabel: 'Mapterhorn',
    description:
        'Full-planet Terrarium DEM. Very large — prefer a US-state extract '
        'above unless you truly need worldwide coverage.',
  ),
];
