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

abstract class AppSettings implements _i1.SerializableModel {
  AppSettings._({
    this.id,
    required this.homeLatitude,
    required this.homeLongitude,
    required this.homeZoom,
    required this.pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    this.restApiKeyHash,
    required this.updatedAt,
  }) : measurementUnits = measurementUnits ?? 'metric',
       angleDisplayFormat = angleDisplayFormat ?? 'decimal',
       circleSizeDisplay = circleSizeDisplay ?? 'radius',
       appTheme = appTheme ?? 'light',
       appLocale = appLocale ?? 'system';

  factory AppSettings({
    int? id,
    required double homeLatitude,
    required double homeLongitude,
    required double homeZoom,
    required String pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    String? restApiKeyHash,
    required DateTime updatedAt,
  }) = _AppSettingsImpl;

  factory AppSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppSettings(
      id: jsonSerialization['id'] as int?,
      homeLatitude: (jsonSerialization['homeLatitude'] as num).toDouble(),
      homeLongitude: (jsonSerialization['homeLongitude'] as num).toDouble(),
      homeZoom: (jsonSerialization['homeZoom'] as num).toDouble(),
      pmtilesStoragePath: jsonSerialization['pmtilesStoragePath'] as String,
      measurementUnits: jsonSerialization['measurementUnits'] as String?,
      angleDisplayFormat: jsonSerialization['angleDisplayFormat'] as String?,
      circleSizeDisplay: jsonSerialization['circleSizeDisplay'] as String?,
      appTheme: jsonSerialization['appTheme'] as String?,
      appLocale: jsonSerialization['appLocale'] as String?,
      restApiKeyHash: jsonSerialization['restApiKeyHash'] as String?,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  double homeLatitude;

  double homeLongitude;

  double homeZoom;

  String pmtilesStoragePath;

  String measurementUnits;

  String angleDisplayFormat;

  String circleSizeDisplay;

  String appTheme;

  String appLocale;

  String? restApiKeyHash;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AppSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppSettings copyWith({
    int? id,
    double? homeLatitude,
    double? homeLongitude,
    double? homeZoom,
    String? pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    String? restApiKeyHash,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppSettings',
      if (id != null) 'id': id,
      'homeLatitude': homeLatitude,
      'homeLongitude': homeLongitude,
      'homeZoom': homeZoom,
      'pmtilesStoragePath': pmtilesStoragePath,
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      if (restApiKeyHash != null) 'restApiKeyHash': restApiKeyHash,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppSettingsImpl extends AppSettings {
  _AppSettingsImpl({
    int? id,
    required double homeLatitude,
    required double homeLongitude,
    required double homeZoom,
    required String pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    String? restApiKeyHash,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         homeLatitude: homeLatitude,
         homeLongitude: homeLongitude,
         homeZoom: homeZoom,
         pmtilesStoragePath: pmtilesStoragePath,
         measurementUnits: measurementUnits,
         angleDisplayFormat: angleDisplayFormat,
         circleSizeDisplay: circleSizeDisplay,
         appTheme: appTheme,
         appLocale: appLocale,
         restApiKeyHash: restApiKeyHash,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AppSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppSettings copyWith({
    Object? id = _Undefined,
    double? homeLatitude,
    double? homeLongitude,
    double? homeZoom,
    String? pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    Object? restApiKeyHash = _Undefined,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id is int? ? id : this.id,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      homeZoom: homeZoom ?? this.homeZoom,
      pmtilesStoragePath: pmtilesStoragePath ?? this.pmtilesStoragePath,
      measurementUnits: measurementUnits ?? this.measurementUnits,
      angleDisplayFormat: angleDisplayFormat ?? this.angleDisplayFormat,
      circleSizeDisplay: circleSizeDisplay ?? this.circleSizeDisplay,
      appTheme: appTheme ?? this.appTheme,
      appLocale: appLocale ?? this.appLocale,
      restApiKeyHash: restApiKeyHash is String?
          ? restApiKeyHash
          : this.restApiKeyHash,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
