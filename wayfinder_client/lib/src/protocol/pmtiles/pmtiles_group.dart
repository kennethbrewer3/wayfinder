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

abstract class PmtilesGroup implements _i1.SerializableModel {
  PmtilesGroup._({
    _i1.UuidValue? id,
    required this.name,
    int? sortOrder,
    required this.createdAt,
    bool? showOnMap,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       sortOrder = sortOrder ?? 0,
       showOnMap = showOnMap ?? false;

  factory PmtilesGroup({
    _i1.UuidValue? id,
    required String name,
    int? sortOrder,
    required DateTime createdAt,
    bool? showOnMap,
  }) = _PmtilesGroupImpl;

  factory PmtilesGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return PmtilesGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      showOnMap: jsonSerialization['showOnMap'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['showOnMap']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String name;

  int sortOrder;

  DateTime createdAt;

  bool showOnMap;

  /// Returns a shallow copy of this [PmtilesGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PmtilesGroup copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    bool? showOnMap,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PmtilesGroup',
      'id': id.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'showOnMap': showOnMap,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PmtilesGroupImpl extends PmtilesGroup {
  _PmtilesGroupImpl({
    _i1.UuidValue? id,
    required String name,
    int? sortOrder,
    required DateTime createdAt,
    bool? showOnMap,
  }) : super._(
         id: id,
         name: name,
         sortOrder: sortOrder,
         createdAt: createdAt,
         showOnMap: showOnMap,
       );

  /// Returns a shallow copy of this [PmtilesGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PmtilesGroup copyWith({
    _i1.UuidValue? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    bool? showOnMap,
  }) {
    return PmtilesGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      showOnMap: showOnMap ?? this.showOnMap,
    );
  }
}
