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

abstract class AccessSessionInfo implements _i1.SerializableModel {
  AccessSessionInfo._({
    required this.authRequired,
    required this.authenticated,
    this.authUserId,
    this.email,
    this.displayName,
    this.roleKey,
    this.roleName,
    required this.isAdmin,
    required this.permissions,
    required this.canEditMap,
    required this.canManageUsers,
    required this.canManageRoles,
    required this.canManageSettings,
    required this.canManageBackups,
    required this.canManageApiKeys,
    required this.canManageLayers,
    required this.canManageTides,
    required this.canManageGeocoding,
    required this.canManageMarkerIcons,
    required this.canManagePmtiles,
    required this.canManageMapHome,
    required this.canManageMapZoom,
  });

  factory AccessSessionInfo({
    required bool authRequired,
    required bool authenticated,
    _i1.UuidValue? authUserId,
    String? email,
    String? displayName,
    String? roleKey,
    String? roleName,
    required bool isAdmin,
    required List<String> permissions,
    required bool canEditMap,
    required bool canManageUsers,
    required bool canManageRoles,
    required bool canManageSettings,
    required bool canManageBackups,
    required bool canManageApiKeys,
    required bool canManageLayers,
    required bool canManageTides,
    required bool canManageGeocoding,
    required bool canManageMarkerIcons,
    required bool canManagePmtiles,
    required bool canManageMapHome,
    required bool canManageMapZoom,
  }) = _AccessSessionInfoImpl;

