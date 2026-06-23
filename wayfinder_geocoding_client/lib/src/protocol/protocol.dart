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
import 'geocoding/geocode_housenumber.dart' as _i2;
import 'geocoding/geocode_place.dart' as _i3;
import 'geocoding/geocode_search_result.dart' as _i4;
import 'geocoding/geocoding_settings.dart' as _i5;
import 'package:wayfinder_geocoding_client/src/protocol/geocoding/geocode_search_result.dart'
    as _i6;
export 'geocoding/geocode_housenumber.dart';
export 'geocoding/geocode_place.dart';
export 'geocoding/geocode_search_result.dart';
export 'geocoding/geocoding_settings.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.GeocodeHousenumber) {
      return _i2.GeocodeHousenumber.fromJson(data) as T;
    }
    if (t == _i3.GeocodePlace) {
      return _i3.GeocodePlace.fromJson(data) as T;
    }
    if (t == _i4.GeocodeSearchResult) {
      return _i4.GeocodeSearchResult.fromJson(data) as T;
    }
    if (t == _i5.GeocodingSettings) {
      return _i5.GeocodingSettings.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.GeocodeHousenumber?>()) {
      return (data != null ? _i2.GeocodeHousenumber.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.GeocodePlace?>()) {
      return (data != null ? _i3.GeocodePlace.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.GeocodeSearchResult?>()) {
      return (data != null ? _i4.GeocodeSearchResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.GeocodingSettings?>()) {
      return (data != null ? _i5.GeocodingSettings.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i6.GeocodeSearchResult>) {
      return (data as List)
              .map((e) => deserialize<_i6.GeocodeSearchResult>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.GeocodeHousenumber => 'GeocodeHousenumber',
      _i3.GeocodePlace => 'GeocodePlace',
      _i4.GeocodeSearchResult => 'GeocodeSearchResult',
      _i5.GeocodingSettings => 'GeocodingSettings',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'wayfinder_geocoding.',
        '',
      );
    }

    switch (data) {
      case _i2.GeocodeHousenumber():
        return 'GeocodeHousenumber';
      case _i3.GeocodePlace():
        return 'GeocodePlace';
      case _i4.GeocodeSearchResult():
        return 'GeocodeSearchResult';
      case _i5.GeocodingSettings():
        return 'GeocodingSettings';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'GeocodeHousenumber') {
      return deserialize<_i2.GeocodeHousenumber>(data['data']);
    }
    if (dataClassName == 'GeocodePlace') {
      return deserialize<_i3.GeocodePlace>(data['data']);
    }
    if (dataClassName == 'GeocodeSearchResult') {
      return deserialize<_i4.GeocodeSearchResult>(data['data']);
    }
    if (dataClassName == 'GeocodingSettings') {
      return deserialize<_i5.GeocodingSettings>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
