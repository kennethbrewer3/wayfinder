import 'geocoding_constants.dart';

abstract final class GeocodingImportStatus {
  static bool isActive(String status) {
    return status == GeocodingConstants.statusDownloading ||
        status == GeocodingConstants.statusImporting;
  }

  /// True when imported rows are available for offline search.
  static bool isSearchable(String status, int rowCount) {
    return rowCount > 0 && !isActive(status);
  }
}
