import 'atlas_bounds.dart';

/// One printable sheet in an atlas grid.
class AtlasSheet {
  const AtlasSheet({
    required this.column,
    required this.row,
    required this.columns,
    required this.rows,
    required this.bounds,
  });

  final int column;
  final int row;
  final int columns;
  final int rows;
  final AtlasBounds bounds;

  /// Sheet id like `A1` (column letter + 1-based row).
  String get id {
    final letter = String.fromCharCode('A'.codeUnitAt(0) + column);
    return '$letter${row + 1}';
  }
}
