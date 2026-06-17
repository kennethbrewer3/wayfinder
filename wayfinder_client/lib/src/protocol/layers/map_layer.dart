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

abstract class MapLayer implements _i1.SerializableModel {
  MapLayer._({
    _i1.UuidValue? id,
    required this.name,
    required this.sortOrder,
    bool? visible,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       visible = visible ?? true;

  factory MapLayer({
    _i1.UuidValue? id,
    required String name,
    required int sortOrder,
    bool? visible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MapLayerImpl;

  factory MapLayer.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapLayer(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      visible: jsonSerialization['visible'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['visible']),
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

  int sortOrder;

  bool visible;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MapLayer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapLayer copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapLayer',
      'id': id.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'visible': visible,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MapLayerImpl extends MapLayer {
  _MapLayerImpl({
    _i1.UuidValue? id,
    required String name,
    required int sortOrder,
    bool? visible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         sortOrder: sortOrder,
         visible: visible,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MapLayer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapLayer copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