  factory AccessSessionInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccessSessionInfo(
      authRequired: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['authRequired'],
      ),
      authenticated: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['authenticated'],
      ),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      email: jsonSerialization['email'] as String?,
      displayName: jsonSerialization['displayName'] as String?,
      roleKey: jsonSerialization['roleKey'] as String?,
      roleName: jsonSerialization['roleName'] as String?,
      isAdmin: _i1.BoolJsonExtension.fromJson(jsonSerialization['isAdmin']),
      permissions: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['permissions'],
      ),
      canEditMap: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canEditMap'],
      ),
      canManageUsers: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageUsers'],
      ),
      canManageRoles: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageRoles'],
      ),
      canManageSettings: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageSettings'],
      ),
      canManageBackups: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageBackups'],
      ),
      canManageApiKeys: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageApiKeys'],
      ),
      canManageLayers: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageLayers'],
      ),
      canManageTides: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageTides'],
      ),
      canManageGeocoding: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageGeocoding'],
      ),
      canManageMarkerIcons: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageMarkerIcons'],
      ),
      canManagePmtiles: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManagePmtiles'],
      ),
      canManageMapHome: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageMapHome'],
      ),
      canManageMapZoom: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['canManageMapZoom'],
      ),
    );
  }

  bool authRequired;

  bool authenticated;

  _i1.UuidValue? authUserId;

  String? email;

  String? displayName;

  String? roleKey;

  String? roleName;

  bool isAdmin;

  List<String> permissions;

  bool canEditMap;

  bool canManageUsers;

  bool canManageRoles;

  bool canManageSettings;

  bool canManageBackups;

  bool canManageApiKeys;

  bool canManageLayers;

  bool canManageTides;

  bool canManageGeocoding;

  bool canManageMarkerIcons;

  bool canManagePmtiles;

  bool canManageMapHome;

  bool canManageMapZoom;

  /// Returns a shallow copy of this [AccessSessionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccessSessionInfo copyWith({
    bool? authRequired,
    bool? authenticated,
    _i1.UuidValue? authUserId,
    String? email,
    String? displayName,
    String? roleKey,
    String? roleName,
    bool? isAdmin,
    List<String>? permissions,
    bool? canEditMap,
    bool? canManageUsers,
    bool? canManageRoles,
    bool? canManageSettings,
    bool? canManageBackups,
    bool? canManageApiKeys,
    bool? canManageLayers,
    bool? canManageTides,
    bool? canManageGeocoding,
    bool? canManageMarkerIcons,
    bool? canManagePmtiles,
    bool? canManageMapHome,
    bool? canManageMapZoom,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccessSessionInfo',
      'authRequired': authRequired,
      'authenticated': authenticated,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (roleKey != null) 'roleKey': roleKey,
      if (roleName != null) 'roleName': roleName,
      'isAdmin': isAdmin,
      'permissions': permissions.toJson(),
      'canEditMap': canEditMap,
      'canManageUsers': canManageUsers,
      'canManageRoles': canManageRoles,
      'canManageSettings': canManageSettings,
      'canManageBackups': canManageBackups,
      'canManageApiKeys': canManageApiKeys,
      'canManageLayers': canManageLayers,
      'canManageTides': canManageTides,
      'canManageGeocoding': canManageGeocoding,
      'canManageMarkerIcons': canManageMarkerIcons,
      'canManagePmtiles': canManagePmtiles,
      'canManageMapHome': canManageMapHome,
      'canManageMapZoom': canManageMapZoom,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccessSessionInfoImpl extends AccessSessionInfo {
  _AccessSessionInfoImpl({
    required bool authRequired,
    required bool authenticated,
    _i1.UuidValue? authUserId,
    String? email,
    String? displayName,
    String? roleKey,
    String? roleName,
    required bool isAdmin,
    required List<String> permissions,
    required bool canEditMap,
    required bool canManageUsers,
    required bool canManageRoles,
    required bool canManageSettings,
    required bool canManageBackups,
    required bool canManageApiKeys,
    required bool canManageLayers,
    required bool canManageTides,
    required bool canManageGeocoding,
    required bool canManageMarkerIcons,
    required bool canManagePmtiles,
    required bool canManageMapHome,
    required bool canManageMapZoom,
  }) : super._(
         authRequired: authRequired,
         authenticated: authenticated,
         authUserId: authUserId,
         email: email,
         displayName: displayName,
         roleKey: roleKey,
         roleName: roleName,
         isAdmin: isAdmin,
         permissions: permissions,
         canEditMap: canEditMap,
         canManageUsers: canManageUsers,
         canManageRoles: canManageRoles,
         canManageSettings: canManageSettings,
         canManageBackups: canManageBackups,
         canManageApiKeys: canManageApiKeys,
         canManageLayers: canManageLayers,
         canManageTides: canManageTides,
         canManageGeocoding: canManageGeocoding,
         canManageMarkerIcons: canManageMarkerIcons,
         canManagePmtiles: canManagePmtiles,
         canManageMapHome: canManageMapHome,
         canManageMapZoom: canManageMapZoom,
       );

  /// Returns a shallow copy of this [AccessSessionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccessSessionInfo copyWith({
    bool? authRequired,
    bool? authenticated,
    Object? authUserId = _Undefined,
    Object? email = _Undefined,
    Object? displayName = _Undefined,
    Object? roleKey = _Undefined,
    Object? roleName = _Undefined,
    bool? isAdmin,
    List<String>? permissions,
    bool? canEditMap,
    bool? canManageUsers,
    bool? canManageRoles,
    bool? canManageSettings,
    bool? canManageBackups,
    bool? canManageApiKeys,
    bool? canManageLayers,
    bool? canManageTides,
    bool? canManageGeocoding,
    bool? canManageMarkerIcons,
    bool? canManagePmtiles,
    bool? canManageMapHome,
    bool? canManageMapZoom,
  }) {
    return AccessSessionInfo(
      authRequired: authRequired ?? this.authRequired,
      authenticated: authenticated ?? this.authenticated,
      authUserId: authUserId is _i1.UuidValue? ? authUserId : this.authUserId,
      email: email is String? ? email : this.email,
      displayName: displayName is String? ? displayName : this.displayName,
      roleKey: roleKey is String? ? roleKey : this.roleKey,
      roleName: roleName is String? ? roleName : this.roleName,
      isAdmin: isAdmin ?? this.isAdmin,
      permissions: permissions ?? this.permissions.map((e0) => e0).toList(),
      canEditMap: canEditMap ?? this.canEditMap,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canManageRoles: canManageRoles ?? this.canManageRoles,
      canManageSettings: canManageSettings ?? this.canManageSettings,
      canManageBackups: canManageBackups ?? this.canManageBackups,
      canManageApiKeys: canManageApiKeys ?? this.canManageApiKeys,
      canManageLayers: canManageLayers ?? this.canManageLayers,
      canManageTides: canManageTides ?? this.canManageTides,
      canManageGeocoding: canManageGeocoding ?? this.canManageGeocoding,
      canManageMarkerIcons: canManageMarkerIcons ?? this.canManageMarkerIcons,
      canManagePmtiles: canManagePmtiles ?? this.canManagePmtiles,
      canManageMapHome: canManageMapHome ?? this.canManageMapHome,
      canManageMapZoom: canManageMapZoom ?? this.canManageMapZoom,
    );
  }
}
