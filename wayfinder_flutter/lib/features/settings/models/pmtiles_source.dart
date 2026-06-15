import 'dart:typed_data';

/// Resolved PMTiles data used to build a tile provider.
sealed class PmtilesSource {
  const PmtilesSource();
}

class PmtilesSourcePath extends PmtilesSource {
  const PmtilesSourcePath(this.path);

  final String path;
}

class PmtilesSourceBytes extends PmtilesSource {
  const PmtilesSourceBytes(this.bytes);

  final Uint8List bytes;
}
