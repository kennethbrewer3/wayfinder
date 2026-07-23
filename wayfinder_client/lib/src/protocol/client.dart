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
import 'dart:async' as _i2;
import 'package:wayfinder_client/src/protocol/access/access_session_info.dart'
    as _i3;
import 'package:wayfinder_client/src/protocol/access/access_user_info.dart'
    as _i4;
import 'package:wayfinder_client/src/protocol/access/access_role_info.dart'
    as _i5;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i6;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i7;
import 'package:wayfinder_client/src/protocol/categories/category.dart' as _i8;
import 'package:wayfinder_client/src/protocol/greetings/greeting.dart' as _i9;
import 'package:wayfinder_client/src/protocol/layers/map_layer.dart' as _i10;
import 'package:wayfinder_client/src/protocol/layers/map_layer_change.dart'
    as _i11;
import 'package:wayfinder_client/src/protocol/map/map_data_restore_summary.dart'
    as _i12;
import 'dart:typed_data' as _i13;
import 'package:wayfinder_client/src/protocol/map/map_marker.dart' as _i14;
import 'package:wayfinder_client/src/protocol/map/map_marker_change.dart'
    as _i15;
import 'package:wayfinder_client/src/protocol/markers/marker_attachment.dart'
    as _i16;
import 'package:wayfinder_client/src/protocol/markers/marker_icon_catalog_entry.dart'
    as _i17;
import 'package:wayfinder_client/src/protocol/markers/marker_icon_category_definition.dart'
    as _i18;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_file.dart'
    as _i19;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_group.dart'
    as _i20;
import 'package:wayfinder_client/src/protocol/seasonal_overlays/seasonal_overlay.dart'
    as _i21;
import 'package:wayfinder_client/src/protocol/seasonal_overlays/seasonal_overlay_change.dart'
    as _i22;
import 'package:wayfinder_client/src/protocol/settings/app_settings.dart'
    as _i23;
import 'package:wayfinder_client/src/protocol/settings/user_client_preferences.dart'
    as _i24;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key_info.dart'
    as _i25;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key.dart'
    as _i26;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key_created.dart'
    as _i27;
import 'package:wayfinder_client/src/protocol/tides/tide_pack_info.dart'
    as _i28;
import 'package:wayfinder_client/src/protocol/tides/tide_coastal_region.dart'
    as _i29;
import 'package:wayfinder_client/src/protocol/tides/tide_query_result.dart'
    as _i30;
import 'package:wayfinder_client/src/protocol/watch_log/watch_log_entry.dart'
    as _i31;
import 'package:wayfinder_client/src/protocol/watch_log/watch_log_entry_change.dart'
    as _i32;
import 'package:wayfinder_client/src/protocol/zones/map_zone.dart' as _i33;
import 'package:wayfinder_client/src/protocol/zones/map_zone_change.dart'
    as _i34;
import 'protocol.dart' as _i35;

