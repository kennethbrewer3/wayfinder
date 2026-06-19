import 'geocoding_datasets.dart';

const defaultGeocodingSourceUrl = geocodingPlanetSourceUrl;
const defaultHousenumbersSourceUrl = geocodingHousenumbersSourceUrl;

const geocodingStatusIdle = 'idle';
const geocodingStatusDownloading = 'downloading';
const geocodingStatusImporting = 'importing';
const geocodingStatusCompleted = 'completed';
const geocodingStatusFailed = 'failed';

const geocodingResultTypePlace = 'place';
const geocodingResultTypeAddress = 'address';

class GeocodingImportState {
  const GeocodingImportState({
    required this.sourceUrl,
    required this.countryCodes,
    required this.importStatus,
    required this.importedRowCount,
    required this.importProgress,
    required this.housenumbersSourceUrl,
    required this.housenumbersImportStatus,
    required this.housenumbersImportedRowCount,
    required this.housenumbersImportProgress,
    required this.isReady,
    required this.isRunning,
    required this.isPlacesRunning,
    required this.isHousenumbersRunning,
    this.importError,
    this.importedAt,
    this.housenumbersImportError,
    this.housenumbersImportedAt,
  });

  final String sourceUrl;
  final String? countryCodes;
  final String importStatus;
  final int importedRowCount;
  final double importProgress;
  final String? importError;
  final DateTime? importedAt;
  final String housenumbersSourceUrl;
  final String housenumbersImportStatus;
  final int housenumbersImportedRowCount;
  final double housenumbersImportProgress;
  final String? housenumbersImportError;
  final DateTime? housenumbersImportedAt;
  final bool isReady;
  final bool isRunning;
  final bool isPlacesRunning;
  final bool isHousenumbersRunning;

  bool get isPlacesReady =>
      importStatus == geocodingStatusCompleted && importedRowCount > 0;

  bool get isHousenumbersReady =>
      housenumbersImportStatus == geocodingStatusCompleted &&
      housenumbersImportedRowCount > 0;
}

class GeocodingPlaceResult {
  const GeocodingPlaceResult({
    required this.id,
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
    required this.importance,
    required this.resultType,
  });

  final int id;
  final String name;
  final String? displayName;
  final double latitude;
  final double longitude;
  final String? countryCode;
  final double importance;
  final String resultType;

  bool get isAddress => resultType == geocodingResultTypeAddress;

  String get label => displayName ?? name;

  String get subtitle {
    if (isAddress) {
      return 'Address';
    }
    final parts = <String>['Place'];
    if (countryCode != null && countryCode!.isNotEmpty) {
      parts.add(countryCode!.toUpperCase());
    }
    return parts.join(' · ');
  }
}
