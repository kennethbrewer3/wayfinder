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

abstract class Category implements _i1.SerializableModel {
  Category._({
    _i1.UuidValue? id,
    this.parentId,
    required this.name,
    required this.sortOrder,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory Category({
    _i1.UuidValue? id,
    _i1.UuidValue? parentId,
    required String name,
    required int sortOrder,
  }) = _CategoryImpl;

  factory Category.fromJson(Map<String, dynamic> jsonSerialization) {
    return Category(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      parentId: jsonSerialization['parentId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['parentId']),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue? parentId;

  String name;

  int sortOrder;

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Category copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? parentId,
    String? name,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Category',
      'id': id.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'name': name,
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CategoryImpl extends Category {
  _CategoryImpl({
    _i1.UuidValue? id,
    _i1.UuidValue? parentId,
    required String name,
    required int sortOrder,
  }) : super._(
         id: id,
         parentId: parentId,
         name: name,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Category copyWith({
    _i1.UuidValue? id,
    Object? parentId = _Undefined,
    String? name,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      parentId: parentId is _i1.UuidValue? ? parentId : this.parentId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
