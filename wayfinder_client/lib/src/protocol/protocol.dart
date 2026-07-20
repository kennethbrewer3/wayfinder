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
import 'layers/map_layer_change.dart' as _i5;
import 'map/map_data_restore_summary.dart' as _i6;
import 'map/map_marker.dart' as _i7;
import 'map/map_marker_change.dart' as _i8;
import 'markers/marker_icon_catalog_entry.dart' as _i9;
import 'markers/marker_icon_category_definition.dart' as _i10;
import 'pmtiles/pmtiles_file.dart' as _i11;
import 'pmtiles/pmtiles_file_group_link.dart' as _i12;
import 'pmtiles/pmtiles_group.dart' as _i13;
import 'settings/app_settings.dart' as _i14;
import 'settings/rest_api_key.dart' as _i15;
import 'settings/rest_api_key_created.dart' as _i16;
import 'settings/rest_api_key_info.dart' as _i17;
import 'tides/tide_coastal_region.dart' as _i18;
import 'tides/tide_extreme.dart' as _i19;
import 'tides/tide_pack_info.dart' as _i20;
import 'tides/tide_query_result.dart' as _i21;
import 'tides/tide_sample.dart' as _i22;
import 'tides/tide_station_info.dart' as _i23;
import 'zones/map_zone.dart' as _i24;
import 'zones/map_zone_change.dart' as _i25;
import 'package:wayfinder_client/src/protocol/categories/category.dart' as _i26;
import 'package:wayfinder_client/src/protocol/layers/map_layer.dart' as _i27;
import 'package:wayfinder_client/src/protocol/map/map_marker.dart' as _i28;
import 'package:wayfinder_client/src/protocol/markers/marker_icon_catalog_entry.dart'
    as _i29;
import 'package:wayfinder_client/src/protocol/markers/marker_icon_category_definition.dart'
    as _i30;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_file.dart'
    as _i31;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_group.dart'
    as _i32;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key.dart'
    as _i33;
import 'package:wayfinder_client/src/protocol/tides/tide_pack_info.dart'
    as _i34;
import 'package:wayfinder_client/src/protocol/tides/tide_coastal_region.dart'
    as _i35;
