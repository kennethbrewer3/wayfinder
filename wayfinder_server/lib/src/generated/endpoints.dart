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
import '../markers/marker_attachment_endpoint.dart' as _i9;
import '../markers/marker_icon_endpoint.dart' as _i10;
import '../pmtiles/pmtiles_endpoint.dart' as _i11;
import '../seasonal_overlays/seasonal_overlay_endpoint.dart' as _i12;
import '../settings/app_settings_endpoint.dart' as _i13;
import '../tides/tides_endpoint.dart' as _i14;
import '../watch_log/watch_log_endpoint.dart' as _i15;
import '../zones/map_zone_endpoint.dart' as _i16;
import 'package:wayfinder_server/src/generated/categories/category.dart'
    as _i17;
import 'package:wayfinder_server/src/generated/layers/map_layer.dart' as _i18;
import 'dart:typed_data' as _i19;
import 'package:wayfinder_server/src/generated/map/map_marker.dart' as _i20;
import 'package:wayfinder_server/src/generated/seasonal_overlays/seasonal_overlay.dart'
    as _i21;
import 'package:wayfinder_server/src/generated/watch_log/watch_log_entry.dart'
    as _i22;
import 'package:wayfinder_server/src/generated/zones/map_zone.dart' as _i23;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i24;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i25;

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
      'markerAttachment': _i9.MarkerAttachmentEndpoint()
        ..initialize(
          server,
          'markerAttachment',
          null,
        ),
      'markerIcon': _i10.MarkerIconEndpoint()
        ..initialize(
          server,
          'markerIcon',
          null,
        ),
      'pmtiles': _i11.PmtilesEndpoint()
        ..initialize(
          server,
          'pmtiles',
          null,
        ),
      'seasonalOverlay': _i12.SeasonalOverlayEndpoint()
        ..initialize(
          server,
          'seasonalOverlay',
          null,
        ),
      'appSettings': _i13.AppSettingsEndpoint()
        ..initialize(
          server,
          'appSettings',
          null,
        ),
      'tides': _i14.TidesEndpoint()
        ..initialize(
          server,
          'tides',
          null,
        ),
      'watchLog': _i15.WatchLogEndpoint()
        ..initialize(
          server,
          'watchLog',
          null,
        ),
      'mapZone': _i16.MapZoneEndpoint()
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
              type: _i1.getType<_i17.Category>(),
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
              type: _i1.getType<_i17.Category>(),
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
              type: _i1.getType<_i18.MapLayer>(),
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
              type: _i1.getType<_i18.MapLayer>(),
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
              type: _i1.getType<List<_i18.MapLayer>>(),
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
        'layerChanges': _i1.MethodStreamConnector(
          name: 'layerChanges',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['mapLayer'] as _i6.MapLayerEndpoint).layerChanges(
                session,
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
        'exportMapDataArchive': _i1.MethodConnector(
          name: 'exportMapDataArchive',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapData'] as _i7.MapDataEndpoint)
                  .exportMapDataArchive(session),
        ),
        'restoreMapDataArchive': _i1.MethodConnector(
          name: 'restoreMapDataArchive',
          params: {
            'archiveBytes': _i1.ParameterDescription(
              name: 'archiveBytes',
              type: _i1.getType<_i19.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['mapData'] as _i7.MapDataEndpoint)
                  .restoreMapDataArchive(
                    session,
                    params['archiveBytes'],
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
              type: _i1.getType<_i20.MapMarker>(),
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
              type: _i1.getType<_i20.MapMarker>(),
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
        'markerChanges': _i1.MethodStreamConnector(
          name: 'markerChanges',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['mapMarker'] as _i8.MapMarkerEndpoint)
                  .markerChanges(session),
        ),
      },
    );
    connectors['markerAttachment'] = _i1.EndpointConnector(
      name: 'markerAttachment',
      endpoint: endpoints['markerAttachment']!,
      methodConnectors: {
        'listForMarker': _i1.MethodConnector(
          name: 'listForMarker',
          params: {
            'markerId': _i1.ParameterDescription(
              name: 'markerId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['markerAttachment']
                          as _i9.MarkerAttachmentEndpoint)
                      .listForMarker(
                        session,
                        params['markerId'],
                      ),
        ),
        'deleteAttachment': _i1.MethodConnector(
          name: 'deleteAttachment',
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
                  (endpoints['markerAttachment']
                          as _i9.MarkerAttachmentEndpoint)
                      .deleteAttachment(
                        session,
                        params['id'],
                      ),
        ),
      },
    );
    connectors['markerIcon'] = _i1.EndpointConnector(
      name: 'markerIcon',
      endpoint: endpoints['markerIcon']!,
      methodConnectors: {
        'listCatalog': _i1.MethodConnector(
          name: 'listCatalog',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .listCatalog(session),
        ),
        'createIcon': _i1.MethodConnector(
          name: 'createIcon',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'iconBackgroundColor': _i1.ParameterDescription(
              name: 'iconBackgroundColor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'materialIcon': _i1.ParameterDescription(
              name: 'materialIcon',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'coloredAsset': _i1.ParameterDescription(
              name: 'coloredAsset',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'glyphScale': _i1.ParameterDescription(
              name: 'glyphScale',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .createIcon(
                    session,
                    params['key'],
                    params['label'],
                    category: params['category'],
                    iconBackgroundColor: params['iconBackgroundColor'],
                    materialIcon: params['materialIcon'],
                    coloredAsset: params['coloredAsset'],
                    glyphScale: params['glyphScale'],
                    sortOrder: params['sortOrder'],
                  ),
        ),
        'updateIcon': _i1.MethodConnector(
          name: 'updateIcon',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'iconBackgroundColor': _i1.ParameterDescription(
              name: 'iconBackgroundColor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'materialIcon': _i1.ParameterDescription(
              name: 'materialIcon',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'coloredAsset': _i1.ParameterDescription(
              name: 'coloredAsset',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
            'glyphScale': _i1.ParameterDescription(
              name: 'glyphScale',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .updateIcon(
                    session,
                    params['key'],
                    params['label'],
                    category: params['category'],
                    iconBackgroundColor: params['iconBackgroundColor'],
                    materialIcon: params['materialIcon'],
                    coloredAsset: params['coloredAsset'],
                    glyphScale: params['glyphScale'],
                    sortOrder: params['sortOrder'],
                  ),
        ),
        'deleteIcon': _i1.MethodConnector(
          name: 'deleteIcon',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .deleteIcon(
                    session,
                    params['key'],
                  ),
        ),
        'listCategories': _i1.MethodConnector(
          name: 'listCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .listCategories(session),
        ),
        'createCategory': _i1.MethodConnector(
          name: 'createCategory',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .createCategory(
                    session,
                    params['key'],
                    params['label'],
                    sortOrder: params['sortOrder'],
                  ),
        ),
        'updateCategory': _i1.MethodConnector(
          name: 'updateCategory',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .updateCategory(
                    session,
                    params['key'],
                    params['label'],
                    sortOrder: params['sortOrder'],
                  ),
        ),
        'deleteCategory': _i1.MethodConnector(
          name: 'deleteCategory',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['markerIcon'] as _i10.MarkerIconEndpoint)
                  .deleteCategory(
                    session,
                    params['key'],
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
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
                  .listFiles(session),
        ),
        'listGroups': _i1.MethodConnector(
          name: 'listGroups',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
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
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).createGroup(
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
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).renameGroup(
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
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).deleteGroup(
                    session,
                    params['id'],
                  ),
        ),
        'addFileToGroup': _i1.MethodConnector(
          name: 'addFileToGroup',
          params: {
            'fileId': _i1.ParameterDescription(
              name: 'fileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).addFileToGroup(
                    session,
                    params['fileId'],
                    params['groupId'],
                  ),
        ),
        'removeFileFromGroup': _i1.MethodConnector(
          name: 'removeFileFromGroup',
          params: {
            'fileId': _i1.ParameterDescription(
              name: 'fileId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
                  .removeFileFromGroup(
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
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
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
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
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
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
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
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).setActiveFile(
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
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).setFileEnabled(
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
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
                  .enableAllFiles(session),
        ),
        'clearActiveFile': _i1.MethodConnector(
          name: 'clearActiveFile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
                  .clearActiveFile(session),
        ),
        'disableAllFiles': _i1.MethodConnector(
          name: 'disableAllFiles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pmtiles'] as _i11.PmtilesEndpoint)
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
                  (endpoints['pmtiles'] as _i11.PmtilesEndpoint).deleteFile(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['seasonalOverlay'] = _i1.EndpointConnector(
      name: 'seasonalOverlay',
      endpoint: endpoints['seasonalOverlay']!,
      methodConnectors: {
        'listOverlays': _i1.MethodConnector(
          name: 'listOverlays',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .listOverlays(session),
        ),
        'getOverlay': _i1.MethodConnector(
          name: 'getOverlay',
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
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .getOverlay(
                        session,
                        params['id'],
                      ),
        ),
        'createOverlay': _i1.MethodConnector(
          name: 'createOverlay',
          params: {
            'overlay': _i1.ParameterDescription(
              name: 'overlay',
              type: _i1.getType<_i21.SeasonalOverlay>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .createOverlay(
                        session,
                        params['overlay'],
                      ),
        ),
        'updateOverlay': _i1.MethodConnector(
          name: 'updateOverlay',
          params: {
            'overlay': _i1.ParameterDescription(
              name: 'overlay',
              type: _i1.getType<_i21.SeasonalOverlay>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .updateOverlay(
                        session,
                        params['overlay'],
                      ),
        ),
        'deleteOverlay': _i1.MethodConnector(
          name: 'deleteOverlay',
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
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .deleteOverlay(
                        session,
                        params['id'],
                      ),
        ),
        'reorderOverlays': _i1.MethodConnector(
          name: 'reorderOverlays',
          params: {
            'overlays': _i1.ParameterDescription(
              name: 'overlays',
              type: _i1.getType<List<_i21.SeasonalOverlay>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .reorderOverlays(
                        session,
                        params['overlays'],
                      ),
        ),
        'overlayChanges': _i1.MethodStreamConnector(
          name: 'overlayChanges',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) =>
                  (endpoints['seasonalOverlay'] as _i12.SeasonalOverlayEndpoint)
                      .overlayChanges(session),
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
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
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
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
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
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
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
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .updatePmtilesStoragePath(
                    session,
                    params['storagePath'],
                  ),
        ),
        'updateClientPreferences': _i1.MethodConnector(
          name: 'updateClientPreferences',
          params: {
            'measurementUnits': _i1.ParameterDescription(
              name: 'measurementUnits',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'angleDisplayFormat': _i1.ParameterDescription(
              name: 'angleDisplayFormat',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bearingReference': _i1.ParameterDescription(
              name: 'bearingReference',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'circleSizeDisplay': _i1.ParameterDescription(
              name: 'circleSizeDisplay',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'appTheme': _i1.ParameterDescription(
              name: 'appTheme',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'appLocale': _i1.ParameterDescription(
              name: 'appLocale',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mapMarkerSizeScale': _i1.ParameterDescription(
              name: 'mapMarkerSizeScale',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'mapViewportDebugBorder': _i1.ParameterDescription(
              name: 'mapViewportDebugBorder',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'mapTileBorderDebug': _i1.ParameterDescription(
              name: 'mapTileBorderDebug',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'mapCompassRoseEnabled': _i1.ParameterDescription(
              name: 'mapCompassRoseEnabled',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'mapMgrsGridEnabled': _i1.ParameterDescription(
              name: 'mapMgrsGridEnabled',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'polygonSnapRightAngles': _i1.ParameterDescription(
              name: 'polygonSnapRightAngles',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'polygonSnap45Angles': _i1.ParameterDescription(
              name: 'polygonSnap45Angles',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'mapMinZoom': _i1.ParameterDescription(
              name: 'mapMinZoom',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'mapMaxZoom': _i1.ParameterDescription(
              name: 'mapMaxZoom',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .updateClientPreferences(
                    session,
                    params['measurementUnits'],
                    params['angleDisplayFormat'],
                    params['bearingReference'],
                    params['circleSizeDisplay'],
                    params['appTheme'],
                    params['appLocale'],
                    params['mapMarkerSizeScale'],
                    params['mapViewportDebugBorder'],
                    params['mapTileBorderDebug'],
                    params['mapCompassRoseEnabled'],
                    params['mapMgrsGridEnabled'],
                    params['polygonSnapRightAngles'],
                    params['polygonSnap45Angles'],
                    params['mapMinZoom'],
                    params['mapMaxZoom'],
                  ),
        ),
        'getRestApiKeyStatus': _i1.MethodConnector(
          name: 'getRestApiKeyStatus',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .getRestApiKeyStatus(session),
        ),
        'listRestApiKeys': _i1.MethodConnector(
          name: 'listRestApiKeys',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .listRestApiKeys(session),
        ),
        'createRestApiKey': _i1.MethodConnector(
          name: 'createRestApiKey',
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
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .createRestApiKey(
                    session,
                    params['name'],
                  ),
        ),
        'deleteRestApiKey': _i1.MethodConnector(
          name: 'deleteRestApiKey',
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
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .deleteRestApiKey(
                    session,
                    params['id'],
                  ),
        ),
        'clearRestApiKeys': _i1.MethodConnector(
          name: 'clearRestApiKeys',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appSettings'] as _i13.AppSettingsEndpoint)
                  .clearRestApiKeys(session),
        ),
      },
    );
    connectors['tides'] = _i1.EndpointConnector(
      name: 'tides',
      endpoint: endpoints['tides']!,
      methodConnectors: {
        'listPacks': _i1.MethodConnector(
          name: 'listPacks',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['tides'] as _i14.TidesEndpoint).listPacks(session),
        ),
        'listCoastalRegions': _i1.MethodConnector(
          name: 'listCoastalRegions',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tides'] as _i14.TidesEndpoint)
                  .listCoastalRegions(session),
        ),
        'importCoastalRegion': _i1.MethodConnector(
          name: 'importCoastalRegion',
          params: {
            'regionId': _i1.ParameterDescription(
              name: 'regionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tides'] as _i14.TidesEndpoint)
                  .importCoastalRegion(
                    session,
                    params['regionId'],
                  ),
        ),
        'setPackActive': _i1.MethodConnector(
          name: 'setPackActive',
          params: {
            'packId': _i1.ParameterDescription(
              name: 'packId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'active': _i1.ParameterDescription(
              name: 'active',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['tides'] as _i14.TidesEndpoint).setPackActive(
                    session,
                    params['packId'],
                    params['active'],
                  ),
        ),
        'deletePack': _i1.MethodConnector(
          name: 'deletePack',
          params: {
            'packId': _i1.ParameterDescription(
              name: 'packId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tides'] as _i14.TidesEndpoint).deletePack(
                session,
                params['packId'],
              ),
        ),
        'exportPack': _i1.MethodConnector(
          name: 'exportPack',
          params: {
            'packId': _i1.ParameterDescription(
              name: 'packId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tides'] as _i14.TidesEndpoint).exportPack(
                session,
                params['packId'],
              ),
        ),
        'importPackArchive': _i1.MethodConnector(
          name: 'importPackArchive',
          params: {
            'archiveBytes': _i1.ParameterDescription(
              name: 'archiveBytes',
              type: _i1.getType<_i19.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['tides'] as _i14.TidesEndpoint).importPackArchive(
                    session,
                    params['archiveBytes'],
                  ),
        ),
        'queryAt': _i1.MethodConnector(
          name: 'queryAt',
          params: {
            'lat': _i1.ParameterDescription(
              name: 'lat',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'lng': _i1.ParameterDescription(
              name: 'lng',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'hours': _i1.ParameterDescription(
              name: 'hours',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tides'] as _i14.TidesEndpoint).queryAt(
                session,
                params['lat'],
                params['lng'],
                params['date'],
                hours: params['hours'],
              ),
        ),
      },
    );
    connectors['watchLog'] = _i1.EndpointConnector(
      name: 'watchLog',
      endpoint: endpoints['watchLog']!,
      methodConnectors: {
        'listEntries': _i1.MethodConnector(
          name: 'listEntries',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['watchLog'] as _i15.WatchLogEndpoint)
                  .listEntries(session),
        ),
        'getEntry': _i1.MethodConnector(
          name: 'getEntry',
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
                  (endpoints['watchLog'] as _i15.WatchLogEndpoint).getEntry(
                    session,
                    params['id'],
                  ),
        ),
        'createEntry': _i1.MethodConnector(
          name: 'createEntry',
          params: {
            'entry': _i1.ParameterDescription(
              name: 'entry',
              type: _i1.getType<_i22.WatchLogEntry>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['watchLog'] as _i15.WatchLogEndpoint).createEntry(
                    session,
                    params['entry'],
                  ),
        ),
        'updateEntry': _i1.MethodConnector(
          name: 'updateEntry',
          params: {
            'entry': _i1.ParameterDescription(
              name: 'entry',
              type: _i1.getType<_i22.WatchLogEntry>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['watchLog'] as _i15.WatchLogEndpoint).updateEntry(
                    session,
                    params['entry'],
                  ),
        ),
        'deleteEntry': _i1.MethodConnector(
          name: 'deleteEntry',
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
                  (endpoints['watchLog'] as _i15.WatchLogEndpoint).deleteEntry(
                    session,
                    params['id'],
                  ),
        ),
        'entryChanges': _i1.MethodStreamConnector(
          name: 'entryChanges',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['watchLog'] as _i15.WatchLogEndpoint)
                  .entryChanges(session),
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
              ) async => (endpoints['mapZone'] as _i16.MapZoneEndpoint)
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
              ) async => (endpoints['mapZone'] as _i16.MapZoneEndpoint).getZone(
                session,
                params['id'],
              ),
        ),
        'createZone': _i1.MethodConnector(
          name: 'createZone',
          params: {
            'zone': _i1.ParameterDescription(
              name: 'zone',
              type: _i1.getType<_i23.MapZone>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i16.MapZoneEndpoint).createZone(
                    session,
                    params['zone'],
                  ),
        ),
        'updateZone': _i1.MethodConnector(
          name: 'updateZone',
          params: {
            'zone': _i1.ParameterDescription(
              name: 'zone',
              type: _i1.getType<_i23.MapZone>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['mapZone'] as _i16.MapZoneEndpoint).updateZone(
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
                  (endpoints['mapZone'] as _i16.MapZoneEndpoint).deleteZone(
                    session,
                    params['id'],
                  ),
        ),
        'zoneChanges': _i1.MethodStreamConnector(
          name: 'zoneChanges',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['mapZone'] as _i16.MapZoneEndpoint).zoneChanges(
                session,
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i24.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i25.Endpoints()
      ..initializeEndpoints(server);
  }
}
