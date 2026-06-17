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
import 'greetings/greeting.dart' as _i3;
import 'layers/map_layer.dart' as _i4;
import 'map/map_data_restore_summary.dart' as _i5;
import 'map/map_marker.dart' as _i6;
import 'pmtiles/pmtiles_file.dart' as _i7;
import 'zones/map_zone.dart' as _i8;
import 'package:wayfinder_client/src/protocol/categories/category.dart' as _i9;
import 'package:wayfinder_client/src/protocol/layers/map_layer.dart' as _i10;
import 'package:wayfinder_client/src/protocol/map/map_marker.dart' as _i11;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_file.dart'
    as _i12;
import 'package:wayfinder_client/src/protocol/zones/map_zone.dart' as _i13;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i14;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i15;
export 'categories/category.dart';
export 'greetings/greeting.dart';
export 'layers/map_layer.dart';
export 'map/map_data_restore_summary.dart';
export 'map/map_marker.dart';
export 'pmtiles/pmtiles_file.dart';
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
    if (t == _i3.Greeting) {
      return _i3.Greeting.fromJson(data) as T;
    }
    if (t == _i4.MapLayer) {
      return _i4.MapLayer.fromJson(data) as T;
    }
    if (t == _i5.MapDataRestoreSummary) {
      return _i5.MapDataRestoreSummary.fromJson(data) as T;
    }
    if (t == _i6.MapMarker) {
      return _i6.MapMarker.fromJson(data) as T;
    }
    if (t == _i7.PmtilesFile) {
      return _i7.PmtilesFile.fromJson(data) as T;
    }
    if (t == _i8.MapZone) {
      return _i8.MapZone.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Category?>()) {
      return (data != null ? _i2.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Greeting?>()) {
      return (data != null ? _i3.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.MapLayer?>()) {
      return (data != null ? _i4.MapLayer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.MapDataRestoreSummary?>()) {
      return (data != null ? _i5.MapDataRestoreSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.MapMarker?>()) {
      return (data != null ? _i6.MapMarker.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.PmtilesFile?>()) {
      return (data != null ? _i7.PmtilesFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MapZone?>()) {
      return (data != null ? _i8.MapZone.fromJson(data) : null) as T;
    }
    if (t == List<_i9.Category>) {
      return (data as List).map((e) => deserialize<_i9.Category>(e)).toList()
          as T;
    }
    if (t == List<_i10.MapLayer>) {
      return (data as List).map((e) => deserialize<_i10.MapLayer>(e)).toList()
          as T;
    }
    if (t == List<_i11.MapMarker>) {
      return (data as List).map((e) => deserialize<_i11.MapMarker>(e)).toList()
          as T;
    }
    if (t == List<_i12.PmtilesFile>) {
      return (data as List)
              .map((e) => deserialize<_i12.PmtilesFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.MapZone>) {
      return (data as List).map((e) => deserialize<_i13.MapZone>(e)).toList()
          as T;
    }
    try {
      return _i14.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i15.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Category => 'Category',
      _i3.Greeting => 'Greeting',
      _i4.MapLayer => 'MapLayer',
      _i5.MapDataRestoreSummary => 'MapDataRestoreSummary',
      _i6.MapMarker => 'MapMarker',
      _i7.PmtilesFile => 'PmtilesFile',
      _i8.MapZone => 'MapZone',
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
      case _i3.Greeting():
        return 'Greeting';
      case _i4.MapLayer():
        return 'MapLayer';
      case _i5.MapDataRestoreSummary():
        return 'MapDataRestoreSummary';
      case _i6.MapMarker():
        return 'MapMarker';
      case _i7.PmtilesFile():
        return 'PmtilesFile';
      case _i8.MapZone():
        return 'MapZone';
    }
    className = _i14.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i15.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Greeting') {
      return deserialize<_i3.Greeting>(data['data']);
    }
    if (dataClassName == 'MapLayer') {
      return deserialize<_i4.MapLayer>(data['data']);
    }
    if (dataClassName == 'MapDataRestoreSummary') {
      return deserialize<_i5.MapDataRestoreSummary>(data['data']);
    }
    if (dataClassName == 'MapMarker') {
      return deserialize<_i6.MapMarker>(data['data']);
    }
    if (dataClassName == 'PmtilesFile') {
      return deserialize<_i7.PmtilesFile>(data['data']);
    }
    if (dataClassName == 'MapZone') {
      return deserialize<_i8.MapZone>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i14.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i15.Protocol().deserializeByClassName(data);
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
      return _i14.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i15.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
