import '../models/atlas_bounds.dart';
import '../models/atlas_sheet.dart';

/// Divides [coverage] into a [columns]×[rows] sheet grid.
///
/// [overlapFraction] expands each sheet slightly so edge features appear on
/// neighboring pages (typical field-atlas practice).
List<AtlasSheet> tileAtlasBounds({
  required AtlasBounds coverage,
  required int columns,
  required int rows,
  double overlapFraction = 0.06,
}) {
  if (!coverage.isValid || columns < 1 || rows < 1) {
    return const [];
  }

  final cellLat = coverage.latSpan / rows;
  final cellLng = coverage.lngSpan / columns;
  final latOverlap = cellLat * overlapFraction;
  final lngOverlap = cellLng * overlapFraction;
  final sheets = <AtlasSheet>[];

  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < columns; col++) {
      final south = (coverage.south + row * cellLat - latOverlap).clamp(
        -90.0,
        90.0,
      );
      final north = (coverage.south + (row + 1) * cellLat + latOverlap).clamp(
        -90.0,
        90.0,
      );
      final west = (coverage.west + col * cellLng - lngOverlap).clamp(
        -180.0,
        180.0,
      );
      final east = (coverage.west + (col + 1) * cellLng + lngOverlap).clamp(
        -180.0,
        180.0,
      );
      if (south >= north || west >= east) {
        continue;
      }
      sheets.add(
        AtlasSheet(
          column: col,
          row: row,
          columns: columns,
          rows: rows,
          bounds: AtlasBounds(
            south: south,
            west: west,
            north: north,
            east: east,
          ),
        ),
      );
    }
  }

  return sheets;
}

/// Column×row presets offered in the export dialog.
typedef AtlasGridPreset = ({int columns, int rows, String label});

const atlasGridPresets = <AtlasGridPreset>[
  (columns: 1, rows: 1, label: '1 × 1'),
  (columns: 2, rows: 1, label: '2 × 1'),
  (columns: 2, rows: 2, label: '2 × 2'),
  (columns: 3, rows: 2, label: '3 × 2'),
  (columns: 3, rows: 3, label: '3 × 3'),
  (columns: 4, rows: 3, label: '4 × 3'),
];
