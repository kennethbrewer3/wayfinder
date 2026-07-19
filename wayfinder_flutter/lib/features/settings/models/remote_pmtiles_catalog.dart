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
  });

  final String id;
  final String name;
  final String title;
  final String url;
  final RemotePmtilesKind kind;
  final int? bytes;
  final String? description;
  final String? sourceLabel;

  bool get isDem => kind == RemotePmtilesKind.dem;

  factory RemotePmtilesPack.fromJson(Map<String, dynamic> json) {
    return RemotePmtilesPack(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      kind: RemotePmtilesKind.fromWire(json['kind'] as String? ?? 'basemap'),
      bytes: (json['bytes'] as num?)?.toInt(),
      description: json['description'] as String?,
      sourceLabel: json['sourceLabel'] as String?,
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

/// Bundled Project NOMAD US-state Protomaps extracts + DEM options.
///
/// NOMAD packs: https://github.com/Crosstalk-Solutions/project-nomad-maps
/// DEM: Mapterhorn Terrarium planet (extract regional cuts with pmtiles CLI).
Future<List<RemotePmtilesPack>> loadRemotePmtilesCatalog() async {
  final raw = await rootBundle.loadString(nomadPmtilesCatalogAsset);
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    return const [];
  }

  final packs = <RemotePmtilesPack>[
    for (final item in decoded)
      if (item is Map)
        RemotePmtilesPack.fromJson(Map<String, dynamic>.from(item)),
    ..._demCatalogExtras,
  ];

  packs.sort((a, b) {
    final kindCmp = a.kind.index.compareTo(b.kind.index);
    if (kindCmp != 0) {
      return kindCmp;
    }
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
  return packs;
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
        'Global Terrarium DEM for elevation / viewshed. Very large — prefer a '
        'regional extract with `pmtiles extract` when possible. Named so '
        'Wayfinder treats it as Elevation DEM.',
  ),
];
