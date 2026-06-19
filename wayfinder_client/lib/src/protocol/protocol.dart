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
import 'categories/category.dart' as _i2;
import 'geocoding/geocode_housenumber.dart' as _i3;
import 'geocoding/geocode_place.dart' as _i4;
import 'geocoding/geocode_search_result.dart' as _i5;
import 'geocoding/geocoding_settings.dart' as _i6;
import 'greetings/greeting.dart' as _i7;
import 'layers/map_layer.dart' as _i8;
import 'map/map_data_restore_summary.dart' as _i9;
import 'map/map_marker.dart' as _i10;
import 'pmtiles/pmtiles_file.dart' as _i11;
import 'pmtiles/pmtiles_group.dart' as _i12;
import 'zones/map_zone.dart' as _i13;
import 'package:wayfinder_client/src/protocol/categories/category.dart' as _i14;
import 'package:wayfinder_client/src/protocol/geocoding/geocode_search_result.dart'
    as _i15;
import 'package:wayfinder_client/src/protocol/layers/map_layer.dart' as _i16;
import 'package:wayfinder_client/src/protocol/map/map_marker.dart' as _i17;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_file.dart'
    as _i18;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_group.dart'
    as _i19;
import 'package:wayfinder_client/src/protocol/zones/map_zone.dart' as _i20;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i21;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i22;
export 'categories/category.dart';
export 'geocoding/geocode_housenumber.dart';
export 'geocoding/geocode_place.dart';
export 'geocoding/geocode_search_result.dart';
export 'geocoding/geocoding_settings.dart';
export 'greetings/greeting.dart';
export 'layers/map_layer.dart';
export 'map/map_data_restore_summary.dart';
export 'map/map_marker.dart';
export 'pmtiles/pmtiles_file.dart';
export 'pmtiles/pmtiles_group.dart';
export 'zones/map_zone.dart';
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

    if (t == _i2.Category) {
      return _i2.Category.fromJson(data) as T;
    }
    if (t == _i3.GeocodeHousenumber) {
      return _i3.GeocodeHousenumber.fromJson(data) as T;
    }
    if (t == _i4.GeocodePlace) {
      return _i4.GeocodePlace.fromJson(data) as T;
    }
    if (t == _i5.GeocodeSearchResult) {
      return _i5.GeocodeSearchResult.fromJson(data) as T;
    }
    if (t == _i6.GeocodingSettings) {
      return _i6.GeocodingSettings.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.MapLayer) {
      return _i8.MapLayer.fromJson(data) as T;
    }
    if (t == _i9.MapDataRestoreSummary) {
      return _i9.MapDataRestoreSummary.fromJson(data) as T;
    }
    if (t == _i10.MapMarker) {
      return _i10.MapMarker.fromJson(data) as T;
    }
    if (t == _i11.PmtilesFile) {
      return _i11.PmtilesFile.fromJson(data) as T;
    }
    if (t == _i12.PmtilesGroup) {
      return _i12.PmtilesGroup.fromJson(data) as T;
    }
    if (t == _i13.MapZone) {
      return _i13.MapZone.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Category?>()) {
      return (data != null ? _i2.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.GeocodeHousenumber?>()) {
      return (data != null ? _i3.GeocodeHousenumber.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.GeocodePlace?>()) {
      return (data != null ? _i4.GeocodePlace.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.GeocodeSearchResult?>()) {
      return (data != null ? _i5.GeocodeSearchResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.GeocodingSettings?>()) {
      return (data != null ? _i6.GeocodingSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MapLayer?>()) {
      return (data != null ? _i8.MapLayer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.MapDataRestoreSummary?>()) {
      return (data != null ? _i9.MapDataRestoreSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.MapMarker?>()) {
      return (data != null ? _i10.MapMarker.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.PmtilesFile?>()) {
      return (data != null ? _i11.PmtilesFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PmtilesGroup?>()) {
      return (data != null ? _i12.PmtilesGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.MapZone?>()) {
      return (data != null ? _i13.MapZone.fromJson(data) : null) as T;
    }
    if (t == List<_i14.Category>) {
      return (data as List).map((e) => deserialize<_i14.Category>(e)).toList()
          as T;
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
    if (t == List<_i15.GeocodeSearchResult>) {
      return (data as List)
              .map((e) => deserialize<_i15.GeocodeSearchResult>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.MapLayer>) {
      return (data as List).map((e) => deserialize<_i16.MapLayer>(e)).toList()
          as T;
    }
    if (t == List<_i17.MapMarker>) {
      return (data as List).map((e) => deserialize<_i17.MapMarker>(e)).toList()
          as T;
    }
    if (t == List<_i18.PmtilesFile>) {
      return (data as List)
              .map((e) => deserialize<_i18.PmtilesFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.PmtilesGroup>) {
      return (data as List)
              .map((e) => deserialize<_i19.PmtilesGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_i20.MapZone>) {
      return (data as List).map((e) => deserialize<_i20.MapZone>(e)).toList()
          as T;
    }
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i22.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Category => 'Category',
      _i3.GeocodeHousenumber => 'GeocodeHousenumber',
      _i4.GeocodePlace => 'GeocodePlace',
      _i5.GeocodeSearchResult => 'GeocodeSearchResult',
      _i6.GeocodingSettings => 'GeocodingSettings',
      _i7.Greeting => 'Greeting',
      _i8.MapLayer => 'MapLayer',
      _i9.MapDataRestoreSummary => 'MapDataRestoreSummary',
      _i10.MapMarker => 'MapMarker',
      _i11.PmtilesFile => 'PmtilesFile',
      _i12.PmtilesGroup => 'PmtilesGroup',
      _i13.MapZone => 'MapZone',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('wayfinder.', '');
    }

    switch (data) {
      case _i2.Category():
        return 'Category';
      case _i3.GeocodeHousenumber():
        return 'GeocodeHousenumber';
      case _i4.GeocodePlace():
        return 'GeocodePlace';
      case _i5.GeocodeSearchResult():
        return 'GeocodeSearchResult';
      case _i6.GeocodingSettings():
        return 'GeocodingSettings';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.MapLayer():
        return 'MapLayer';
      case _i9.MapDataRestoreSummary():
        return 'MapDataRestoreSummary';
      case _i10.MapMarker():
        return 'MapMarker';
      case _i11.PmtilesFile():
        return 'PmtilesFile';
      case _i12.PmtilesGroup():
        return 'PmtilesGroup';
      case _i13.MapZone():
        return 'MapZone';
    }
    className = _i21.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i22.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i2.Category>(data['data']);
    }
    if (dataClassName == 'GeocodeHousenumber') {
      return deserialize<_i3.GeocodeHousenumber>(data['data']);
    }
    if (dataClassName == 'GeocodePlace') {
      return deserialize<_i4.GeocodePlace>(data['data']);
    }
    if (dataClassName == 'GeocodeSearchResult') {
      return deserialize<_i5.GeocodeSearchResult>(data['data']);
    }
    if (dataClassName == 'GeocodingSettings') {
      return deserialize<_i6.GeocodingSettings>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'MapLayer') {
      return deserialize<_i8.MapLayer>(data['data']);
    }
    if (dataClassName == 'MapDataRestoreSummary') {
      return deserialize<_i9.MapDataRestoreSummary>(data['data']);
    }
    if (dataClassName == 'MapMarker') {
      return deserialize<_i10.MapMarker>(data['data']);
    }
    if (dataClassName == 'PmtilesFile') {
      return deserialize<_i11.PmtilesFile>(data['data']);
    }
    if (dataClassName == 'PmtilesGroup') {
      return deserialize<_i12.PmtilesGroup>(data['data']);
    }
    if (dataClassName == 'MapZone') {
      return deserialize<_i13.MapZone>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i21.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i22.Protocol().deserializeByClassName(data);
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
    try {
      return _i21.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i22.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