import 'package:wayfinder_client/src/protocol/zones/map_zone.dart' as _i36;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i37;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i38;
export 'categories/category.dart';
export 'greetings/greeting.dart';
export 'layers/map_layer.dart';
export 'layers/map_layer_change.dart';
export 'map/map_data_restore_summary.dart';
export 'map/map_marker.dart';
export 'map/map_marker_change.dart';
export 'markers/marker_icon_catalog_entry.dart';
export 'markers/marker_icon_category_definition.dart';
export 'pmtiles/pmtiles_file.dart';
export 'pmtiles/pmtiles_file_group_link.dart';
export 'pmtiles/pmtiles_group.dart';
export 'settings/app_settings.dart';
export 'settings/rest_api_key.dart';
export 'settings/rest_api_key_created.dart';
export 'settings/rest_api_key_info.dart';
export 'tides/tide_coastal_region.dart';
export 'tides/tide_extreme.dart';
export 'tides/tide_pack_info.dart';
export 'tides/tide_query_result.dart';
export 'tides/tide_sample.dart';
export 'tides/tide_station_info.dart';
export 'zones/map_zone.dart';
export 'zones/map_zone_change.dart';
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
    if (t == _i5.MapLayerChange) {
      return _i5.MapLayerChange.fromJson(data) as T;
    }
    if (t == _i6.MapDataRestoreSummary) {
      return _i6.MapDataRestoreSummary.fromJson(data) as T;
    }
    if (t == _i7.MapMarker) {
      return _i7.MapMarker.fromJson(data) as T;
    }
    if (t == _i8.MapMarkerChange) {
      return _i8.MapMarkerChange.fromJson(data) as T;
    }
    if (t == _i9.MarkerIconCatalogEntry) {
      return _i9.MarkerIconCatalogEntry.fromJson(data) as T;
    }
    if (t == _i10.MarkerIconCategoryDefinition) {
      return _i10.MarkerIconCategoryDefinition.fromJson(data) as T;
    }
    if (t == _i11.PmtilesFile) {
      return _i11.PmtilesFile.fromJson(data) as T;
    }
    if (t == _i12.PmtilesFileGroupLink) {
      return _i12.PmtilesFileGroupLink.fromJson(data) as T;
    }
    if (t == _i13.PmtilesGroup) {
      return _i13.PmtilesGroup.fromJson(data) as T;
    }
    if (t == _i14.AppSettings) {
      return _i14.AppSettings.fromJson(data) as T;
    }
    if (t == _i15.RestApiKey) {
      return _i15.RestApiKey.fromJson(data) as T;
    }
    if (t == _i16.RestApiKeyCreated) {
      return _i16.RestApiKeyCreated.fromJson(data) as T;
    }
    if (t == _i17.RestApiKeyInfo) {
      return _i17.RestApiKeyInfo.fromJson(data) as T;
    }
    if (t == _i18.TideCoastalRegion) {
      return _i18.TideCoastalRegion.fromJson(data) as T;
    }
    if (t == _i19.TideExtreme) {
      return _i19.TideExtreme.fromJson(data) as T;
    }
    if (t == _i20.TidePackInfo) {
      return _i20.TidePackInfo.fromJson(data) as T;
    }
    if (t == _i21.TideQueryResult) {
      return _i21.TideQueryResult.fromJson(data) as T;
    }
    if (t == _i22.TideSample) {
      return _i22.TideSample.fromJson(data) as T;
    }
    if (t == _i23.TideStationInfo) {
      return _i23.TideStationInfo.fromJson(data) as T;
    }
    if (t == _i24.MapZone) {
      return _i24.MapZone.fromJson(data) as T;
    }
    if (t == _i25.MapZoneChange) {
      return _i25.MapZoneChange.fromJson(data) as T;
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
    if (t == _i1.getType<_i5.MapLayerChange?>()) {
      return (data != null ? _i5.MapLayerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.MapDataRestoreSummary?>()) {
      return (data != null ? _i6.MapDataRestoreSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.MapMarker?>()) {
      return (data != null ? _i7.MapMarker.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MapMarkerChange?>()) {
      return (data != null ? _i8.MapMarkerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.MarkerIconCatalogEntry?>()) {
      return (data != null ? _i9.MarkerIconCatalogEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.MarkerIconCategoryDefinition?>()) {
      return (data != null
              ? _i10.MarkerIconCategoryDefinition.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.PmtilesFile?>()) {
      return (data != null ? _i11.PmtilesFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PmtilesFileGroupLink?>()) {
      return (data != null ? _i12.PmtilesFileGroupLink.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.PmtilesGroup?>()) {
      return (data != null ? _i13.PmtilesGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.AppSettings?>()) {
      return (data != null ? _i14.AppSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.RestApiKey?>()) {
      return (data != null ? _i15.RestApiKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.RestApiKeyCreated?>()) {
      return (data != null ? _i16.RestApiKeyCreated.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.RestApiKeyInfo?>()) {
      return (data != null ? _i17.RestApiKeyInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.TideCoastalRegion?>()) {
      return (data != null ? _i18.TideCoastalRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.TideExtreme?>()) {
      return (data != null ? _i19.TideExtreme.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.TidePackInfo?>()) {
      return (data != null ? _i20.TidePackInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.TideQueryResult?>()) {
      return (data != null ? _i21.TideQueryResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.TideSample?>()) {
      return (data != null ? _i22.TideSample.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.TideStationInfo?>()) {
      return (data != null ? _i23.TideStationInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.MapZone?>()) {
      return (data != null ? _i24.MapZone.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.MapZoneChange?>()) {
      return (data != null ? _i25.MapZoneChange.fromJson(data) : null) as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i1.UuidValue>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i1.UuidValue>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i22.TideSample>) {
      return (data as List).map((e) => deserialize<_i22.TideSample>(e)).toList()
          as T;
    }
    if (t == List<_i19.TideExtreme>) {
      return (data as List)
              .map((e) => deserialize<_i19.TideExtreme>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.Category>) {
      return (data as List).map((e) => deserialize<_i26.Category>(e)).toList()
          as T;
    }
    if (t == List<_i27.MapLayer>) {
      return (data as List).map((e) => deserialize<_i27.MapLayer>(e)).toList()
          as T;
    }
    if (t == List<_i28.MapMarker>) {
      return (data as List).map((e) => deserialize<_i28.MapMarker>(e)).toList()
          as T;
    }
    if (t == List<_i29.MarkerIconCatalogEntry>) {
      return (data as List)
              .map((e) => deserialize<_i29.MarkerIconCatalogEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i30.MarkerIconCategoryDefinition>) {
      return (data as List)
              .map((e) => deserialize<_i30.MarkerIconCategoryDefinition>(e))
              .toList()
          as T;
    }
    if (t == List<_i31.PmtilesFile>) {
      return (data as List)
              .map((e) => deserialize<_i31.PmtilesFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i32.PmtilesGroup>) {
      return (data as List)
              .map((e) => deserialize<_i32.PmtilesGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_i33.RestApiKey>) {
      return (data as List).map((e) => deserialize<_i33.RestApiKey>(e)).toList()
          as T;
    }
    if (t == List<_i34.TidePackInfo>) {
      return (data as List)
              .map((e) => deserialize<_i34.TidePackInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.TideCoastalRegion>) {
      return (data as List)
              .map((e) => deserialize<_i35.TideCoastalRegion>(e))
              .toList()
          as T;
    }
    if (t == List<_i36.MapZone>) {
      return (data as List).map((e) => deserialize<_i36.MapZone>(e)).toList()
          as T;
    }
    try {
      return _i37.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i38.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Category => 'Category',
      _i3.Greeting => 'Greeting',
      _i4.MapLayer => 'MapLayer',
      _i5.MapLayerChange => 'MapLayerChange',
      _i6.MapDataRestoreSummary => 'MapDataRestoreSummary',
      _i7.MapMarker => 'MapMarker',
      _i8.MapMarkerChange => 'MapMarkerChange',
      _i9.MarkerIconCatalogEntry => 'MarkerIconCatalogEntry',
      _i10.MarkerIconCategoryDefinition => 'MarkerIconCategoryDefinition',
      _i11.PmtilesFile => 'PmtilesFile',
      _i12.PmtilesFileGroupLink => 'PmtilesFileGroupLink',
      _i13.PmtilesGroup => 'PmtilesGroup',
      _i14.AppSettings => 'AppSettings',
      _i15.RestApiKey => 'RestApiKey',
      _i16.RestApiKeyCreated => 'RestApiKeyCreated',
      _i17.RestApiKeyInfo => 'RestApiKeyInfo',
      _i18.TideCoastalRegion => 'TideCoastalRegion',
      _i19.TideExtreme => 'TideExtreme',
      _i20.TidePackInfo => 'TidePackInfo',
      _i21.TideQueryResult => 'TideQueryResult',
      _i22.TideSample => 'TideSample',
      _i23.TideStationInfo => 'TideStationInfo',
      _i24.MapZone => 'MapZone',
      _i25.MapZoneChange => 'MapZoneChange',
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
      case _i5.MapLayerChange():
        return 'MapLayerChange';
      case _i6.MapDataRestoreSummary():
        return 'MapDataRestoreSummary';
      case _i7.MapMarker():
        return 'MapMarker';
      case _i8.MapMarkerChange():
        return 'MapMarkerChange';
      case _i9.MarkerIconCatalogEntry():
        return 'MarkerIconCatalogEntry';
      case _i10.MarkerIconCategoryDefinition():
        return 'MarkerIconCategoryDefinition';
      case _i11.PmtilesFile():
        return 'PmtilesFile';
      case _i12.PmtilesFileGroupLink():
        return 'PmtilesFileGroupLink';
      case _i13.PmtilesGroup():
        return 'PmtilesGroup';
      case _i14.AppSettings():
        return 'AppSettings';
      case _i15.RestApiKey():
        return 'RestApiKey';
      case _i16.RestApiKeyCreated():
        return 'RestApiKeyCreated';
      case _i17.RestApiKeyInfo():
        return 'RestApiKeyInfo';
      case _i18.TideCoastalRegion():
        return 'TideCoastalRegion';
      case _i19.TideExtreme():
        return 'TideExtreme';
      case _i20.TidePackInfo():
        return 'TidePackInfo';
      case _i21.TideQueryResult():
        return 'TideQueryResult';
      case _i22.TideSample():
        return 'TideSample';
      case _i23.TideStationInfo():
        return 'TideStationInfo';
      case _i24.MapZone():
        return 'MapZone';
      case _i25.MapZoneChange():
        return 'MapZoneChange';
    }
    className = _i37.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i38.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'MapLayerChange') {
      return deserialize<_i5.MapLayerChange>(data['data']);
    }
    if (dataClassName == 'MapDataRestoreSummary') {
      return deserialize<_i6.MapDataRestoreSummary>(data['data']);
    }
    if (dataClassName == 'MapMarker') {
      return deserialize<_i7.MapMarker>(data['data']);
    }
    if (dataClassName == 'MapMarkerChange') {
      return deserialize<_i8.MapMarkerChange>(data['data']);
    }
    if (dataClassName == 'MarkerIconCatalogEntry') {
      return deserialize<_i9.MarkerIconCatalogEntry>(data['data']);
    }
    if (dataClassName == 'MarkerIconCategoryDefinition') {
      return deserialize<_i10.MarkerIconCategoryDefinition>(data['data']);
    }
    if (dataClassName == 'PmtilesFile') {
      return deserialize<_i11.PmtilesFile>(data['data']);
    }
    if (dataClassName == 'PmtilesFileGroupLink') {
      return deserialize<_i12.PmtilesFileGroupLink>(data['data']);
    }
    if (dataClassName == 'PmtilesGroup') {
      return deserialize<_i13.PmtilesGroup>(data['data']);
    }
    if (dataClassName == 'AppSettings') {
      return deserialize<_i14.AppSettings>(data['data']);
    }
    if (dataClassName == 'RestApiKey') {
      return deserialize<_i15.RestApiKey>(data['data']);
    }
    if (dataClassName == 'RestApiKeyCreated') {
      return deserialize<_i16.RestApiKeyCreated>(data['data']);
    }
    if (dataClassName == 'RestApiKeyInfo') {
      return deserialize<_i17.RestApiKeyInfo>(data['data']);
    }
    if (dataClassName == 'TideCoastalRegion') {
      return deserialize<_i18.TideCoastalRegion>(data['data']);
    }
    if (dataClassName == 'TideExtreme') {
      return deserialize<_i19.TideExtreme>(data['data']);
    }
    if (dataClassName == 'TidePackInfo') {
      return deserialize<_i20.TidePackInfo>(data['data']);
    }
    if (dataClassName == 'TideQueryResult') {
      return deserialize<_i21.TideQueryResult>(data['data']);
    }
    if (dataClassName == 'TideSample') {
      return deserialize<_i22.TideSample>(data['data']);
    }
    if (dataClassName == 'TideStationInfo') {
      return deserialize<_i23.TideStationInfo>(data['data']);
    }
    if (dataClassName == 'MapZone') {
      return deserialize<_i24.MapZone>(data['data']);
    }
    if (dataClassName == 'MapZoneChange') {
      return deserialize<_i25.MapZoneChange>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i37.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i38.Protocol().deserializeByClassName(data);
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
      return _i37.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i38.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
