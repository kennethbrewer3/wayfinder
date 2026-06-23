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
import '../geocoding/geocoding_endpoint.dart' as _i2;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'geocoding': _i2.GeocodingEndpoint()
        ..initialize(
          server,
          'geocoding',
          null,
        ),
    };
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
                  (endpoints['geocoding'] as _i2.GeocodingEndpoint).startImport(
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
                  .cancelImport(session),
        ),
        'cancelHousenumbersImport': _i1.MethodConnector(
          name: 'cancelHousenumbersImport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
                  .isSearchReady(session),
        ),
        'exportPlacesArchive': _i1.MethodConnector(
          name: 'exportPlacesArchive',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
                  .exportPlacesArchive(session),
        ),
        'exportHousenumbersArchive': _i1.MethodConnector(
          name: 'exportHousenumbersArchive',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
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
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
                  .clearPlaces(session),
        ),
        'clearHousenumbers': _i1.MethodConnector(
          name: 'clearHousenumbers',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['geocoding'] as _i2.GeocodingEndpoint)
                  .clearHousenumbers(session),
        ),
      },
    );
  }
}
