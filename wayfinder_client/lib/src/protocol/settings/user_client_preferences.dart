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

abstract class UserClientPreferences implements _i1.SerializableModel {
  UserClientPreferences._({
    _i1.UuidValue? id,
    required this.authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       measurementUnits = measurementUnits ?? 'metric',
       angleDisplayFormat = angleDisplayFormat ?? 'decimal',
       bearingReference = bearingReference ?? 'true',
       circleSizeDisplay = circleSizeDisplay ?? 'radius',
       appTheme = appTheme ?? 'light',
       appLocale = appLocale ?? 'system',
       mapMarkerSizeScale = mapMarkerSizeScale ?? 1.0,
       mapViewportDebugBorder = mapViewportDebugBorder ?? false,
       mapTileBorderDebug = mapTileBorderDebug ?? false,
       mapCompassRoseEnabled = mapCompassRoseEnabled ?? true,
       mapMgrsGridEnabled = mapMgrsGridEnabled ?? false,
       darkMapTilesInDarkMode = darkMapTilesInDarkMode ?? true,
       polygonSnapRightAngles = polygonSnapRightAngles ?? true,
       polygonSnap45Angles = polygonSnap45Angles ?? false;

  factory UserClientPreferences({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    required DateTime updatedAt,
  }) = _UserClientPreferencesImpl;

  factory UserClientPreferences.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UserClientPreferences(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      measurementUnits: jsonSerialization['measurementUnits'] as String?,
      angleDisplayFormat: jsonSerialization['angleDisplayFormat'] as String?,
      bearingReference: jsonSerialization['bearingReference'] as String?,
      circleSizeDisplay: jsonSerialization['circleSizeDisplay'] as String?,
      appTheme: jsonSerialization['appTheme'] as String?,
      appLocale: jsonSerialization['appLocale'] as String?,
      mapMarkerSizeScale: (jsonSerialization['mapMarkerSizeScale'] as num?)
          ?.toDouble(),
      mapViewportDebugBorder:
          jsonSerialization['mapViewportDebugBorder'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapViewportDebugBorder'],
            ),
      mapTileBorderDebug: jsonSerialization['mapTileBorderDebug'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapTileBorderDebug'],
            ),
      mapCompassRoseEnabled: jsonSerialization['mapCompassRoseEnabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapCompassRoseEnabled'],
            ),
      mapMgrsGridEnabled: jsonSerialization['mapMgrsGridEnabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapMgrsGridEnabled'],
            ),
      darkMapTilesInDarkMode:
          jsonSerialization['darkMapTilesInDarkMode'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['darkMapTilesInDarkMode'],
            ),
      polygonSnapRightAngles:
          jsonSerialization['polygonSnapRightAngles'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['polygonSnapRightAngles'],
            ),
      polygonSnap45Angles: jsonSerialization['polygonSnap45Angles'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['polygonSnap45Angles'],
            ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue authUserId;

  String measurementUnits;

  String angleDisplayFormat;

  String bearingReference;

  String circleSizeDisplay;

  String appTheme;

  String appLocale;

  double mapMarkerSizeScale;

  bool mapViewportDebugBorder;

  bool mapTileBorderDebug;

  bool mapCompassRoseEnabled;

  bool mapMgrsGridEnabled;

  bool darkMapTilesInDarkMode;

  bool polygonSnapRightAngles;

  bool polygonSnap45Angles;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserClientPreferences]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserClientPreferences copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserClientPreferences',
      'id': id.toJson(),
      'authUserId': authUserId.toJson(),
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'bearingReference': bearingReference,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'mapMarkerSizeScale': mapMarkerSizeScale,
      'mapViewportDebugBorder': mapViewportDebugBorder,
      'mapTileBorderDebug': mapTileBorderDebug,
      'mapCompassRoseEnabled': mapCompassRoseEnabled,
      'mapMgrsGridEnabled': mapMgrsGridEnabled,
      'darkMapTilesInDarkMode': darkMapTilesInDarkMode,
      'polygonSnapRightAngles': polygonSnapRightAngles,
      'polygonSnap45Angles': polygonSnap45Angles,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UserClientPreferencesImpl extends UserClientPreferences {
  _UserClientPreferencesImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         measurementUnits: measurementUnits,
         angleDisplayFormat: angleDisplayFormat,
         bearingReference: bearingReference,
         circleSizeDisplay: circleSizeDisplay,
         appTheme: appTheme,
         appLocale: appLocale,
         mapMarkerSizeScale: mapMarkerSizeScale,
         mapViewportDebugBorder: mapViewportDebugBorder,
         mapTileBorderDebug: mapTileBorderDebug,
         mapCompassRoseEnabled: mapCompassRoseEnabled,
         mapMgrsGridEnabled: mapMgrsGridEnabled,
         darkMapTilesInDarkMode: darkMapTilesInDarkMode,
         polygonSnapRightAngles: polygonSnapRightAngles,
         polygonSnap45Angles: polygonSnap45Angles,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserClientPreferences]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserClientPreferences copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    DateTime? updatedAt,
  }) {
    return UserClientPreferences(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      measurementUnits: measurementUnits ?? this.measurementUnits,
      angleDisplayFormat: angleDisplayFormat ?? this.angleDisplayFormat,
      bearingReference: bearingReference ?? this.bearingReference,
      circleSizeDisplay: circleSizeDisplay ?? this.circleSizeDisplay,
      appTheme: appTheme ?? this.appTheme,
      appLocale: appLocale ?? this.appLocale,
      mapMarkerSizeScale: mapMarkerSizeScale ?? this.mapMarkerSizeScale,
      mapViewportDebugBorder:
          mapViewportDebugBorder ?? this.mapViewportDebugBorder,
      mapTileBorderDebug: mapTileBorderDebug ?? this.mapTileBorderDebug,
      mapCompassRoseEnabled:
          mapCompassRoseEnabled ?? this.mapCompassRoseEnabled,
      mapMgrsGridEnabled: mapMgrsGridEnabled ?? this.mapMgrsGridEnabled,
      darkMapTilesInDarkMode:
          darkMapTilesInDarkMode ?? this.darkMapTilesInDarkMode,
      polygonSnapRightAngles:
          polygonSnapRightAngles ?? this.polygonSnapRightAngles,
      polygonSnap45Angles: polygonSnap45Angles ?? this.polygonSnap45Angles,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
