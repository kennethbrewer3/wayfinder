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
import '../geocoding/geocoding_endpoint.dart' as _i5;
import '../greetings/greeting_endpoint.dart' as _i6;
import '../layers/map_layer_endpoint.dart' as _i7;
import '../map/map_data_endpoint.dart' as _i8;
import '../map/map_marker_endpoint.dart' as _i9;
import '../pmtiles/pmtiles_endpoint.dart' as _i10;
import '../settings/app_settings_endpoint.dart' as _i11;
import '../zones/map_zone_endpoint.dart' as _i12;
import 'package:wayfinder_server/src/generated/categories/category.dart'
    as _i13;
import 'package:wayfinder_server/src/generated/layers/map_layer.dart' as _i14;
import 'package:wayfinder_server/src/generated/map/map_marker.dart' as _i15;
import 'package:wayfinder_server/src/generated/zones/map_zone.dart' as _i16;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i17;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i18;

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
      'geocoding': _i5.GeocodingEndpoint()
        ..initialize(
          server,
          'geocoding',
          null,
        ),
      'greeting': _i6.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'mapLayer': _i7.MapLayerEndpoint()
        ..initialize(
          server,
          'mapLayer',
          null,
        ),
      'mapData': _i8.MapDataEndpoint()
        ..initialize(
          server,
          'mapData',
          null,
        ),
      'mapMarker': _i9.MapMarkerEndpoint()
        ..initialize(
          server,
          'mapMarker',
          null,
        ),
      'pmtiles': _i10.PmtilesEndpoint()
        ..initialize(
          server,
          'pmtiles',
          null,
        ),
      'appSettings': _i11.AppSettingsEndpoint()
        ..initialize(
          server,
          'appSettings',
          null,
        ),
      'mapZone': _i12.MapZoneEndpoint()
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
              type: _i1.getType<_i13.Category>(),
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
              type: _i1.getType<_i13.Category>(),
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
    connectors['geocoding'] = _i1.EndpointConnector(
      name: 'geocoding',
      endpoint: endpoints['geocoding']!,
      methodConnectors: {
        'getSettings': _i1.MethodConnector(
          name: 'getSettings',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .getSettings(session),
        ),
        'updateSourceUrl': _i1.MethodConnector(
          name: 'updateSourceUrl',
          params: {
            'sourceUrl': _i1.ParameterDescription(
              name: 'sourceUrl',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'countryCodes': _i1.ParameterDescription(
              name: 'countryCodes',
              type: _i1.getType<List<String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .updateSourceUrl(
                    session,
                    params['sourceUrl'],
                    countryCodes: params['countryCodes'],
                  ),
        ),
        'startImport': _i1.MethodConnector(
          name: 'startImport',
          params: {
            'sourceUrl': _i1.ParameterDescription(
              name: 'sourceUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'countryCodes': _i1.ParameterDescription(
              name: 'countryCodes',
              type: _i1.getType<List<String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['geocoding'] as _i5.GeocodingEndpoint).startImport(
                    session,
                    sourceUrl: params['sourceUrl'],
                    countryCodes: params['countryCodes'],
                  ),
        ),
        'startHousenumbersImport': _i1.MethodConnector(
          name: 'startHousenumbersImport',
          params: {
            'sourceUrl': _i1.ParameterDescription(
              name: 'sourceUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .startHousenumbersImport(
                    session,
                    sourceUrl: params['sourceUrl'],
                  ),
        ),
        'cancelImport': _i1.MethodConnector(
          name: 'cancelImport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .cancelImport(session),
        ),
        'cancelHousenumbersImport': _i1.MethodConnector(
          name: 'cancelHousenumbersImport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .cancelHousenumbersImport(session),
        ),
        'searchPlaces': _i1.MethodConnector(
          name: 'searchPlaces',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .searchPlaces(
                    session,
                    params['query'],
                  ),
        ),
        'isSearchReady': _i1.MethodConnector(
          name: 'isSearchReady',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .isSearchReady(session),
        ),
        'exportPlacesArchive': _i1.MethodConnector(
          name: 'exportPlacesArchive',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .exportPlacesArchive(session),
        ),
        'exportHousenumbersArchive': _i1.MethodConnector(
          name: 'exportHousenumbersArchive',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .exportHousenumbersArchive(session),
        ),
        'importPlacesArchive': _i1.MethodConnector(
          name: 'importPlacesArchive',
          params: {
            'archiveJson': _i1.ParameterDescription(
              name: 'archiveJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .importPlacesArchive(
                    session,
                    params['archiveJson'],
                  ),
        ),
        'importHousenumbersArchive': _i1.MethodConnector(
          name: 'importHousenumbersArchive',
          params: {
            'archiveJson': _i1.ParameterDescription(
              name: 'archiveJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .importHousenumbersArchive(
                    session,
                    params['archiveJson'],
                  ),
        ),
        'clearPlaces': _i1.MethodConnector(
          name: 'clearPlaces',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .clearPlaces(session),
        ),
        'clearHousenumbers': _i1.MethodConnector(
          name: 'clearHousenumbers',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i5.GeocodingEndpoint)
                  .clearHousenumbers(session),
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
              ) async => (endpoints['greeting'] as _i6.GreetingEndpoint).hello(
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
              ) async => (endpoints['mapLayer'] as _i7.MapLayerEndpoint)
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
                  (endpoints['mapLayer'] as _i7.MapLayerEndpoint).getLayer(
                    session,
                    params['id'],
                  ),
        ),
        'createLayer': _i1.MethodConnector(
          name: 'createLayer',
          params: {
            'layer': _i1.ParameterDescription(
              name: 'layer',
              type: _i1.getType<_i14.MapLayer>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i7.MapLayerEndpoint).createLayer(
                    session,
                    params['layer'],
                  ),
        ),
        'updateLayer': _i1.MethodConnector(
          name: 'updateLayer',
          params: {
            'layer': _i1.ParameterDescription(
              name: 'layer',
              type: _i1.getType<_i14.MapLayer>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i7.MapLayerEndpoint).updateLayer(
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
                  (endpoints['mapLayer'] as _i7.MapLayerEndpoint).deleteLayer(
                    session,
                    params['id'],
                  ),
        ),
        'reorderLayers': _i1.MethodConnector(
          name: 'reorderLayers',
          params: {
            'layers': _i1.ParameterDescription(
              name: 'layers',
              type: _i1.getType<List<_i14.MapLayer>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapLayer'] as _i7.MapLayerEndpoint).reorderLayers(
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
              ) async => (endpoints['mapData'] as _i8.MapDataEndpoint)
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
                  (endpoints['mapData'] as _i8.MapDataEndpoint).restoreMapData(
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
              ) async => (endpoints['mapMarker'] as _i9.MapMarkerEndpoint)
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
                  (endpoints['mapMarker'] as _i9.MapMarkerEndpoint).getMarker(
                    session,
                    params['id'],
                  ),
        ),
        'createMarker': _i1.MethodConnector(
          name: 'createMarker',
          params: {
            'marker': _i1.ParameterDescription(
              name: 'marker',
              type: _i1.getType<_i15.MapMarker>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapMarker'] as _i9.MapMarkerEndpoint)
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
              type: _i1.getType<_i15.MapMarker>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapMarker'] as _i9.MapMarkerEndpoint)
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
              ) async => (endpoints['mapMarker'] as _i9.MapMarkerEndpoint)
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
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .listFiles(session),
        ),
        'listGroups': _i1.MethodConnector(
          name: 'listGroups',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .listGroups(session),
        ),
        'createGroup': _i1.MethodConnector(
          name: 'createGroup',
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
              ) async =>
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).createGroup(
                    session,
                    params['name'],
                  ),
        ),
        'renameGroup': _i1.MethodConnector(
          name: 'renameGroup',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
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
              ) async =>
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).renameGroup(
                    session,
                    params['id'],
                    params['name'],
                  ),
        ),
        'deleteGroup': _i1.MethodConnector(
          name: 'deleteGroup',
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
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).deleteGroup(
                    session,
                    params['id'],
                  ),
        ),
        'setFileGroup': _i1.MethodConnector(
          name: 'setFileGroup',
          params: {
            'fileId': _i1.ParameterDescription(
              name: 'fileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).setFileGroup(
                    session,
                    params['fileId'],
                    params['groupId'],
                  ),
        ),
        'setGroupEnabled': _i1.MethodConnector(
          name: 'setGroupEnabled',
          params: {
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'enabled': _i1.ParameterDescription(
              name: 'enabled',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .setGroupEnabled(
                    session,
                    params['groupId'],
                    enabled: params['enabled'],
                  ),
        ),
        'setUngroupedEnabled': _i1.MethodConnector(
          name: 'setUngroupedEnabled',
          params: {
            'enabled': _i1.ParameterDescription(
              name: 'enabled',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .setUngroupedEnabled(
                    session,
                    enabled: params['enabled'],
                  ),
        ),
        'activeFileId': _i1.MethodConnector(
          name: 'activeFileId',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
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
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).setActiveFile(
                    session,
                    params['id'],
                  ),
        ),
        'setFileEnabled': _i1.MethodConnector(
          name: 'setFileEnabled',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'enabled': _i1.ParameterDescription(
              name: 'enabled',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).setFileEnabled(
                    session,
                    params['id'],
                    enabled: params['enabled'],
                  ),
        ),
        'enableAllFiles': _i1.MethodConnector(
          name: 'enableAllFiles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .enableAllFiles(session),
        ),
        'clearActiveFile': _i1.MethodConnector(
          name: 'clearActiveFile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .clearActiveFile(session),
        ),
        'disableAllFiles': _i1.MethodConnector(
          name: 'disableAllFiles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i10.PmtilesEndpoint)
                  .disableAllFiles(session),
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
                  (endpoints['pmtiles'] as _i10.PmtilesEndpoint).deleteFile(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['appSettings'] = _i1.EndpointConnector(
      name: 'appSettings',
      endpoint: endpoints['appSettings']!,
      methodConnectors: {
        'getSettings': _i1.MethodConnector(
          name: 'getSettings',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i11.AppSettingsEndpoint)
                  .getSettings(session),
        ),
        'updateHomeLocation': _i1.MethodConnector(
          name: 'updateHomeLocation',
          params: {
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'zoom': _i1.ParameterDescription(
              name: 'zoom',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i11.AppSettingsEndpoint)
                  .updateHomeLocation(
                    session,
                    params['latitude'],
                    params['longitude'],
                    params['zoom'],
                  ),
        ),
        'resetHomeLocation': _i1.MethodConnector(
          name: 'resetHomeLocation',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i11.AppSettingsEndpoint)
                  .resetHomeLocation(session),
        ),
        'updatePmtilesStoragePath': _i1.MethodConnector(
          name: 'updatePmtilesStoragePath',
          params: {
            'storagePath': _i1.ParameterDescription(
              name: 'storagePath',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i11.AppSettingsEndpoint)
                  .updatePmtilesStoragePath(
                    session,
                    params['storagePath'],
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
              ) async => (endpoints['mapZone'] as _i12.MapZoneEndpoint)
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
              ) async => (endpoints['mapZone'] as _i12.MapZoneEndpoint).getZone(
                session,
                params['id'],
              ),
        ),
        'createZone': _i1.MethodConnector(
          name: 'createZone',
          params: {
            'zone': _i1.ParameterDescription(
              name: 'zone',
              type: _i1.getType<_i16.MapZone>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i12.MapZoneEndpoint).createZone(
                    session,
                    params['zone'],
                  ),
        ),
        'updateZone': _i1.MethodConnector(
          name: 'updateZone',
          params: {
            'zone': _i1.ParameterDescription(
              name: 'zone',
              type: _i1.getType<_i16.MapZone>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i12.MapZoneEndpoint).updateZone(
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
                  (endpoints['mapZone'] as _i12.MapZoneEndpoint).deleteZone(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i17.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i18.Endpoints()
      ..initializeEndpoints(server);
  }
}
