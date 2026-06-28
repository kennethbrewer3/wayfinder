import 'geocoding_datasets.dart';

const defaultGeocodingSourceUrl = geocodingPlanetSourceUrl;
const defaultHousenumbersSourceUrl = geocodingHousenumbersSourceUrl;

const geocodingStatusIdle = 'idle';
const geocodingStatusDownloading = 'downloading';
const geocodingStatusImporting = 'importing';
const geocodingStatusCompleted = 'completed';
const geocodingStatusFailed = 'failed';
const geocodingStatusCancelled = 'cancelled';

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
      isSearchableGeocodingImport(importStatus, importedRowCount);

  bool get isHousenumbersReady => isSearchableGeocodingImport(
        housenumbersImportStatus,
        housenumbersImportedRowCount,
      );
}

bool isSearchableGeocodingImport(String status, int rowCount) {
  if (rowCount <= 0) {
    return false;
  }
  return status != geocodingStatusDownloading &&
      status != geocodingStatusImporting;
}

/// Matches server progress weights in [GeocodingDownloadProgress].
enum GeocodingImportPhase {
  idle,
  downloading,
  importing,
  finalizing,
  committing,
}

GeocodingImportPhase resolveGeocodingImportPhase({
  required bool isRunning,
  required String status,
  required double progress,
}) {
  if (!isRunning &&
      status != geocodingStatusDownloading &&
      status != geocodingStatusImporting) {
    return GeocodingImportPhase.idle;
  }
  if (status == geocodingStatusDownloading) {
    return GeocodingImportPhase.downloading;
  }
  if (progress >= 0.97) {
    return GeocodingImportPhase.committing;
  }
  if (progress >= 0.92) {
    return GeocodingImportPhase.finalizing;
  }
  return GeocodingImportPhase.importing;
}

class GeocodingSearchReadiness {
  const GeocodingSearchReadiness({
    required this.isPlacesDataReady,
    required this.isAddressDataReady,
    required this.isPlacesSearchReady,
    required this.isAddressSearchReady,
    required this.isFullSearchReady,
    required this.indexesBuilding,
    required this.readyIndexCount,
    required this.totalIndexCount,
    this.buildProgress,
    this.etaSeconds,
    this.currentIndexName,
    this.statusMessage,
  });

  final bool isPlacesDataReady;
  final bool isAddressDataReady;
  final bool isPlacesSearchReady;
  final bool isAddressSearchReady;
  final bool isFullSearchReady;
  final bool indexesBuilding;
  final int readyIndexCount;
  final int totalIndexCount;
  final double? buildProgress;
  final int? etaSeconds;
  final String? currentIndexName;
  final String? statusMessage;

  bool get indexesReady =>
      totalIndexCount > 0 && readyIndexCount >= totalIndexCount;

  bool get anySearchReady =>
      isFullSearchReady || isPlacesSearchReady || isAddressSearchReady;

  factory GeocodingSearchReadiness.fromJson(Map<String, dynamic> json) {
    return GeocodingSearchReadiness(
      isPlacesDataReady: json['isPlacesDataReady'] as bool? ?? false,
      isAddressDataReady: json['isAddressDataReady'] as bool? ?? false,
      isPlacesSearchReady: json['isPlacesSearchReady'] as bool? ?? false,
      isAddressSearchReady: json['isAddressSearchReady'] as bool? ?? false,
      isFullSearchReady: json['isFullSearchReady'] as bool? ?? false,
      indexesBuilding: json['indexesBuilding'] as bool? ?? false,
      readyIndexCount: (json['readyIndexCount'] as num?)?.toInt() ?? 0,
      totalIndexCount: (json['totalIndexCount'] as num?)?.toInt() ?? 0,
      buildProgress: (json['buildProgress'] as num?)?.toDouble(),
      etaSeconds: (json['etaSeconds'] as num?)?.toInt(),
      currentIndexName: json['currentIndexName'] as String?,
      statusMessage: json['statusMessage'] as String?,
    );
  }

  String? get etaLabel {
    final seconds = etaSeconds;
    if (seconds == null || seconds <= 0) {
      return null;
    }
    if (seconds < 60) {
      return 'about $seconds seconds';
    }
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return minutes == 1 ? 'about 1 minute' : 'about $minutes minutes';
    }
    final hours = (minutes / 60).ceil();
    return hours == 1 ? 'about 1 hour' : 'about $hours hours';
  }
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

  String get label => isAddress ? name : (displayName ?? name);

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
