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

abstract class SeasonalOverlay implements _i1.SerializableModel {
  SeasonalOverlay._({
    _i1.UuidValue? id,
    required this.name,
    required this.color,
    required this.borderColor,
    required this.fillColor,
    bool? visible,
    this.notes,
    required this.dateMode,
    required this.dateWindowsJson,
    required this.geometryJson,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       visible = visible ?? true;

  factory SeasonalOverlay({
    _i1.UuidValue? id,
    required String name,
    required String color,
    required String borderColor,
    required String fillColor,
    bool? visible,
    String? notes,
    required String dateMode,
    required String dateWindowsJson,
    required String geometryJson,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SeasonalOverlayImpl;

  factory SeasonalOverlay.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeasonalOverlay(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      color: jsonSerialization['color'] as String,
      borderColor: jsonSerialization['borderColor'] as String,
      fillColor: jsonSerialization['fillColor'] as String,
      visible: jsonSerialization['visible'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
      notes: jsonSerialization['notes'] as String?,
      dateMode: jsonSerialization['dateMode'] as String,
      dateWindowsJson: jsonSerialization['dateWindowsJson'] as String,
      geometryJson: jsonSerialization['geometryJson'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
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

  String color;

  String borderColor;

  String fillColor;

  bool visible;

  String? notes;

  /// One of: absolute, recurring
  String dateMode;

  /// JSON list of date windows (shape depends on dateMode)
  String dateWindowsJson;

  /// Polygon geometry JSON (same shape as MapZone polygon geometryJson)
  String geometryJson;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [SeasonalOverlay]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SeasonalOverlay copyWith({
    _i1.UuidValue? id,
    String? name,
    String? color,
    String? borderColor,
    String? fillColor,
    bool? visible,
    String? notes,
    String? dateMode,
    String? dateWindowsJson,
    String? geometryJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeasonalOverlay',
      'id': id.toJson(),
      'name': name,
      'color': color,
      'borderColor': borderColor,
      'fillColor': fillColor,
      'visible': visible,
      if (notes != null) 'notes': notes,
      'dateMode': dateMode,
      'dateWindowsJson': dateWindowsJson,
      'geometryJson': geometryJson,
      'sortOrder': sortOrder,
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

class _SeasonalOverlayImpl extends SeasonalOverlay {
  _SeasonalOverlayImpl({
    _i1.UuidValue? id,
    required String name,
    required String color,
    required String borderColor,
    required String fillColor,
    bool? visible,
    String? notes,
    required String dateMode,
    required String dateWindowsJson,
    required String geometryJson,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         color: color,
         borderColor: borderColor,
         fillColor: fillColor,
         visible: visible,
         notes: notes,
         dateMode: dateMode,
         dateWindowsJson: dateWindowsJson,
         geometryJson: geometryJson,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SeasonalOverlay]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SeasonalOverlay copyWith({
    _i1.UuidValue? id,
    String? name,
    String? color,
    String? borderColor,
    String? fillColor,
    bool? visible,
    Object? notes = _Undefined,
    String? dateMode,
    String? dateWindowsJson,
    String? geometryJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeasonalOverlay(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      fillColor: fillColor ?? this.fillColor,
      visible: visible ?? this.visible,
      notes: notes is String? ? notes : this.notes,
      dateMode: dateMode ?? this.dateMode,
      dateWindowsJson: dateWindowsJson ?? this.dateWindowsJson,
      geometryJson: geometryJson ?? this.geometryJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
