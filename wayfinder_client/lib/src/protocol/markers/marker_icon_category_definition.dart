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

abstract class MarkerIconCategoryDefinition implements _i1.SerializableModel {
  MarkerIconCategoryDefinition._({
    _i1.UuidValue? id,
    required this.key,
    required this.label,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MarkerIconCategoryDefinition({
    _i1.UuidValue? id,
    required String key,
    required String label,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarkerIconCategoryDefinitionImpl;

  factory MarkerIconCategoryDefinition.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MarkerIconCategoryDefinition(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
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

  String key;

  String label;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MarkerIconCategoryDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkerIconCategoryDefinition copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarkerIconCategoryDefinition',
      'id': id.toJson(),
      'key': key,
      'label': label,
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

class _MarkerIconCategoryDefinitionImpl extends MarkerIconCategoryDefinition {
  _MarkerIconCategoryDefinitionImpl({
    _i1.UuidValue? id,
    required String key,
    required String label,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         label: label,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MarkerIconCategoryDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkerIconCategoryDefinition copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarkerIconCategoryDefinition(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
