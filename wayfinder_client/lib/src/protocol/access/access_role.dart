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

abstract class AccessRole implements _i1.SerializableModel {
  AccessRole._({
    _i1.UuidValue? id,
    required this.key,
    required this.name,
    this.description,
    required this.isSystem,
    required this.permissionsJson,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory AccessRole({
    _i1.UuidValue? id,
    required String key,
    required String name,
    String? description,
    required bool isSystem,
    required String permissionsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccessRoleImpl;

  factory AccessRole.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccessRole(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      isSystem: _i1.BoolJsonExtension.fromJson(jsonSerialization['isSystem']),
      permissionsJson: jsonSerialization['permissionsJson'] as String,
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

  /// Stable slug: admin, editor, viewer, or custom
  String key;

  String name;

  String? description;

  bool isSystem;

  /// JSON array of permission keys
  String permissionsJson;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AccessRole]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccessRole copyWith({
    _i1.UuidValue? id,
    String? key,
    String? name,
    String? description,
    bool? isSystem,
    String? permissionsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccessRole',
      'id': id.toJson(),
      'key': key,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
      'permissionsJson': permissionsJson,
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

class _AccessRoleImpl extends AccessRole {
  _AccessRoleImpl({
    _i1.UuidValue? id,
    required String key,
    required String name,
    String? description,
    required bool isSystem,
    required String permissionsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         name: name,
         description: description,
         isSystem: isSystem,
         permissionsJson: permissionsJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccessRole]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccessRole copyWith({
    _i1.UuidValue? id,
    String? key,
    String? name,
    Object? description = _Undefined,
    bool? isSystem,
    String? permissionsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccessRole(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      isSystem: isSystem ?? this.isSystem,
      permissionsJson: permissionsJson ?? this.permissionsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
