import 'pmtiles_geo_bounds.dart';
import 'pmtiles_source.dart';

/// Lightweight metadata for an enabled PMTiles archive.
class PmtilesArchiveEntry {
  const PmtilesArchiveEntry({
    required this.id,
    required this.name,
    required this.source,
    required this.bounds,
    required this.boundsKnown,
    required this.minZoom,
    required this.maxZoom,
  });

  final String id;
  final String name;
  final PmtilesSource source;
  final PmtilesGeoBounds bounds;
  final bool boundsKnown;
  final int minZoom;
  final int maxZoom;
}
