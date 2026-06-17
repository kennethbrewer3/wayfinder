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

abstract class MapMarker implements _i1.SerializableModel {
  MapMarker._({
    _i1.UuidValue? id,
    required this.name,
    this.notes,
    required this.latitude,
    required this.longitude,
    double? elevation,
    required this.color,
    required this.icon,
    required this.visible,
    this.layerId,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       elevation = elevation ?? 0.0;

  factory MapMarker({
    _i1.UuidValue? id,
    required String name,
    String? notes,
    required double latitude,
    required double longitude,
    double? elevation,
    required String color,
    required String icon,
    required bool visible,
    _i1.UuidValue? layerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MapMarkerImpl;

  factory MapMarker.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapMarker(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      notes: jsonSerialization['notes'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      elevation: (jsonSerialization['elevation'] as num?)?.toDouble(),
      color: jsonSerialization['color'] as String,
      icon: jsonSerialization['icon'] as String,
      visible: _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
      layerId: jsonSerialization['layerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['layerId']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String name;

  String? notes;

  double latitude;

  double longitude;

  double elevation;

  String color;

  String icon;

  bool visible;

  _i1.UuidValue? layerId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MapMarker]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapMarker copyWith({
    _i1.UuidValue? id,
    String? name,
    String? notes,
    double? latitude,
    double? longitude,
    double? elevation,
    String? color,
    String? icon,
    bool? visible,
    _i1.UuidValue? layerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapMarker',
      'id': id.toJson(),
      'name': name,
      if (notes != null) 'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'color': color,
      'icon': icon,
      'visible': visible,
      if (layerId != null) 'layerId': layerId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MapMarkerImpl extends MapMarker {
  _MapMarkerImpl({
    _i1.UuidValue? id,
    required String name,
    String? notes,
    required double latitude,
    required double longitude,
    double? elevation,
    required String color,
    required String icon,
    required bool visible,
    _i1.UuidValue? layerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         notes: notes,
         latitude: latitude,
         longitude: longitude,
         elevation: elevation,
         color: color,
         icon: icon,
         visible: visible,
         layerId: layerId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MapMarker]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapMarker copyWith({
    _i1.UuidValue? id,
    String? name,
    Object? notes = _Undefined,
    double? latitude,
    double? longitude,
    double? elevation,
    String? color,
    String? icon,
    bool? visible,
    Object? layerId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapMarker(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes is String? ? notes : this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      visible: visible ?? this.visible,
      layerId: layerId is _i1.UuidValue? ? layerId : this.layerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
