abstract final class GeocodingConstants {
  static const defaultSourceUrl =
      'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_geonames.tsv.gz';
  static const sampleSourceUrl =
      'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest-100k_geonames.tsv.gz';
  static const defaultHousenumbersSourceUrl =
      'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_housenumbers.tsv.gz';

  static const resultTypePlace = 'place';
  static const resultTypeAddress = 'address';

  static const statusIdle = 'idle';
  static const statusDownloading = 'downloading';
  static const statusImporting = 'importing';
  static const statusCompleted = 'completed';
  static const statusFailed = 'failed';

  static const minSearchLength = 2;
  static const maxSearchResults = 20;
  static const importBatchSize = 500;
  static const progressUpdateInterval = 5000;
}
