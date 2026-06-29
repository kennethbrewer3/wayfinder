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
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:wayfinder_client/src/protocol/categories/category.dart' as _i5;
import 'package:wayfinder_client/src/protocol/greetings/greeting.dart' as _i6;
import 'package:wayfinder_client/src/protocol/layers/map_layer.dart' as _i7;
import 'package:wayfinder_client/src/protocol/map/map_data_restore_summary.dart'
    as _i8;
import 'package:wayfinder_client/src/protocol/map/map_marker.dart' as _i9;
import 'package:wayfinder_client/src/protocol/map/map_marker_change.dart'
    as _i10;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_file.dart'
    as _i11;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_group.dart'
    as _i12;
import 'package:wayfinder_client/src/protocol/settings/app_settings.dart'
    as _i13;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key_info.dart'
    as _i14;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key.dart'
    as _i15;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key_created.dart'
    as _i16;
import 'package:wayfinder_client/src/protocol/zones/map_zone.dart' as _i17;
import 'protocol.dart' as _i18;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

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
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
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
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
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
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
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
  _i3.Future<void> finishPasswordReset({
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
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

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
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointCategory extends _i2.EndpointRef {
  EndpointCategory(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'category';

  _i3.Future<List<_i5.Category>> listCategories() =>
      caller.callServerEndpoint<List<_i5.Category>>(
        'category',
        'listCategories',
        {},
      );

  _i3.Future<_i5.Category?> getCategory(_i2.UuidValue id) =>
      caller.callServerEndpoint<_i5.Category?>(
        'category',
        'getCategory',
        {'id': id},
      );

  _i3.Future<_i5.Category> createCategory(_i5.Category category) =>
      caller.callServerEndpoint<_i5.Category>(
        'category',
        'createCategory',
        {'category': category},
      );

  _i3.Future<_i5.Category> updateCategory(_i5.Category category) =>
      caller.callServerEndpoint<_i5.Category>(
        'category',
        'updateCategory',
        {'category': category},
      );

  _i3.Future<bool> deleteCategory(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'category',
        'deleteCategory',
        {'id': id},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i6.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i6.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// {@category Endpoint}
class EndpointMapLayer extends _i2.EndpointRef {
  EndpointMapLayer(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapLayer';

  _i3.Future<List<_i7.MapLayer>> listLayers() =>
      caller.callServerEndpoint<List<_i7.MapLayer>>(
        'mapLayer',
        'listLayers',
        {},
      );

  _i3.Future<_i7.MapLayer?> getLayer(_i2.UuidValue id) =>
      caller.callServerEndpoint<_i7.MapLayer?>(
        'mapLayer',
        'getLayer',
        {'id': id},
      );

  _i3.Future<_i7.MapLayer> createLayer(_i7.MapLayer layer) =>
      caller.callServerEndpoint<_i7.MapLayer>(
        'mapLayer',
        'createLayer',
        {'layer': layer},
      );

  _i3.Future<_i7.MapLayer> updateLayer(_i7.MapLayer layer) =>
      caller.callServerEndpoint<_i7.MapLayer>(
        'mapLayer',
        'updateLayer',
        {'layer': layer},
      );

  _i3.Future<bool> deleteLayer(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapLayer',
        'deleteLayer',
        {'id': id},
      );

  _i3.Future<List<_i7.MapLayer>> reorderLayers(List<_i7.MapLayer> layers) =>
      caller.callServerEndpoint<List<_i7.MapLayer>>(
        'mapLayer',
        'reorderLayers',
        {'layers': layers},
      );
}

/// {@category Endpoint}
class EndpointMapData extends _i2.EndpointRef {
  EndpointMapData(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapData';

  _i3.Future<String> exportMapData() => caller.callServerEndpoint<String>(
    'mapData',
    'exportMapData',
    {},
  );

  _i3.Future<_i8.MapDataRestoreSummary> restoreMapData(String backupJson) =>
      caller.callServerEndpoint<_i8.MapDataRestoreSummary>(
        'mapData',
        'restoreMapData',
        {'backupJson': backupJson},
      );
}

/// {@category Endpoint}
class EndpointMapMarker extends _i2.EndpointRef {
  EndpointMapMarker(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapMarker';

  _i3.Future<List<_i9.MapMarker>> listMarkers() =>
      caller.callServerEndpoint<List<_i9.MapMarker>>(
        'mapMarker',
        'listMarkers',
        {},
      );

  _i3.Future<_i9.MapMarker?> getMarker(_i2.UuidValue id) =>
      caller.callServerEndpoint<_i9.MapMarker?>(
        'mapMarker',
        'getMarker',
        {'id': id},
      );

  _i3.Future<_i9.MapMarker> createMarker(_i9.MapMarker marker) =>
      caller.callServerEndpoint<_i9.MapMarker>(
        'mapMarker',
        'createMarker',
        {'marker': marker},
      );

  _i3.Future<_i9.MapMarker> updateMarker(_i9.MapMarker marker) =>
      caller.callServerEndpoint<_i9.MapMarker>(
        'mapMarker',
        'updateMarker',
        {'marker': marker},
      );

  _i3.Future<bool> deleteMarker(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapMarker',
        'deleteMarker',
        {'id': id},
      );

  _i3.Stream<_i10.MapMarkerChange> markerChanges() =>
      caller.callStreamingServerEndpoint<
        _i3.Stream<_i10.MapMarkerChange>,
        _i10.MapMarkerChange
      >(
        'mapMarker',
        'markerChanges',
        {},
        {},
      );
}

/// {@category Endpoint}
class EndpointPmtiles extends _i2.EndpointRef {
  EndpointPmtiles(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'pmtiles';

  _i3.Future<List<_i11.PmtilesFile>> listFiles() =>
      caller.callServerEndpoint<List<_i11.PmtilesFile>>(
        'pmtiles',
        'listFiles',
        {},
      );

  _i3.Future<List<_i12.PmtilesGroup>> listGroups() =>
      caller.callServerEndpoint<List<_i12.PmtilesGroup>>(
        'pmtiles',
        'listGroups',
        {},
      );

  _i3.Future<_i12.PmtilesGroup> createGroup(String name) =>
      caller.callServerEndpoint<_i12.PmtilesGroup>(
        'pmtiles',
        'createGroup',
        {'name': name},
      );

  _i3.Future<_i12.PmtilesGroup> renameGroup(
    _i2.UuidValue id,
    String name,
  ) => caller.callServerEndpoint<_i12.PmtilesGroup>(
    'pmtiles',
    'renameGroup',
    {
      'id': id,
      'name': name,
    },
  );

  _i3.Future<bool> deleteGroup(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'pmtiles',
        'deleteGroup',
        {'id': id},
      );

  _i3.Future<void> addFileToGroup(
    _i2.UuidValue fileId,
    _i2.UuidValue groupId,
  ) => caller.callServerEndpoint<void>(
    'pmtiles',
    'addFileToGroup',
    {
      'fileId': fileId,
      'groupId': groupId,
    },
  );

  _i3.Future<void> removeFileFromGroup(
    _i2.UuidValue fileId,
    _i2.UuidValue groupId,
  ) => caller.callServerEndpoint<void>(
    'pmtiles',
    'removeFileFromGroup',
    {
      'fileId': fileId,
      'groupId': groupId,
    },
  );

  _i3.Future<void> setGroupEnabled(
    _i2.UuidValue groupId, {
    required bool enabled,
  }) => caller.callServerEndpoint<void>(
    'pmtiles',
    'setGroupEnabled',
    {
      'groupId': groupId,
      'enabled': enabled,
    },
  );

  _i3.Future<void> setUngroupedEnabled({required bool enabled}) =>
      caller.callServerEndpoint<void>(
        'pmtiles',
        'setUngroupedEnabled',
        {'enabled': enabled},
      );

  _i3.Future<_i2.UuidValue?> activeFileId() =>
      caller.callServerEndpoint<_i2.UuidValue?>(
        'pmtiles',
        'activeFileId',
        {},
      );

  /// Enables a file on the map without disabling others.
  _i3.Future<void> setActiveFile(_i2.UuidValue id) =>
      caller.callServerEndpoint<void>(
        'pmtiles',
        'setActiveFile',
        {'id': id},
      );

  _i3.Future<void> setFileEnabled(
    _i2.UuidValue id, {
    required bool enabled,
  }) => caller.callServerEndpoint<void>(
    'pmtiles',
    'setFileEnabled',
    {
      'id': id,
      'enabled': enabled,
    },
  );

  _i3.Future<void> enableAllFiles() => caller.callServerEndpoint<void>(
    'pmtiles',
    'enableAllFiles',
    {},
  );

  _i3.Future<void> clearActiveFile() => caller.callServerEndpoint<void>(
    'pmtiles',
    'clearActiveFile',
    {},
  );

  _i3.Future<void> disableAllFiles() => caller.callServerEndpoint<void>(
    'pmtiles',
    'disableAllFiles',
    {},
  );

  _i3.Future<bool> deleteFile(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'pmtiles',
        'deleteFile',
        {'id': id},
      );
}

/// {@category Endpoint}
class EndpointAppSettings extends _i2.EndpointRef {
  EndpointAppSettings(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'appSettings';

  _i3.Future<_i13.AppSettings> getSettings() =>
      caller.callServerEndpoint<_i13.AppSettings>(
        'appSettings',
        'getSettings',
        {},
      );

  _i3.Future<_i13.AppSettings> updateHomeLocation(
    double latitude,
    double longitude,
    double zoom,
  ) => caller.callServerEndpoint<_i13.AppSettings>(
    'appSettings',
    'updateHomeLocation',
    {
      'latitude': latitude,
      'longitude': longitude,
      'zoom': zoom,
    },
  );

  _i3.Future<_i13.AppSettings> resetHomeLocation() =>
      caller.callServerEndpoint<_i13.AppSettings>(
        'appSettings',
        'resetHomeLocation',
        {},
      );

  _i3.Future<_i13.AppSettings> updatePmtilesStoragePath(String storagePath) =>
      caller.callServerEndpoint<_i13.AppSettings>(
        'appSettings',
        'updatePmtilesStoragePath',
        {'storagePath': storagePath},
      );

  _i3.Future<_i13.AppSettings> updateClientPreferences(
    String measurementUnits,
    String angleDisplayFormat,
    String circleSizeDisplay,
    String appTheme,
    String appLocale,
  ) => caller.callServerEndpoint<_i13.AppSettings>(
    'appSettings',
    'updateClientPreferences',
    {
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
    },
  );

  _i3.Future<_i14.RestApiKeyInfo> getRestApiKeyStatus() =>
      caller.callServerEndpoint<_i14.RestApiKeyInfo>(
        'appSettings',
        'getRestApiKeyStatus',
        {},
      );

  _i3.Future<List<_i15.RestApiKey>> listRestApiKeys() =>
      caller.callServerEndpoint<List<_i15.RestApiKey>>(
        'appSettings',
        'listRestApiKeys',
        {},
      );

  _i3.Future<_i16.RestApiKeyCreated> createRestApiKey(String name) =>
      caller.callServerEndpoint<_i16.RestApiKeyCreated>(
        'appSettings',
        'createRestApiKey',
        {'name': name},
      );

  _i3.Future<bool> deleteRestApiKey(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'appSettings',
        'deleteRestApiKey',
        {'id': id},
      );

  _i3.Future<_i14.RestApiKeyInfo> clearRestApiKeys() =>
      caller.callServerEndpoint<_i14.RestApiKeyInfo>(
        'appSettings',
        'clearRestApiKeys',
        {},
      );
}

/// {@category Endpoint}
class EndpointMapZone extends _i2.EndpointRef {
  EndpointMapZone(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mapZone';

  _i3.Future<List<_i17.MapZone>> listZones() =>
      caller.callServerEndpoint<List<_i17.MapZone>>(
        'mapZone',
        'listZones',
        {},
      );

  _i3.Future<_i17.MapZone?> getZone(_i2.UuidValue id) =>
      caller.callServerEndpoint<_i17.MapZone?>(
        'mapZone',
        'getZone',
        {'id': id},
      );

  _i3.Future<_i17.MapZone> createZone(_i17.MapZone zone) =>
      caller.callServerEndpoint<_i17.MapZone>(
        'mapZone',
        'createZone',
        {'zone': zone},
      );

  _i3.Future<_i17.MapZone> updateZone(_i17.MapZone zone) =>
      caller.callServerEndpoint<_i17.MapZone>(
        'mapZone',
        'updateZone',
        {'zone': zone},
      );

  _i3.Future<bool> deleteZone(_i2.UuidValue id) =>
      caller.callServerEndpoint<bool>(
        'mapZone',
        'deleteZone',
        {'id': id},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
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
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i18.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    category = EndpointCategory(this);
    greeting = EndpointGreeting(this);
    mapLayer = EndpointMapLayer(this);
    mapData = EndpointMapData(this);
    mapMarker = EndpointMapMarker(this);
    pmtiles = EndpointPmtiles(this);
    appSettings = EndpointAppSettings(this);
    mapZone = EndpointMapZone(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointCategory category;

  late final EndpointGreeting greeting;

  late final EndpointMapLayer mapLayer;

  late final EndpointMapData mapData;

  late final EndpointMapMarker mapMarker;

  late final EndpointPmtiles pmtiles;

  late final EndpointAppSettings appSettings;

  late final EndpointMapZone mapZone;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'category': category,
    'greeting': greeting,
    'mapLayer': mapLayer,
    'mapData': mapData,
    'mapMarker': mapMarker,
    'pmtiles': pmtiles,
    'appSettings': appSettings,
    'mapZone': mapZone,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
