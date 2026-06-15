import 'dart:typed_data';

/// Resolved PMTiles data used to build a tile provider.
sealed class PmtilesSource {
  const PmtilesSource();
}

class PmtilesSourcePath extends PmtilesSource {
  const PmtilesSourcePath(this.path);

  final String path;
}

class PmtilesSourceUrl extends PmtilesSource {
  const PmtilesSourceUrl(this.url);

  final String url;
}

class PmtilesSourceBytes extends PmtilesSource {
  const PmtilesSourceBytes(this.bytes);

  final Uint8List bytes;
}
