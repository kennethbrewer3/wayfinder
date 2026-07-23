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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class AccessUserInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AccessUserInfo._({
    required this.membershipId,
    required this.authUserId,
    required this.email,
    this.displayName,
    required this.roleId,
    required this.roleKey,
    required this.roleName,
    required this.blocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccessUserInfo({
    required _i1.UuidValue membershipId,
    required _i1.UuidValue authUserId,
    required String email,
    String? displayName,
    required _i1.UuidValue roleId,
    required String roleKey,
    required String roleName,
    required bool blocked,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccessUserInfoImpl;

  factory AccessUserInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccessUserInfo(
      membershipId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['membershipId'],
      ),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      email: jsonSerialization['email'] as String,
      displayName: jsonSerialization['displayName'] as String?,
      roleId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['roleId']),
      roleKey: jsonSerialization['roleKey'] as String,
      roleName: jsonSerialization['roleName'] as String,
      blocked: _i1.BoolJsonExtension.fromJson(jsonSerialization['blocked']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  _i1.UuidValue membershipId;

  _i1.UuidValue authUserId;

  String email;

  String? displayName;

  _i1.UuidValue roleId;

  String roleKey;

  String roleName;

  bool blocked;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AccessUserInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccessUserInfo copyWith({
    _i1.UuidValue? membershipId,
    _i1.UuidValue? authUserId,
    String? email,
    String? displayName,
    _i1.UuidValue? roleId,
    String? roleKey,
    String? roleName,
    bool? blocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccessUserInfo',
      'membershipId': membershipId.toJson(),
      'authUserId': authUserId.toJson(),
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'roleId': roleId.toJson(),
      'roleKey': roleKey,
      'roleName': roleName,
      'blocked': blocked,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccessUserInfo',
      'membershipId': membershipId.toJson(),
      'authUserId': authUserId.toJson(),
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'roleId': roleId.toJson(),
      'roleKey': roleKey,
      'roleName': roleName,
      'blocked': blocked,
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

class _AccessUserInfoImpl extends AccessUserInfo {
  _AccessUserInfoImpl({
    required _i1.UuidValue membershipId,
    required _i1.UuidValue authUserId,
    required String email,
    String? displayName,
    required _i1.UuidValue roleId,
    required String roleKey,
    required String roleName,
    required bool blocked,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         membershipId: membershipId,
         authUserId: authUserId,
         email: email,
         displayName: displayName,
         roleId: roleId,
         roleKey: roleKey,
         roleName: roleName,
         blocked: blocked,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccessUserInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccessUserInfo copyWith({
    _i1.UuidValue? membershipId,
    _i1.UuidValue? authUserId,
    String? email,
    Object? displayName = _Undefined,
    _i1.UuidValue? roleId,
    String? roleKey,
    String? roleName,
    bool? blocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccessUserInfo(
      membershipId: membershipId ?? this.membershipId,
      authUserId: authUserId ?? this.authUserId,
      email: email ?? this.email,
      displayName: displayName is String? ? displayName : this.displayName,
      roleId: roleId ?? this.roleId,
      roleKey: roleKey ?? this.roleKey,
      roleName: roleName ?? this.roleName,
      blocked: blocked ?? this.blocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
