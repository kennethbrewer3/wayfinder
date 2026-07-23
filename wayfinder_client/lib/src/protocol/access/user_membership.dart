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

abstract class UserMembership implements _i1.SerializableModel {
  UserMembership._({
    _i1.UuidValue? id,
    required this.authUserId,
    required this.roleId,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory UserMembership({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required _i1.UuidValue roleId,
    required String email,
    String? displayName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserMembershipImpl;

  factory UserMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserMembership(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      roleId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['roleId']),
      email: jsonSerialization['email'] as String,
      displayName: jsonSerialization['displayName'] as String?,
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

  _i1.UuidValue authUserId;

  _i1.UuidValue roleId;

  String email;

  String? displayName;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserMembership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserMembership copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i1.UuidValue? roleId,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserMembership',
      'id': id.toJson(),
      'authUserId': authUserId.toJson(),
      'roleId': roleId.toJson(),
      'email': email,
      if (displayName != null) 'displayName': displayName,
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

class _UserMembershipImpl extends UserMembership {
  _UserMembershipImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required _i1.UuidValue roleId,
    required String email,
    String? displayName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         roleId: roleId,
         email: email,
         displayName: displayName,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserMembership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserMembership copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i1.UuidValue? roleId,
    String? email,
    Object? displayName = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserMembership(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      roleId: roleId ?? this.roleId,
      email: email ?? this.email,
      displayName: displayName is String? ? displayName : this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
