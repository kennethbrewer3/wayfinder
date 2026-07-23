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

abstract class MapZone implements _i1.SerializableModel {
  MapZone._({
    _i1.UuidValue? id,
    required this.name,
    required this.type,
    required this.color,
    required this.borderColor,
    required this.borderPattern,
    required this.fillColor,
    required this.visible,
    required this.geometryJson,
    this.layerId,
    this.createdByAuthUserId,
    this.createdByUsername,
    this.updatedByAuthUserId,
    this.updatedByUsername,
    this.deletedAt,
    this.deletedByAuthUserId,
    this.deletedByUsername,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MapZone({
    _i1.UuidValue? id,
    required String name,
    required String type,
    required String color,
    required String borderColor,
    required String borderPattern,
    required String fillColor,
    required bool visible,
    required String geometryJson,
    _i1.UuidValue? layerId,
    _i1.UuidValue? createdByAuthUserId,
    String? createdByUsername,
    _i1.UuidValue? updatedByAuthUserId,
    String? updatedByUsername,
    DateTime? deletedAt,
    _i1.UuidValue? deletedByAuthUserId,
    String? deletedByUsername,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MapZoneImpl;

  factory MapZone.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapZone(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      type: jsonSerialization['type'] as String,
      color: jsonSerialization['color'] as String,
      borderColor: jsonSerialization['borderColor'] as String,
      borderPattern: jsonSerialization['borderPattern'] as String,
      fillColor: jsonSerialization['fillColor'] as String,
      visible: _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
      geometryJson: jsonSerialization['geometryJson'] as String,
      layerId: jsonSerialization['layerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['layerId']),
      createdByAuthUserId: jsonSerialization['createdByAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByAuthUserId'],
            ),
      createdByUsername: jsonSerialization['createdByUsername'] as String?,
      updatedByAuthUserId: jsonSerialization['updatedByAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['updatedByAuthUserId'],
            ),
      updatedByUsername: jsonSerialization['updatedByUsername'] as String?,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedByAuthUserId: jsonSerialization['deletedByAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['deletedByAuthUserId'],
            ),
      deletedByUsername: jsonSerialization['deletedByUsername'] as String?,
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

  String type;

  String color;

  String borderColor;

  String borderPattern;

  String fillColor;

  bool visible;

  String geometryJson;

  _i1.UuidValue? layerId;

  /// Auth user that created this zone (null for legacy / anonymous)
  _i1.UuidValue? createdByAuthUserId;

  /// Login id / display label at create time (survives user deletion)
  String? createdByUsername;

  /// Auth user that last edited this zone
  _i1.UuidValue? updatedByAuthUserId;

  /// Login id / display label at last edit
  String? updatedByUsername;

  /// Soft-delete timestamp; null means active
  DateTime? deletedAt;

  _i1.UuidValue? deletedByAuthUserId;

  String? deletedByUsername;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MapZone]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapZone copyWith({
    _i1.UuidValue? id,
    String? name,
    String? type,
    String? color,
    String? borderColor,
    String? borderPattern,
    String? fillColor,
    bool? visible,
    String? geometryJson,
    _i1.UuidValue? layerId,
    _i1.UuidValue? createdByAuthUserId,
    String? createdByUsername,
    _i1.UuidValue? updatedByAuthUserId,
    String? updatedByUsername,
    DateTime? deletedAt,
    _i1.UuidValue? deletedByAuthUserId,
    String? deletedByUsername,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapZone',
      'id': id.toJson(),
      'name': name,
      'type': type,
      'color': color,
      'borderColor': borderColor,
      'borderPattern': borderPattern,
      'fillColor': fillColor,
      'visible': visible,
      'geometryJson': geometryJson,
      if (layerId != null) 'layerId': layerId?.toJson(),
      if (createdByAuthUserId != null)
        'createdByAuthUserId': createdByAuthUserId?.toJson(),
      if (createdByUsername != null) 'createdByUsername': createdByUsername,
      if (updatedByAuthUserId != null)
        'updatedByAuthUserId': updatedByAuthUserId?.toJson(),
      if (updatedByUsername != null) 'updatedByUsername': updatedByUsername,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByAuthUserId != null)
        'deletedByAuthUserId': deletedByAuthUserId?.toJson(),
      if (deletedByUsername != null) 'deletedByUsername': deletedByUsername,
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

class _MapZoneImpl extends MapZone {
  _MapZoneImpl({
    _i1.UuidValue? id,
    required String name,
    required String type,
    required String color,
    required String borderColor,
    required String borderPattern,
    required String fillColor,
    required bool visible,
    required String geometryJson,
    _i1.UuidValue? layerId,
    _i1.UuidValue? createdByAuthUserId,
    String? createdByUsername,
    _i1.UuidValue? updatedByAuthUserId,
    String? updatedByUsername,
    DateTime? deletedAt,
    _i1.UuidValue? deletedByAuthUserId,
    String? deletedByUsername,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         type: type,
         color: color,
         borderColor: borderColor,
         borderPattern: borderPattern,
         fillColor: fillColor,
         visible: visible,
         geometryJson: geometryJson,
         layerId: layerId,
         createdByAuthUserId: createdByAuthUserId,
         createdByUsername: createdByUsername,
         updatedByAuthUserId: updatedByAuthUserId,
         updatedByUsername: updatedByUsername,
         deletedAt: deletedAt,
         deletedByAuthUserId: deletedByAuthUserId,
         deletedByUsername: deletedByUsername,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MapZone]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapZone copyWith({
    _i1.UuidValue? id,
    String? name,
    String? type,
    String? color,
    String? borderColor,
    String? borderPattern,
    String? fillColor,
    bool? visible,
    String? geometryJson,
    Object? layerId = _Undefined,
    Object? createdByAuthUserId = _Undefined,
    Object? createdByUsername = _Undefined,
    Object? updatedByAuthUserId = _Undefined,
    Object? updatedByUsername = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByAuthUserId = _Undefined,
    Object? deletedByUsername = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapZone(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      borderPattern: borderPattern ?? this.borderPattern,
      fillColor: fillColor ?? this.fillColor,
      visible: visible ?? this.visible,
      geometryJson: geometryJson ?? this.geometryJson,
      layerId: layerId is _i1.UuidValue? ? layerId : this.layerId,
      createdByAuthUserId: createdByAuthUserId is _i1.UuidValue?
          ? createdByAuthUserId
          : this.createdByAuthUserId,
      createdByUsername: createdByUsername is String?
          ? createdByUsername
          : this.createdByUsername,
      updatedByAuthUserId: updatedByAuthUserId is _i1.UuidValue?
          ? updatedByAuthUserId
          : this.updatedByAuthUserId,
      updatedByUsername: updatedByUsername is String?
          ? updatedByUsername
          : this.updatedByUsername,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByAuthUserId: deletedByAuthUserId is _i1.UuidValue?
          ? deletedByAuthUserId
          : this.deletedByAuthUserId,
      deletedByUsername: deletedByUsername is String?
          ? deletedByUsername
          : this.deletedByUsername,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
