/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class GeocodingSettings implements _i1.SerializableModel {
  GeocodingSettings._({
    this.id,
    required this.sourceUrl,
    this.countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    this.importError,
    this.importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    this.housenumbersImportError,
    this.housenumbersImportedAt,
    required this.updatedAt,
  }) : importStatus = importStatus ?? 'idle',
       importedRowCount = importedRowCount ?? 0,
       importProgress = importProgress ?? 0.0,
       housenumbersSourceUrl =
           housenumbersSourceUrl ??
           'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_housenumbers.tsv.gz',
       housenumbersImportStatus = housenumbersImportStatus ?? 'idle',
       housenumbersImportedRowCount = housenumbersImportedRowCount ?? 0,
       housenumbersImportProgress = housenumbersImportProgress ?? 0.0;

  factory GeocodingSettings({
    int? id,
    required String sourceUrl,
    String? countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
    DateTime? importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    String? housenumbersImportError,
    DateTime? housenumbersImportedAt,
    required DateTime updatedAt,
  }) = _GeocodingSettingsImpl;

  factory GeocodingSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodingSettings(
      id: jsonSerialization['id'] as int?,
      sourceUrl: jsonSerialization['sourceUrl'] as String,
      countryCodes: jsonSerialization['countryCodes'] as String?,
      importStatus: jsonSerialization['importStatus'] as String?,
      importedRowCount: jsonSerialization['importedRowCount'] as int?,
      importProgress: (jsonSerialization['importProgress'] as num?)?.toDouble(),
      importError: jsonSerialization['importError'] as String?,
      importedAt: jsonSerialization['importedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['importedAt']),
      housenumbersSourceUrl:
          jsonSerialization['housenumbersSourceUrl'] as String?,
      housenumbersImportStatus:
          jsonSerialization['housenumbersImportStatus'] as String?,
      housenumbersImportedRowCount:
          jsonSerialization['housenumbersImportedRowCount'] as int?,
      housenumbersImportProgress:
          (jsonSerialization['housenumbersImportProgress'] as num?)?.toDouble(),
      housenumbersImportError:
          jsonSerialization['housenumbersImportError'] as String?,
      housenumbersImportedAt:
          jsonSerialization['housenumbersImportedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['housenumbersImportedAt'],
            ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String sourceUrl;

  String? countryCodes;

  String importStatus;

  int importedRowCount;

  double importProgress;

  String? importError;

  DateTime? importedAt;

  String housenumbersSourceUrl;

  String housenumbersImportStatus;

  int housenumbersImportedRowCount;

  double housenumbersImportProgress;

  String? housenumbersImportError;

  DateTime? housenumbersImportedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [GeocodingSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodingSettings copyWith({
    int? id,
    String? sourceUrl,
    String? countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
    DateTime? importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    String? housenumbersImportError,
    DateTime? housenumbersImportedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodingSettings',
      if (id != null) 'id': id,
      'sourceUrl': sourceUrl,
      if (countryCodes != null) 'countryCodes': countryCodes,
      'importStatus': importStatus,
      'importedRowCount': importedRowCount,
      'importProgress': importProgress,
      if (importError != null) 'importError': importError,
      if (importedAt != null) 'importedAt': importedAt?.toJson(),
      'housenumbersSourceUrl': housenumbersSourceUrl,
      'housenumbersImportStatus': housenumbersImportStatus,
      'housenumbersImportedRowCount': housenumbersImportedRowCount,
      'housenumbersImportProgress': housenumbersImportProgress,
      if (housenumbersImportError != null)
        'housenumbersImportError': housenumbersImportError,
      if (housenumbersImportedAt != null)
        'housenumbersImportedAt': housenumbersImportedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodingSettingsImpl extends GeocodingSettings {
  _GeocodingSettingsImpl({
    int? id,
    required String sourceUrl,
    String? countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
    DateTime? importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    String? housenumbersImportError,
    DateTime? housenumbersImportedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         sourceUrl: sourceUrl,
         countryCodes: countryCodes,
         importStatus: importStatus,
         importedRowCount: importedRowCount,
         importProgress: importProgress,
         importError: importError,
         importedAt: importedAt,
         housenumbersSourceUrl: housenumbersSourceUrl,
         housenumbersImportStatus: housenumbersImportStatus,
         housenumbersImportedRowCount: housenumbersImportedRowCount,
         housenumbersImportProgress: housenumbersImportProgress,
         housenumbersImportError: housenumbersImportError,
         housenumbersImportedAt: housenumbersImportedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [GeocodingSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodingSettings copyWith({
    Object? id = _Undefined,
    String? sourceUrl,
    Object? countryCodes = _Undefined,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    Object? importError = _Undefined,
    Object? importedAt = _Undefined,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    Object? housenumbersImportError = _Undefined,
    Object? housenumbersImportedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return GeocodingSettings(
      id: id is int? ? id : this.id,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      countryCodes: countryCodes is String? ? countryCodes : this.countryCodes,
      importStatus: importStatus ?? this.importStatus,
      importedRowCount: importedRowCount ?? this.importedRowCount,
      importProgress: importProgress ?? this.importProgress,
      importError: importError is String? ? importError : this.importError,
      importedAt: importedAt is DateTime? ? importedAt : this.importedAt,
      housenumbersSourceUrl:
          housenumbersSourceUrl ?? this.housenumbersSourceUrl,
      housenumbersImportStatus:
          housenumbersImportStatus ?? this.housenumbersImportStatus,
      housenumbersImportedRowCount:
          housenumbersImportedRowCount ?? this.housenumbersImportedRowCount,
      housenumbersImportProgress:
          housenumbersImportProgress ?? this.housenumbersImportProgress,
      housenumbersImportError: housenumbersImportError is String?
          ? housenumbersImportError
          : this.housenumbersImportError,
      housenumbersImportedAt: housenumbersImportedAt is DateTime?
          ? housenumbersImportedAt
          : this.housenumbersImportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
