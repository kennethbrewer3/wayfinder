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
import 'package:wayfinder_geocoding_client/src/protocol/geocoding/geocoding_settings.dart'
    as _i3;
import 'package:wayfinder_geocoding_client/src/protocol/geocoding/geocode_search_result.dart'
    as _i4;
import 'protocol.dart' as _i5;

/// {@category Endpoint}
class EndpointGeocoding extends _i1.EndpointRef {
  EndpointGeocoding(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'geocoding';

  _i2.Future<_i3.GeocodingSettings> getSettings() =>
      caller.callServerEndpoint<_i3.GeocodingSettings>(
        'geocoding',
        'getSettings',
        {},
      );

  _i2.Future<_i3.GeocodingSettings> updateSourceUrl(
    String sourceUrl, {
    List<String>? countryCodes,
  }) => caller.callServerEndpoint<_i3.GeocodingSettings>(
    'geocoding',
    'updateSourceUrl',
    {
      'sourceUrl': sourceUrl,
      'countryCodes': countryCodes,
    },
  );

  _i2.Future<_i3.GeocodingSettings> startImport({
    String? sourceUrl,
    List<String>? countryCodes,
  }) => caller.callServerEndpoint<_i3.GeocodingSettings>(
    'geocoding',
    'startImport',
    {
      'sourceUrl': sourceUrl,
      'countryCodes': countryCodes,
    },
  );

  _i2.Future<_i3.GeocodingSettings> startHousenumbersImport({
    String? sourceUrl,
  }) => caller.callServerEndpoint<_i3.GeocodingSettings>(
    'geocoding',
    'startHousenumbersImport',
    {'sourceUrl': sourceUrl},
  );

  _i2.Future<_i3.GeocodingSettings> cancelImport() =>
      caller.callServerEndpoint<_i3.GeocodingSettings>(
        'geocoding',
        'cancelImport',
        {},
      );

  _i2.Future<_i3.GeocodingSettings> cancelHousenumbersImport() =>
      caller.callServerEndpoint<_i3.GeocodingSettings>(
        'geocoding',
        'cancelHousenumbersImport',
        {},
      );

  _i2.Future<List<_i4.GeocodeSearchResult>> searchPlaces(String query) =>
      caller.callServerEndpoint<List<_i4.GeocodeSearchResult>>(
        'geocoding',
        'searchPlaces',
        {'query': query},
      );

  _i2.Future<bool> isSearchReady() => caller.callServerEndpoint<bool>(
    'geocoding',
    'isSearchReady',
    {},
  );

  _i2.Future<String> exportPlacesArchive() => caller.callServerEndpoint<String>(
    'geocoding',
    'exportPlacesArchive',
    {},
  );

  _i2.Future<String> exportHousenumbersArchive() =>
      caller.callServerEndpoint<String>(
        'geocoding',
        'exportHousenumbersArchive',
        {},
      );

  _i2.Future<int> importPlacesArchive(String archiveJson) =>
      caller.callServerEndpoint<int>(
        'geocoding',
        'importPlacesArchive',
        {'archiveJson': archiveJson},
      );

  _i2.Future<int> importHousenumbersArchive(String archiveJson) =>
      caller.callServerEndpoint<int>(
        'geocoding',
        'importHousenumbersArchive',
        {'archiveJson': archiveJson},
      );

  _i2.Future<int> clearPlaces() => caller.callServerEndpoint<int>(
    'geocoding',
    'clearPlaces',
    {},
  );

  _i2.Future<int> clearHousenumbers() => caller.callServerEndpoint<int>(
    'geocoding',
    'clearHousenumbers',
    {},
  );
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
         _i5.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    geocoding = EndpointGeocoding(this);
  }

  late final EndpointGeocoding geocoding;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'geocoding': geocoding,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
