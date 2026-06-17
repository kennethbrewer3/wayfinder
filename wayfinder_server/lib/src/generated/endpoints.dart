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
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../categories/category_endpoint.dart' as _i4;
import '../greetings/greeting_endpoint.dart' as _i5;
import '../layers/map_layer_endpoint.dart' as _i6;
import '../map/map_data_endpoint.dart' as _i7;
import '../map/map_marker_endpoint.dart' as _i8;
import '../pmtiles/pmtiles_endpoint.dart' as _i9;
import '../zones/map_zone_endpoint.dart' as _i10;
import 'package:wayfinder_server/src/generated/categories/category.dart'
    as _i11;
import 'package:wayfinder_server/src/generated/layers/map_layer.dart' as _i12;
import 'package:wayfinder_server/src/generated/map/map_marker.dart' as _i13;
import 'package:wayfinder_server/src/generated/zones/map_zone.dart' as _i14;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i15;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i16;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'category': _i4.CategoryEndpoint()
        ..initialize(
          server,
          'category',
          null,
        ),
      'greeting': _i5.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'mapLayer': _i6.MapLayerEndpoint()
        ..initialize(
          server,
          'mapLayer',
          null,
        ),
      'mapData': _i7.MapDataEndpoint()
        ..initialize(
          server,
          'mapData',
          null,
        ),
      'mapMarker': _i8.MapMarkerEndpoint()
        ..initialize(
          server,
          'mapMarker',
          null,
        ),
      'pmtiles': _i9.PmtilesEndpoint()
        ..initialize(
          server,
          'pmtiles',
          null,
        ),
      'mapZone': _i10.MapZoneEndpoint()
        ..initialize(
          server,
          'mapZone',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['category'] = _i1.EndpointConnector(
      name: 'category',
      endpoint: endpoints['category']!,
      methodConnectors: {
        'listCategories': _i1.MethodConnector(
          name: 'listCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i4.CategoryEndpoint)
                  .listCategories(session),
        ),
        'getCategory': _i1.MethodConnector(
          name: 'getCategory',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['category'] as _i4.CategoryEndpoint).getCategory(
                    session,
                    params['id'],
                  ),
        ),
        'createCategory': _i1.MethodConnector(
          name: 'createCategory',
          params: {
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<_i11.Category>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i4.CategoryEndpoint)
                  .createCategory(
                    session,
                    params['category'],
                  ),
        ),
        'updateCategory': _i1.MethodConnector(
          name: 'updateCategory',
          params: {
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<_i11.Category>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i4.CategoryEndpoint)
                  .updateCategory(
                    session,
                    params['category'],
                  ),
        ),
        'deleteCategory': _i1.MethodConnector(
          name: 'deleteCategory',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['category'] as _i4.CategoryEndpoint)
                  .deleteCategory(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i5.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['mapLayer'] = _i1.EndpointConnector(
      name: 'mapLayer',
      endpoint: endpoints['mapLayer']!,
      methodConnectors: {
        'listLayers': _i1.MethodConnector(
          name: 'listLayers',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapLayer'] as _i6.MapLayerEndpoint)
                  .listLayers(session),
        ),
        'getLayer': _i1.MethodConnector(
          name: 'getLayer',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i6.MapLayerEndpoint).getLayer(
                    session,
                    params['id'],
                  ),
        ),
        'createLayer': _i1.MethodConnector(
          name: 'createLayer',
          params: {
            'layer': _i1.ParameterDescription(
              name: 'layer',
              type: _i1.getType<_i12.MapLayer>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i6.MapLayerEndpoint).createLayer(
                    session,
                    params['layer'],
                  ),
        ),
        'updateLayer': _i1.MethodConnector(
          name: 'updateLayer',
          params: {
            'layer': _i1.ParameterDescription(
              name: 'layer',
              type: _i1.getType<_i12.MapLayer>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i6.MapLayerEndpoint).updateLayer(
                    session,
                    params['layer'],
                  ),
        ),
        'deleteLayer': _i1.MethodConnector(
          name: 'deleteLayer',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i6.MapLayerEndpoint).deleteLayer(
                    session,
                    params['id'],
                  ),
        ),
        'reorderLayers': _i1.MethodConnector(
          name: 'reorderLayers',
          params: {
            'layers': _i1.ParameterDescription(
              name: 'layers',
              type: _i1.getType<List<_i12.MapLayer>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i6.MapLayerEndpoint).reorderLayers(
                    session,
                    params['layers'],
                  ),
        ),
      },
    );
    connectors['mapData'] = _i1.EndpointConnector(
      name: 'mapData',
      endpoint: endpoints['mapData']!,
      methodConnectors: {
        'exportMapData': _i1.MethodConnector(
          name: 'exportMapData',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapData'] as _i7.MapDataEndpoint)
                  .exportMapData(session),
        ),
        'restoreMapData': _i1.MethodConnector(
          name: 'restoreMapData',
          params: {
            'backupJson': _i1.ParameterDescription(
              name: 'backupJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapData'] as _i7.MapDataEndpoint).restoreMapData(
                    session,
                    params['backupJson'],
                  ),
        ),
      },
    );
    connectors['mapMarker'] = _i1.EndpointConnector(
      name: 'mapMarker',
      endpoint: endpoints['mapMarker']!,
      methodConnectors: {
        'listMarkers': _i1.MethodConnector(
          name: 'listMarkers',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapMarker'] as _i8.MapMarkerEndpoint)
                  .listMarkers(session),
        ),
        'getMarker': _i1.MethodConnector(
          name: 'getMarker',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapMarker'] as _i8.MapMarkerEndpoint).getMarker(
                    session,
                    params['id'],
                  ),
        ),
        'createMarker': _i1.MethodConnector(
          name: 'createMarker',
          params: {
            'marker': _i1.ParameterDescription(
              name: 'marker',
              type: _i1.getType<_i13.MapMarker>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapMarker'] as _i8.MapMarkerEndpoint)
                  .createMarker(
                    session,
                    params['marker'],
                  ),
        ),
        'updateMarker': _i1.MethodConnector(
          name: 'updateMarker',
          params: {
            'marker': _i1.ParameterDescription(
              name: 'marker',
              type: _i1.getType<_i13.MapMarker>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapMarker'] as _i8.MapMarkerEndpoint)
                  .updateMarker(
                    session,
                    params['marker'],
                  ),
        ),
        'deleteMarker': _i1.MethodConnector(
          name: 'deleteMarker',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapMarker'] as _i8.MapMarkerEndpoint)
                  .deleteMarker(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['pmtiles'] = _i1.EndpointConnector(
      name: 'pmtiles',
      endpoint: endpoints['pmtiles']!,
      methodConnectors: {
        'listFiles': _i1.MethodConnector(
          name: 'listFiles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i9.PmtilesEndpoint)
                  .listFiles(session),
        ),
        'activeFileId': _i1.MethodConnector(
          name: 'activeFileId',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i9.PmtilesEndpoint)
                  .activeFileId(session),
        ),
        'setActiveFile': _i1.MethodConnector(
          name: 'setActiveFile',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['pmtiles'] as _i9.PmtilesEndpoint).setActiveFile(
                    session,
                    params['id'],
                  ),
        ),
        'clearActiveFile': _i1.MethodConnector(
          name: 'clearActiveFile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i9.PmtilesEndpoint)
                  .clearActiveFile(session),
        ),
        'deleteFile': _i1.MethodConnector(
          name: 'deleteFile',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['pmtiles'] as _i9.PmtilesEndpoint).deleteFile(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['mapZone'] = _i1.EndpointConnector(
      name: 'mapZone',
      endpoint: endpoints['mapZone']!,
      methodConnectors: {
        'listZones': _i1.MethodConnector(
          name: 'listZones',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapZone'] as _i10.MapZoneEndpoint)
                  .listZones(session),
        ),
        'getZone': _i1.MethodConnector(
          name: 'getZone',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapZone'] as _i10.MapZoneEndpoint).getZone(
                session,
                params['id'],
              ),
        ),
        'createZone': _i1.MethodConnector(
          name: 'createZone',
          params: {
            'zone': _i1.ParameterDescription(
              name: 'zone',
              type: _i1.getType<_i14.MapZone>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i10.MapZoneEndpoint).createZone(
                    session,
                    params['zone'],
                  ),
        ),
        'updateZone': _i1.MethodConnector(
          name: 'updateZone',
          params: {
            'zone': _i1.ParameterDescription(
              name: 'zone',
              type: _i1.getType<_i14.MapZone>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i10.MapZoneEndpoint).updateZone(
                    session,
                    params['zone'],
                  ),
        ),
        'deleteZone': _i1.MethodConnector(
          name: 'deleteZone',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i10.MapZoneEndpoint).deleteZone(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i15.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i16.Endpoints()
      ..initializeEndpoints(server);
  }
}
