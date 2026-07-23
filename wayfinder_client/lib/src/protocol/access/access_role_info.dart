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
import 'package:wayfinder_client/src/protocol/protocol.dart' as _i2;

abstract class AccessRoleInfo implements _i1.SerializableModel {
  AccessRoleInfo._({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    required this.isSystem,
    required this.permissions,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccessRoleInfo({
    required _i1.UuidValue id,
    required String key,
    required String name,
    String? description,
    required bool isSystem,
    required List<String> permissions,
    required int memberCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccessRoleInfoImpl;

  factory AccessRoleInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccessRoleInfo(
      id: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      isSystem: _i1.BoolJsonExtension.fromJson(jsonSerialization['isSystem']),
      permissions: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['permissions'],
      ),
      memberCount: jsonSerialization['memberCount'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  _i1.UuidValue id;

  String key;

  String name;

  String? description;

  bool isSystem;

  List<String> permissions;

  int memberCount;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AccessRoleInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccessRoleInfo copyWith({
    _i1.UuidValue? id,
    String? key,
    String? name,
    String? description,
    bool? isSystem,
    List<String>? permissions,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccessRoleInfo',
      'id': id.toJson(),
      'key': key,
      'name': name,
      if (description != null) 'description': description,
      'isSystem': isSystem,
      'permissions': permissions.toJson(),
      'memberCount': memberCount,
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

class _AccessRoleInfoImpl extends AccessRoleInfo {
  _AccessRoleInfoImpl({
    required _i1.UuidValue id,
    required String key,
    required String name,
    String? description,
    required bool isSystem,
    required List<String> permissions,
    required int memberCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         name: name,
         description: description,
         isSystem: isSystem,
         permissions: permissions,
         memberCount: memberCount,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccessRoleInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccessRoleInfo copyWith({
    _i1.UuidValue? id,
    String? key,
    String? name,
    Object? description = _Undefined,
    bool? isSystem,
    List<String>? permissions,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccessRoleInfo(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      isSystem: isSystem ?? this.isSystem,
      permissions: permissions ?? this.permissions.map((e0) => e0).toList(),
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