/// {@category Endpoint}
class EndpointAccessControl extends _i1.EndpointRef {
  EndpointAccessControl(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'accessControl';

  /// Public: whether login is required and the caller's effective permissions.
  _i2.Future<_i3.AccessSessionInfo> getSessionInfo() =>
      caller.callServerEndpoint<_i3.AccessSessionInfo>(
        'accessControl',
        'getSessionInfo',
        {},
      );

  _i2.Future<List<String>> listKnownPermissions() =>
      caller.callServerEndpoint<List<String>>(
        'accessControl',
        'listKnownPermissions',
        {},
      );

  _i2.Future<List<_i4.AccessUserInfo>> listUsers() =>
      caller.callServerEndpoint<List<_i4.AccessUserInfo>>(
        'accessControl',
        'listUsers',
        {},
      );

  _i2.Future<_i4.AccessUserInfo> createUser(
    String email,
    String password,
    _i1.UuidValue roleId,
    String? displayName,
  ) => caller.callServerEndpoint<_i4.AccessUserInfo>(
    'accessControl',
    'createUser',
    {
      'email': email,
      'password': password,
      'roleId': roleId,
      'displayName': displayName,
    },
  );

  /// Any signed-in user may change their own password (current password required).
  _i2.Future<bool> changeOwnPassword(
    String currentPassword,
    String newPassword,
  ) => caller.callServerEndpoint<bool>(
    'accessControl',
    'changeOwnPassword',
    {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );

  _i2.Future<_i4.AccessUserInfo> updateUserRole(
    _i1.UuidValue membershipId,
    _i1.UuidValue roleId,
  ) => caller.callServerEndpoint<_i4.AccessUserInfo>(
    'accessControl',
    'updateUserRole',
    {
      'membershipId': membershipId,
      'roleId': roleId,
    },
  );

  _i2.Future<bool> setUserBlocked(
    _i1.UuidValue membershipId,
    bool blocked,
  ) => caller.callServerEndpoint<bool>(
    'accessControl',
    'setUserBlocked',
    {
      'membershipId': membershipId,
      'blocked': blocked,
    },
  );

  _i2.Future<bool> deleteUser(_i1.UuidValue membershipId) =>
      caller.callServerEndpoint<bool>(
        'accessControl',
        'deleteUser',
        {'membershipId': membershipId},
      );

  /// Admin forgotten-password recovery: set a new password for a TOC user.
  _i2.Future<bool> resetUserPassword(
    _i1.UuidValue membershipId,
    String newPassword,
  ) => caller.callServerEndpoint<bool>(
    'accessControl',
    'resetUserPassword',
    {
      'membershipId': membershipId,
      'newPassword': newPassword,
    },
  );

  _i2.Future<List<_i5.AccessRoleInfo>> listRoles() =>
      caller.callServerEndpoint<List<_i5.AccessRoleInfo>>(
        'accessControl',
        'listRoles',
        {},
      );

  _i2.Future<_i5.AccessRoleInfo> createRole(
    String key,
    String name,
    String? description,
    List<String> permissions,
  ) => caller.callServerEndpoint<_i5.AccessRoleInfo>(
    'accessControl',
    'createRole',
    {
      'key': key,
      'name': name,
      'description': description,
      'permissions': permissions,
    },
  );

  _i2.Future<_i5.AccessRoleInfo> updateRole(
    _i1.UuidValue roleId,
    String? name,
    String? description,
    List<String>? permissions,
  ) => caller.callServerEndpoint<_i5.AccessRoleInfo>(
    'accessControl',
    'updateRole',
    {
      'roleId': roleId,
      'name': name,
      'description': description,
      'permissions': permissions,
    },
  );

  _i2.Future<bool> deleteRole(_i1.UuidValue roleId) =>
      caller.callServerEndpoint<bool>(
        'accessControl',
        'deleteRole',
        {'roleId': roleId},
      );
}

/// Email identity provider endpoints.
///
/// Public self-registration is disabled — TOC admins create accounts.
/// {@category Endpoint}
class EndpointEmailIdp extends _i6.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  @override
  _i2.Future<_i7.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i7.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<_i7.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i7.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i7.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i2.Future<_i7.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i7.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointCategory extends _i1.EndpointRef {
  EndpointCategory(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  _i2.Future<List<_i8.Category>> listCategories() =>
      caller.callServerEndpoint<List<_i8.Category>>(
        'category',
        'listCategories',
        {},
      );

  _i2.Future<_i8.Category?> getCategory(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i8.Category?>(
        'category',
        'getCategory',
        {'id': id},
      );

  _i2.Future<_i8.Category> createCategory(_i8.Category category) =>
      caller.callServerEndpoint<_i8.Category>(
        'category',
        'createCategory',
        {'category': category},
      );

  _i2.Future<_i8.Category> updateCategory(_i8.Category category) =>
      caller.callServerEndpoint<_i8.Category>(
        'category',
        'updateCategory',
        {'category': category},
      );

  _i2.Future<bool> deleteCategory(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'category',
        'deleteCategory',
        {'id': id},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i9.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i9.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// {@category Endpoint}
class EndpointMapLayer extends _i1.EndpointRef {
  EndpointMapLayer(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapLayer';

  _i2.Future<List<_i10.MapLayer>> listLayers() =>
      caller.callServerEndpoint<List<_i10.MapLayer>>(
        'mapLayer',
        'listLayers',
        {},
      );

  _i2.Future<_i10.MapLayer?> getLayer(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i10.MapLayer?>(
        'mapLayer',
        'getLayer',
        {'id': id},
      );

  _i2.Future<_i10.MapLayer> createLayer(_i10.MapLayer layer) =>
      caller.callServerEndpoint<_i10.MapLayer>(
        'mapLayer',
        'createLayer',
        {'layer': layer},
      );

  _i2.Future<_i10.MapLayer> updateLayer(_i10.MapLayer layer) =>
      caller.callServerEndpoint<_i10.MapLayer>(
        'mapLayer',
        'updateLayer',
        {'layer': layer},
      );

  _i2.Future<bool> deleteLayer(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapLayer',
        'deleteLayer',
        {'id': id},
      );

  _i2.Future<List<_i10.MapLayer>> reorderLayers(List<_i10.MapLayer> layers) =>
      caller.callServerEndpoint<List<_i10.MapLayer>>(
        'mapLayer',
        'reorderLayers',
        {'layers': layers},
      );

  _i2.Stream<_i11.MapLayerChange> layerChanges() =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i11.MapLayerChange>,
        _i11.MapLayerChange
      >(
        'mapLayer',
        'layerChanges',
        {},
        {},
      );
}

/// {@category Endpoint}
class EndpointMapData extends _i1.EndpointRef {
  EndpointMapData(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapData';

  _i2.Future<String> exportMapData() => caller.callServerEndpoint<String>(
    'mapData',
    'exportMapData',
    {},
  );

  _i2.Future<_i12.MapDataRestoreSummary> restoreMapData(String backupJson) =>
      caller.callServerEndpoint<_i12.MapDataRestoreSummary>(
        'mapData',
        'restoreMapData',
        {'backupJson': backupJson},
      );

  _i2.Future<_i13.ByteData> exportMapDataArchive() =>
      caller.callServerEndpoint<_i13.ByteData>(
        'mapData',
        'exportMapDataArchive',
        {},
      );

  _i2.Future<_i12.MapDataRestoreSummary> restoreMapDataArchive(
    _i13.ByteData archiveBytes,
  ) => caller.callServerEndpoint<_i12.MapDataRestoreSummary>(
    'mapData',
    'restoreMapDataArchive',
    {'archiveBytes': archiveBytes},
  );
}

/// {@category Endpoint}
class EndpointMapMarker extends _i1.EndpointRef {
  EndpointMapMarker(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapMarker';

  _i2.Future<List<_i14.MapMarker>> listMarkers() =>
      caller.callServerEndpoint<List<_i14.MapMarker>>(
        'mapMarker',
        'listMarkers',
        {},
      );

  _i2.Future<List<_i14.MapMarker>> listDeletedMarkers() =>
      caller.callServerEndpoint<List<_i14.MapMarker>>(
        'mapMarker',
        'listDeletedMarkers',
        {},
      );

  _i2.Future<_i14.MapMarker?> getMarker(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i14.MapMarker?>(
        'mapMarker',
        'getMarker',
        {'id': id},
      );

  _i2.Future<_i14.MapMarker> createMarker(_i14.MapMarker marker) =>
      caller.callServerEndpoint<_i14.MapMarker>(
        'mapMarker',
        'createMarker',
        {'marker': marker},
      );

  _i2.Future<_i14.MapMarker> updateMarker(_i14.MapMarker marker) =>
      caller.callServerEndpoint<_i14.MapMarker>(
        'mapMarker',
        'updateMarker',
        {'marker': marker},
      );

  _i2.Future<bool> deleteMarker(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapMarker',
        'deleteMarker',
        {'id': id},
      );

  _i2.Future<_i14.MapMarker?> restoreMarker(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i14.MapMarker?>(
        'mapMarker',
        'restoreMarker',
        {'id': id},
      );

  _i2.Future<bool> purgeDeletedMarker(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapMarker',
        'purgeDeletedMarker',
        {'id': id},
      );

  _i2.Stream<_i15.MapMarkerChange> markerChanges() =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i15.MapMarkerChange>,
        _i15.MapMarkerChange
      >(
        'mapMarker',
        'markerChanges',
        {},
        {},
      );
}

/// {@category Endpoint}
class EndpointMarkerAttachment extends _i1.EndpointRef {
  EndpointMarkerAttachment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'markerAttachment';

  _i2.Future<List<_i16.MarkerAttachment>> listForMarker(
    _i1.UuidValue markerId,
  ) => caller.callServerEndpoint<List<_i16.MarkerAttachment>>(
    'markerAttachment',
    'listForMarker',
    {'markerId': markerId},
  );

  _i2.Future<bool> deleteAttachment(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'markerAttachment',
        'deleteAttachment',
        {'id': id},
      );
}

/// {@category Endpoint}
class EndpointMarkerIcon extends _i1.EndpointRef {
  EndpointMarkerIcon(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'markerIcon';

  _i2.Future<List<_i17.MarkerIconCatalogEntry>> listCatalog() =>
      caller.callServerEndpoint<List<_i17.MarkerIconCatalogEntry>>(
        'markerIcon',
        'listCatalog',
        {},
      );

  _i2.Future<_i17.MarkerIconCatalogEntry> createIcon(
    String key,
    String label, {
    String? category,
    String? iconBackgroundColor,
    String? materialIcon,
    required bool coloredAsset,
    required double glyphScale,
    int? sortOrder,
  }) => caller.callServerEndpoint<_i17.MarkerIconCatalogEntry>(
    'markerIcon',
    'createIcon',
    {
      'key': key,
      'label': label,
      'category': category,
      'iconBackgroundColor': iconBackgroundColor,
      'materialIcon': materialIcon,
      'coloredAsset': coloredAsset,
      'glyphScale': glyphScale,
      'sortOrder': sortOrder,
    },
  );

  _i2.Future<_i17.MarkerIconCatalogEntry> updateIcon(
    String key,
    String label, {
    String? category,
    String? iconBackgroundColor,
    String? materialIcon,
    bool? coloredAsset,
    double? glyphScale,
    int? sortOrder,
  }) => caller.callServerEndpoint<_i17.MarkerIconCatalogEntry>(
    'markerIcon',
    'updateIcon',
    {
      'key': key,
      'label': label,
      'category': category,
      'iconBackgroundColor': iconBackgroundColor,
      'materialIcon': materialIcon,
      'coloredAsset': coloredAsset,
      'glyphScale': glyphScale,
      'sortOrder': sortOrder,
    },
  );

  _i2.Future<bool> deleteIcon(String key) => caller.callServerEndpoint<bool>(
    'markerIcon',
    'deleteIcon',
    {'key': key},
  );

  _i2.Future<List<_i18.MarkerIconCategoryDefinition>> listCategories() =>
      caller.callServerEndpoint<List<_i18.MarkerIconCategoryDefinition>>(
        'markerIcon',
        'listCategories',
        {},
      );

  _i2.Future<_i18.MarkerIconCategoryDefinition> createCategory(
    String key,
    String label, {
    int? sortOrder,
  }) => caller.callServerEndpoint<_i18.MarkerIconCategoryDefinition>(
    'markerIcon',
    'createCategory',
    {
      'key': key,
      'label': label,
      'sortOrder': sortOrder,
    },
  );

  _i2.Future<_i18.MarkerIconCategoryDefinition> updateCategory(
    String key,
    String label, {
    int? sortOrder,
  }) => caller.callServerEndpoint<_i18.MarkerIconCategoryDefinition>(
    'markerIcon',
    'updateCategory',
    {
      'key': key,
      'label': label,
      'sortOrder': sortOrder,
    },
  );

  _i2.Future<bool> deleteCategory(String key) =>
      caller.callServerEndpoint<bool>(
        'markerIcon',
        'deleteCategory',
        {'key': key},
      );
}

/// {@category Endpoint}
class EndpointPmtiles extends _i1.EndpointRef {
  EndpointPmtiles(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'pmtiles';

  _i2.Future<List<_i19.PmtilesFile>> listFiles() =>
      caller.callServerEndpoint<List<_i19.PmtilesFile>>(
        'pmtiles',
        'listFiles',
        {},
      );

  _i2.Future<List<_i20.PmtilesGroup>> listGroups() =>
      caller.callServerEndpoint<List<_i20.PmtilesGroup>>(
        'pmtiles',
        'listGroups',
        {},
      );

  _i2.Future<_i20.PmtilesGroup> createGroup(String name) =>
      caller.callServerEndpoint<_i20.PmtilesGroup>(
        'pmtiles',
        'createGroup',
        {'name': name},
      );

  _i2.Future<_i20.PmtilesGroup> renameGroup(
    _i1.UuidValue id,
    String name,
  ) => caller.callServerEndpoint<_i20.PmtilesGroup>(
    'pmtiles',
    'renameGroup',
    {
      'id': id,
      'name': name,
    },
  );

  _i2.Future<bool> deleteGroup(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'pmtiles',
        'deleteGroup',
        {'id': id},
      );

  _i2.Future<void> addFileToGroup(
    _i1.UuidValue fileId,
    _i1.UuidValue groupId,
  ) => caller.callServerEndpoint<void>(
    'pmtiles',
    'addFileToGroup',
    {
      'fileId': fileId,
      'groupId': groupId,
    },
  );

  _i2.Future<void> removeFileFromGroup(
    _i1.UuidValue fileId,
    _i1.UuidValue groupId,
  ) => caller.callServerEndpoint<void>(
    'pmtiles',
    'removeFileFromGroup',
    {
      'fileId': fileId,
      'groupId': groupId,
    },
  );

  _i2.Future<void> setGroupEnabled(
    _i1.UuidValue groupId, {
    required bool enabled,
  }) => caller.callServerEndpoint<void>(
    'pmtiles',
    'setGroupEnabled',
    {
      'groupId': groupId,
      'enabled': enabled,
    },
  );

  _i2.Future<void> setUngroupedEnabled({required bool enabled}) =>
      caller.callServerEndpoint<void>(
        'pmtiles',
        'setUngroupedEnabled',
        {'enabled': enabled},
      );

  _i2.Future<_i1.UuidValue?> activeFileId() =>
      caller.callServerEndpoint<_i1.UuidValue?>(
        'pmtiles',
        'activeFileId',
        {},
      );

  /// Enables a file on the map without disabling others.
  _i2.Future<void> setActiveFile(_i1.UuidValue id) =>
      caller.callServerEndpoint<void>(
        'pmtiles',
        'setActiveFile',
        {'id': id},
      );

  _i2.Future<void> setFileEnabled(
    _i1.UuidValue id, {
    required bool enabled,
  }) => caller.callServerEndpoint<void>(
    'pmtiles',
    'setFileEnabled',
    {
      'id': id,
      'enabled': enabled,
    },
  );

  _i2.Future<void> enableAllFiles() => caller.callServerEndpoint<void>(
    'pmtiles',
    'enableAllFiles',
    {},
  );

  _i2.Future<void> clearActiveFile() => caller.callServerEndpoint<void>(
    'pmtiles',
    'clearActiveFile',
    {},
  );

  _i2.Future<void> disableAllFiles() => caller.callServerEndpoint<void>(
    'pmtiles',
    'disableAllFiles',
    {},
  );

  _i2.Future<bool> deleteFile(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'pmtiles',
        'deleteFile',
        {'id': id},
      );
}

/// {@category Endpoint}
class EndpointSeasonalOverlay extends _i1.EndpointRef {
  EndpointSeasonalOverlay(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'seasonalOverlay';

  _i2.Future<List<_i21.SeasonalOverlay>> listOverlays() =>
      caller.callServerEndpoint<List<_i21.SeasonalOverlay>>(
        'seasonalOverlay',
        'listOverlays',
        {},
      );

  _i2.Future<_i21.SeasonalOverlay?> getOverlay(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i21.SeasonalOverlay?>(
        'seasonalOverlay',
        'getOverlay',
        {'id': id},
      );

  _i2.Future<_i21.SeasonalOverlay> createOverlay(
    _i21.SeasonalOverlay overlay,
  ) => caller.callServerEndpoint<_i21.SeasonalOverlay>(
    'seasonalOverlay',
    'createOverlay',
    {'overlay': overlay},
  );

  _i2.Future<_i21.SeasonalOverlay> updateOverlay(
    _i21.SeasonalOverlay overlay,
  ) => caller.callServerEndpoint<_i21.SeasonalOverlay>(
    'seasonalOverlay',
    'updateOverlay',
    {'overlay': overlay},
  );

  _i2.Future<bool> deleteOverlay(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'seasonalOverlay',
        'deleteOverlay',
        {'id': id},
      );

  _i2.Future<List<_i21.SeasonalOverlay>> reorderOverlays(
    List<_i21.SeasonalOverlay> overlays,
  ) => caller.callServerEndpoint<List<_i21.SeasonalOverlay>>(
    'seasonalOverlay',
    'reorderOverlays',
    {'overlays': overlays},
  );

  _i2.Stream<_i22.SeasonalOverlayChange> overlayChanges() =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i22.SeasonalOverlayChange>,
        _i22.SeasonalOverlayChange
      >(
        'seasonalOverlay',
        'overlayChanges',
        {},
        {},
      );
}

/// {@category Endpoint}
class EndpointAppSettings extends _i1.EndpointRef {
  EndpointAppSettings(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'appSettings';

  _i2.Future<_i23.AppSettings> getSettings() =>
      caller.callServerEndpoint<_i23.AppSettings>(
        'appSettings',
        'getSettings',
        {},
      );

  /// Personal UI prefs for the signed-in user (or shared TOC defaults when open).
  _i2.Future<_i24.UserClientPreferences> getMyClientPreferences() =>
      caller.callServerEndpoint<_i24.UserClientPreferences>(
        'appSettings',
        'getMyClientPreferences',
        {},
      );

  /// Saves personal UI prefs for the signed-in user (any role with view_map).
  _i2.Future<_i24.UserClientPreferences> updateMyClientPreferences(
    String measurementUnits,
    String angleDisplayFormat,
    String bearingReference,
    String circleSizeDisplay,
    String appTheme,
    String appLocale,
    double mapMarkerSizeScale,
    bool mapViewportDebugBorder,
    bool mapTileBorderDebug,
    bool mapCompassRoseEnabled,
    bool mapMgrsGridEnabled,
    bool polygonSnapRightAngles,
    bool polygonSnap45Angles,
  ) => caller.callServerEndpoint<_i24.UserClientPreferences>(
    'appSettings',
    'updateMyClientPreferences',
    {
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'bearingReference': bearingReference,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'mapMarkerSizeScale': mapMarkerSizeScale,
      'mapViewportDebugBorder': mapViewportDebugBorder,
      'mapTileBorderDebug': mapTileBorderDebug,
      'mapCompassRoseEnabled': mapCompassRoseEnabled,
      'mapMgrsGridEnabled': mapMgrsGridEnabled,
      'polygonSnapRightAngles': polygonSnapRightAngles,
      'polygonSnap45Angles': polygonSnap45Angles,
    },
  );

  _i2.Future<_i23.AppSettings> updateHomeLocation(
    double latitude,
    double longitude,
    double zoom,
  ) => caller.callServerEndpoint<_i23.AppSettings>(
    'appSettings',
    'updateHomeLocation',
    {
      'latitude': latitude,
      'longitude': longitude,
      'zoom': zoom,
    },
  );

  _i2.Future<_i23.AppSettings> resetHomeLocation() =>
      caller.callServerEndpoint<_i23.AppSettings>(
        'appSettings',
        'resetHomeLocation',
        {},
      );

  _i2.Future<_i23.AppSettings> updateMapZoomRange(
    double mapMinZoom,
    double mapMaxZoom,
  ) => caller.callServerEndpoint<_i23.AppSettings>(
    'appSettings',
    'updateMapZoomRange',
    {
      'mapMinZoom': mapMinZoom,
      'mapMaxZoom': mapMaxZoom,
    },
  );

  _i2.Future<_i23.AppSettings> updatePmtilesStoragePath(String storagePath) =>
      caller.callServerEndpoint<_i23.AppSettings>(
        'appSettings',
        'updatePmtilesStoragePath',
        {'storagePath': storagePath},
      );

  _i2.Future<_i23.AppSettings> updateClientPreferences(
    String measurementUnits,
    String angleDisplayFormat,
    String bearingReference,
    String circleSizeDisplay,
    String appTheme,
    String appLocale,
    double mapMarkerSizeScale,
    bool mapViewportDebugBorder,
    bool mapTileBorderDebug,
    bool mapCompassRoseEnabled,
    bool mapMgrsGridEnabled,
    bool polygonSnapRightAngles,
    bool polygonSnap45Angles,
    double mapMinZoom,
    double mapMaxZoom,
  ) => caller.callServerEndpoint<_i23.AppSettings>(
    'appSettings',
    'updateClientPreferences',
    {
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'bearingReference': bearingReference,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'mapMarkerSizeScale': mapMarkerSizeScale,
      'mapViewportDebugBorder': mapViewportDebugBorder,
      'mapTileBorderDebug': mapTileBorderDebug,
      'mapCompassRoseEnabled': mapCompassRoseEnabled,
      'mapMgrsGridEnabled': mapMgrsGridEnabled,
      'polygonSnapRightAngles': polygonSnapRightAngles,
      'polygonSnap45Angles': polygonSnap45Angles,
      'mapMinZoom': mapMinZoom,
      'mapMaxZoom': mapMaxZoom,
    },
  );

  _i2.Future<_i25.RestApiKeyInfo> getRestApiKeyStatus() =>
      caller.callServerEndpoint<_i25.RestApiKeyInfo>(
        'appSettings',
        'getRestApiKeyStatus',
        {},
      );

  _i2.Future<List<_i26.RestApiKey>> listRestApiKeys() =>
      caller.callServerEndpoint<List<_i26.RestApiKey>>(
        'appSettings',
        'listRestApiKeys',
        {},
      );

  _i2.Future<_i27.RestApiKeyCreated> createRestApiKey(String name) =>
      caller.callServerEndpoint<_i27.RestApiKeyCreated>(
        'appSettings',
        'createRestApiKey',
        {'name': name},
      );

  _i2.Future<bool> deleteRestApiKey(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'appSettings',
        'deleteRestApiKey',
        {'id': id},
      );

  _i2.Future<_i25.RestApiKeyInfo> clearRestApiKeys() =>
      caller.callServerEndpoint<_i25.RestApiKeyInfo>(
        'appSettings',
        'clearRestApiKeys',
        {},
      );
}

/// {@category Endpoint}
class EndpointTides extends _i1.EndpointRef {
  EndpointTides(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'tides';

  _i2.Future<List<_i28.TidePackInfo>> listPacks() =>
      caller.callServerEndpoint<List<_i28.TidePackInfo>>(
        'tides',
        'listPacks',
        {},
      );

  _i2.Future<List<_i29.TideCoastalRegion>> listCoastalRegions() =>
      caller.callServerEndpoint<List<_i29.TideCoastalRegion>>(
        'tides',
        'listCoastalRegions',
        {},
      );

  _i2.Future<_i28.TidePackInfo> importCoastalRegion(String regionId) =>
      caller.callServerEndpoint<_i28.TidePackInfo>(
        'tides',
        'importCoastalRegion',
        {'regionId': regionId},
      );

  _i2.Future<_i28.TidePackInfo> setPackActive(
    String packId,
    bool active,
  ) => caller.callServerEndpoint<_i28.TidePackInfo>(
    'tides',
    'setPackActive',
    {
      'packId': packId,
      'active': active,
    },
  );

  _i2.Future<bool> deletePack(String packId) => caller.callServerEndpoint<bool>(
    'tides',
    'deletePack',
    {'packId': packId},
  );

  /// Downloads one installed pack as a `.wayfinder-tide` zip for offline use.
  _i2.Future<_i13.ByteData> exportPack(String packId) =>
      caller.callServerEndpoint<_i13.ByteData>(
        'tides',
        'exportPack',
        {'packId': packId},
      );

  /// Installs a pack from a `.wayfinder-tide` / zip archive (no NOAA required).
  _i2.Future<_i28.TidePackInfo> importPackArchive(_i13.ByteData archiveBytes) =>
      caller.callServerEndpoint<_i28.TidePackInfo>(
        'tides',
        'importPackArchive',
        {'archiveBytes': archiveBytes},
      );

  _i2.Future<_i30.TideQueryResult> queryAt(
    double lat,
    double lng,
    DateTime date, {
    required int hours,
  }) => caller.callServerEndpoint<_i30.TideQueryResult>(
    'tides',
    'queryAt',
    {
      'lat': lat,
      'lng': lng,
      'date': date,
      'hours': hours,
    },
  );
}

/// {@category Endpoint}
class EndpointWatchLog extends _i1.EndpointRef {
  EndpointWatchLog(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'watchLog';

  _i2.Future<List<_i31.WatchLogEntry>> listEntries() =>
      caller.callServerEndpoint<List<_i31.WatchLogEntry>>(
        'watchLog',
        'listEntries',
        {},
      );

  _i2.Future<_i31.WatchLogEntry?> getEntry(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i31.WatchLogEntry?>(
        'watchLog',
        'getEntry',
        {'id': id},
      );

  _i2.Future<_i31.WatchLogEntry> createEntry(_i31.WatchLogEntry entry) =>
      caller.callServerEndpoint<_i31.WatchLogEntry>(
        'watchLog',
        'createEntry',
        {'entry': entry},
      );

  _i2.Future<_i31.WatchLogEntry> updateEntry(_i31.WatchLogEntry entry) =>
      caller.callServerEndpoint<_i31.WatchLogEntry>(
        'watchLog',
        'updateEntry',
        {'entry': entry},
      );

  _i2.Future<bool> deleteEntry(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'watchLog',
        'deleteEntry',
        {'id': id},
      );

  _i2.Stream<_i32.WatchLogEntryChange> entryChanges() =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i32.WatchLogEntryChange>,
        _i32.WatchLogEntryChange
      >(
        'watchLog',
        'entryChanges',
        {},
        {},
      );
}

/// {@category Endpoint}
class EndpointMapZone extends _i1.EndpointRef {
  EndpointMapZone(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapZone';

  _i2.Future<List<_i33.MapZone>> listZones() =>
      caller.callServerEndpoint<List<_i33.MapZone>>(
        'mapZone',
        'listZones',
        {},
      );

  _i2.Future<List<_i33.MapZone>> listDeletedZones() =>
      caller.callServerEndpoint<List<_i33.MapZone>>(
        'mapZone',
        'listDeletedZones',
        {},
      );

  _i2.Future<_i33.MapZone?> getZone(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i33.MapZone?>(
        'mapZone',
        'getZone',
        {'id': id},
      );

  _i2.Future<_i33.MapZone> createZone(_i33.MapZone zone) =>
      caller.callServerEndpoint<_i33.MapZone>(
        'mapZone',
        'createZone',
        {'zone': zone},
      );

  _i2.Future<_i33.MapZone> updateZone(_i33.MapZone zone) =>
      caller.callServerEndpoint<_i33.MapZone>(
        'mapZone',
        'updateZone',
        {'zone': zone},
      );

  _i2.Future<bool> deleteZone(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapZone',
        'deleteZone',
        {'id': id},
      );

  _i2.Future<_i33.MapZone?> restoreZone(_i1.UuidValue id) =>
      caller.callServerEndpoint<_i33.MapZone?>(
        'mapZone',
        'restoreZone',
        {'id': id},
      );

  _i2.Future<bool> purgeDeletedZone(_i1.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapZone',
        'purgeDeletedZone',
        {'id': id},
      );

  _i2.Stream<_i34.MapZoneChange> zoneChanges() =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i34.MapZoneChange>,
        _i34.MapZoneChange
      >(
        'mapZone',
        'zoneChanges',
        {},
        {},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i6.Caller(client);
    serverpod_auth_core = _i7.Caller(client);
  }

  late final _i6.Caller serverpod_auth_idp;

  late final _i7.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i35.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    accessControl = EndpointAccessControl(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    category = EndpointCategory(this);
    greeting = EndpointGreeting(this);
    mapLayer = EndpointMapLayer(this);
    mapData = EndpointMapData(this);
    mapMarker = EndpointMapMarker(this);
    markerAttachment = EndpointMarkerAttachment(this);
    markerIcon = EndpointMarkerIcon(this);
    pmtiles = EndpointPmtiles(this);
    seasonalOverlay = EndpointSeasonalOverlay(this);
    appSettings = EndpointAppSettings(this);
    tides = EndpointTides(this);
    watchLog = EndpointWatchLog(this);
    mapZone = EndpointMapZone(this);
    modules = Modules(this);
  }

  late final EndpointAccessControl accessControl;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointCategory category;

  late final EndpointGreeting greeting;

  late final EndpointMapLayer mapLayer;

  late final EndpointMapData mapData;

  late final EndpointMapMarker mapMarker;

  late final EndpointMarkerAttachment markerAttachment;

  late final EndpointMarkerIcon markerIcon;

  late final EndpointPmtiles pmtiles;

  late final EndpointSeasonalOverlay seasonalOverlay;

  late final EndpointAppSettings appSettings;

  late final EndpointTides tides;

  late final EndpointWatchLog watchLog;

  late final EndpointMapZone mapZone;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'accessControl': accessControl,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'category': category,
    'greeting': greeting,
    'mapLayer': mapLayer,
    'mapData': mapData,
    'mapMarker': mapMarker,
    'markerAttachment': markerAttachment,
    'markerIcon': markerIcon,
    'pmtiles': pmtiles,
    'seasonalOverlay': seasonalOverlay,
    'appSettings': appSettings,
    'tides': tides,
    'watchLog': watchLog,
    'mapZone': mapZone,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
