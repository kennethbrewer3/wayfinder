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
import 'access/access_role.dart' as _i2;
import 'access/access_role_info.dart' as _i3;
import 'access/access_session_info.dart' as _i4;
import 'access/access_user_info.dart' as _i5;
import 'access/user_membership.dart' as _i6;
import 'categories/category.dart' as _i7;
import 'comms/comms_plan.dart' as _i8;
import 'comms/comms_plan_change.dart' as _i9;
import 'greetings/greeting.dart' as _i10;
import 'layers/map_layer.dart' as _i11;
import 'layers/map_layer_change.dart' as _i12;
import 'map/map_data_restore_summary.dart' as _i13;
import 'map/map_marker.dart' as _i14;
import 'map/map_marker_change.dart' as _i15;
import 'map/map_object_audit_event.dart' as _i16;
import 'markers/marker_attachment.dart' as _i17;
import 'markers/marker_icon_catalog_entry.dart' as _i18;
import 'markers/marker_icon_category_definition.dart' as _i19;
import 'pmtiles/pmtiles_file.dart' as _i20;
import 'pmtiles/pmtiles_file_group_link.dart' as _i21;
import 'pmtiles/pmtiles_group.dart' as _i22;
import 'seasonal_overlays/seasonal_overlay.dart' as _i23;
import 'seasonal_overlays/seasonal_overlay_change.dart' as _i24;
import 'settings/app_settings.dart' as _i25;
import 'settings/rest_api_key.dart' as _i26;
import 'settings/rest_api_key_created.dart' as _i27;
import 'settings/rest_api_key_info.dart' as _i28;
import 'settings/user_client_preferences.dart' as _i29;
import 'themes/app_theme_definition.dart' as _i30;
import 'tides/tide_coastal_region.dart' as _i31;
import 'tides/tide_extreme.dart' as _i32;
import 'tides/tide_pack_info.dart' as _i33;
import 'tides/tide_query_result.dart' as _i34;
import 'tides/tide_sample.dart' as _i35;
import 'tides/tide_station_info.dart' as _i36;
import 'watch_log/watch_log_entry.dart' as _i37;
import 'watch_log/watch_log_entry_change.dart' as _i38;
import 'zones/map_zone.dart' as _i39;
import 'zones/map_zone_change.dart' as _i40;
import 'package:wayfinder_client/src/protocol/access/access_user_info.dart'
    as _i41;
import 'package:wayfinder_client/src/protocol/access/access_role_info.dart'
    as _i42;
import 'package:wayfinder_client/src/protocol/categories/category.dart' as _i43;
import 'package:wayfinder_client/src/protocol/comms/comms_plan.dart' as _i44;
import 'package:wayfinder_client/src/protocol/layers/map_layer.dart' as _i45;
import 'package:wayfinder_client/src/protocol/map/map_marker.dart' as _i46;
import 'package:wayfinder_client/src/protocol/markers/marker_attachment.dart'
    as _i47;
import 'package:wayfinder_client/src/protocol/markers/marker_icon_catalog_entry.dart'
    as _i48;
import 'package:wayfinder_client/src/protocol/markers/marker_icon_category_definition.dart'
    as _i49;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_file.dart'
    as _i50;
import 'package:wayfinder_client/src/protocol/pmtiles/pmtiles_group.dart'
    as _i51;
import 'package:wayfinder_client/src/protocol/seasonal_overlays/seasonal_overlay.dart'
    as _i52;
import 'package:wayfinder_client/src/protocol/settings/rest_api_key.dart'
    as _i53;
import 'package:wayfinder_client/src/protocol/themes/app_theme_definition.dart'
    as _i54;
import 'package:wayfinder_client/src/protocol/tides/tide_pack_info.dart'
    as _i55;
import 'package:wayfinder_client/src/protocol/tides/tide_coastal_region.dart'
    as _i56;
import 'package:wayfinder_client/src/protocol/watch_log/watch_log_entry.dart'
    as _i57;
import 'package:wayfinder_client/src/protocol/zones/map_zone.dart' as _i58;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i59;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i60;
export 'access/access_role.dart';
export 'access/access_role_info.dart';
export 'access/access_session_info.dart';
export 'access/access_user_info.dart';
export 'access/user_membership.dart';
export 'categories/category.dart';
export 'comms/comms_plan.dart';
export 'comms/comms_plan_change.dart';
export 'greetings/greeting.dart';
export 'layers/map_layer.dart';
export 'layers/map_layer_change.dart';
export 'map/map_data_restore_summary.dart';
export 'map/map_marker.dart';
export 'map/map_marker_change.dart';
export 'map/map_object_audit_event.dart';
export 'markers/marker_attachment.dart';
export 'markers/marker_icon_catalog_entry.dart';
export 'markers/marker_icon_category_definition.dart';
export 'pmtiles/pmtiles_file.dart';
export 'pmtiles/pmtiles_file_group_link.dart';
export 'pmtiles/pmtiles_group.dart';
export 'seasonal_overlays/seasonal_overlay.dart';
export 'seasonal_overlays/seasonal_overlay_change.dart';
export 'settings/app_settings.dart';
export 'settings/rest_api_key.dart';
export 'settings/rest_api_key_created.dart';
export 'settings/rest_api_key_info.dart';
export 'settings/user_client_preferences.dart';
export 'themes/app_theme_definition.dart';
export 'tides/tide_coastal_region.dart';
export 'tides/tide_extreme.dart';
export 'tides/tide_pack_info.dart';
export 'tides/tide_query_result.dart';
export 'tides/tide_sample.dart';
export 'tides/tide_station_info.dart';
export 'watch_log/watch_log_entry.dart';
export 'watch_log/watch_log_entry_change.dart';
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

    if (t == _i2.AccessRole) {
      return _i2.AccessRole.fromJson(data) as T;
    }
    if (t == _i3.AccessRoleInfo) {
      return _i3.AccessRoleInfo.fromJson(data) as T;
    }
    if (t == _i4.AccessSessionInfo) {
      return _i4.AccessSessionInfo.fromJson(data) as T;
    }
    if (t == _i5.AccessUserInfo) {
      return _i5.AccessUserInfo.fromJson(data) as T;
    }
    if (t == _i6.UserMembership) {
      return _i6.UserMembership.fromJson(data) as T;
    }
    if (t == _i7.Category) {
      return _i7.Category.fromJson(data) as T;
    }
    if (t == _i8.CommsPlan) {
      return _i8.CommsPlan.fromJson(data) as T;
    }
    if (t == _i9.CommsPlanChange) {
      return _i9.CommsPlanChange.fromJson(data) as T;
    }
    if (t == _i10.Greeting) {
      return _i10.Greeting.fromJson(data) as T;
    }
    if (t == _i11.MapLayer) {
      return _i11.MapLayer.fromJson(data) as T;
    }
    if (t == _i12.MapLayerChange) {
      return _i12.MapLayerChange.fromJson(data) as T;
    }
    if (t == _i13.MapDataRestoreSummary) {
      return _i13.MapDataRestoreSummary.fromJson(data) as T;
    }
    if (t == _i14.MapMarker) {
      return _i14.MapMarker.fromJson(data) as T;
    }
    if (t == _i15.MapMarkerChange) {
      return _i15.MapMarkerChange.fromJson(data) as T;
    }
    if (t == _i16.MapObjectAuditEvent) {
      return _i16.MapObjectAuditEvent.fromJson(data) as T;
    }
    if (t == _i17.MarkerAttachment) {
      return _i17.MarkerAttachment.fromJson(data) as T;
    }
    if (t == _i18.MarkerIconCatalogEntry) {
      return _i18.MarkerIconCatalogEntry.fromJson(data) as T;
    }
    if (t == _i19.MarkerIconCategoryDefinition) {
      return _i19.MarkerIconCategoryDefinition.fromJson(data) as T;
    }
    if (t == _i20.PmtilesFile) {
      return _i20.PmtilesFile.fromJson(data) as T;
    }
    if (t == _i21.PmtilesFileGroupLink) {
      return _i21.PmtilesFileGroupLink.fromJson(data) as T;
    }
    if (t == _i22.PmtilesGroup) {
      return _i22.PmtilesGroup.fromJson(data) as T;
    }
    if (t == _i23.SeasonalOverlay) {
      return _i23.SeasonalOverlay.fromJson(data) as T;
    }
    if (t == _i24.SeasonalOverlayChange) {
      return _i24.SeasonalOverlayChange.fromJson(data) as T;
    }
    if (t == _i25.AppSettings) {
      return _i25.AppSettings.fromJson(data) as T;
    }
    if (t == _i26.RestApiKey) {
      return _i26.RestApiKey.fromJson(data) as T;
    }
    if (t == _i27.RestApiKeyCreated) {
      return _i27.RestApiKeyCreated.fromJson(data) as T;
    }
    if (t == _i28.RestApiKeyInfo) {
      return _i28.RestApiKeyInfo.fromJson(data) as T;
    }
    if (t == _i29.UserClientPreferences) {
      return _i29.UserClientPreferences.fromJson(data) as T;
    }
    if (t == _i30.AppThemeDefinition) {
      return _i30.AppThemeDefinition.fromJson(data) as T;
    }
    if (t == _i31.TideCoastalRegion) {
      return _i31.TideCoastalRegion.fromJson(data) as T;
    }
    if (t == _i32.TideExtreme) {
      return _i32.TideExtreme.fromJson(data) as T;
    }
    if (t == _i33.TidePackInfo) {
      return _i33.TidePackInfo.fromJson(data) as T;
    }
    if (t == _i34.TideQueryResult) {
      return _i34.TideQueryResult.fromJson(data) as T;
    }
    if (t == _i35.TideSample) {
      return _i35.TideSample.fromJson(data) as T;
    }
    if (t == _i36.TideStationInfo) {
      return _i36.TideStationInfo.fromJson(data) as T;
    }
    if (t == _i37.WatchLogEntry) {
      return _i37.WatchLogEntry.fromJson(data) as T;
    }
    if (t == _i38.WatchLogEntryChange) {
      return _i38.WatchLogEntryChange.fromJson(data) as T;
    }
    if (t == _i39.MapZone) {
      return _i39.MapZone.fromJson(data) as T;
    }
    if (t == _i40.MapZoneChange) {
      return _i40.MapZoneChange.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AccessRole?>()) {
      return (data != null ? _i2.AccessRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AccessRoleInfo?>()) {
      return (data != null ? _i3.AccessRoleInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AccessSessionInfo?>()) {
      return (data != null ? _i4.AccessSessionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AccessUserInfo?>()) {
      return (data != null ? _i5.AccessUserInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.UserMembership?>()) {
      return (data != null ? _i6.UserMembership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Category?>()) {
      return (data != null ? _i7.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CommsPlan?>()) {
      return (data != null ? _i8.CommsPlan.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CommsPlanChange?>()) {
      return (data != null ? _i9.CommsPlanChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Greeting?>()) {
      return (data != null ? _i10.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MapLayer?>()) {
      return (data != null ? _i11.MapLayer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.MapLayerChange?>()) {
      return (data != null ? _i12.MapLayerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.MapDataRestoreSummary?>()) {
      return (data != null ? _i13.MapDataRestoreSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.MapMarker?>()) {
      return (data != null ? _i14.MapMarker.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.MapMarkerChange?>()) {
      return (data != null ? _i15.MapMarkerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.MapObjectAuditEvent?>()) {
      return (data != null ? _i16.MapObjectAuditEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.MarkerAttachment?>()) {
      return (data != null ? _i17.MarkerAttachment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.MarkerIconCatalogEntry?>()) {
      return (data != null ? _i18.MarkerIconCatalogEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.MarkerIconCategoryDefinition?>()) {
      return (data != null
              ? _i19.MarkerIconCategoryDefinition.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.PmtilesFile?>()) {
      return (data != null ? _i20.PmtilesFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.PmtilesFileGroupLink?>()) {
      return (data != null ? _i21.PmtilesFileGroupLink.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.PmtilesGroup?>()) {
      return (data != null ? _i22.PmtilesGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.SeasonalOverlay?>()) {
      return (data != null ? _i23.SeasonalOverlay.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.SeasonalOverlayChange?>()) {
      return (data != null ? _i24.SeasonalOverlayChange.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.AppSettings?>()) {
      return (data != null ? _i25.AppSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.RestApiKey?>()) {
      return (data != null ? _i26.RestApiKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.RestApiKeyCreated?>()) {
      return (data != null ? _i27.RestApiKeyCreated.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.RestApiKeyInfo?>()) {
      return (data != null ? _i28.RestApiKeyInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.UserClientPreferences?>()) {
      return (data != null ? _i29.UserClientPreferences.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.AppThemeDefinition?>()) {
      return (data != null ? _i30.AppThemeDefinition.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i31.TideCoastalRegion?>()) {
      return (data != null ? _i31.TideCoastalRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.TideExtreme?>()) {
      return (data != null ? _i32.TideExtreme.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.TidePackInfo?>()) {
      return (data != null ? _i33.TidePackInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.TideQueryResult?>()) {
      return (data != null ? _i34.TideQueryResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.TideSample?>()) {
      return (data != null ? _i35.TideSample.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.TideStationInfo?>()) {
      return (data != null ? _i36.TideStationInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.WatchLogEntry?>()) {
      return (data != null ? _i37.WatchLogEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.WatchLogEntryChange?>()) {
      return (data != null ? _i38.WatchLogEntryChange.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i39.MapZone?>()) {
      return (data != null ? _i39.MapZone.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.MapZoneChange?>()) {
      return (data != null ? _i40.MapZoneChange.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
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
    if (t == List<_i35.TideSample>) {
      return (data as List).map((e) => deserialize<_i35.TideSample>(e)).toList()
          as T;
    }
    if (t == List<_i32.TideExtreme>) {
      return (data as List)
              .map((e) => deserialize<_i32.TideExtreme>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i41.AccessUserInfo>) {
      return (data as List)
              .map((e) => deserialize<_i41.AccessUserInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i42.AccessRoleInfo>) {
      return (data as List)
              .map((e) => deserialize<_i42.AccessRoleInfo>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i43.Category>) {
      return (data as List).map((e) => deserialize<_i43.Category>(e)).toList()
          as T;
    }
    if (t == List<_i44.CommsPlan>) {
      return (data as List).map((e) => deserialize<_i44.CommsPlan>(e)).toList()
          as T;
    }
    if (t == List<_i45.MapLayer>) {
      return (data as List).map((e) => deserialize<_i45.MapLayer>(e)).toList()
          as T;
    }
    if (t == List<_i46.MapMarker>) {
      return (data as List).map((e) => deserialize<_i46.MapMarker>(e)).toList()
          as T;
    }
    if (t == List<_i47.MarkerAttachment>) {
      return (data as List)
              .map((e) => deserialize<_i47.MarkerAttachment>(e))
              .toList()
          as T;
    }
    if (t == List<_i48.MarkerIconCatalogEntry>) {
      return (data as List)
              .map((e) => deserialize<_i48.MarkerIconCatalogEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i49.MarkerIconCategoryDefinition>) {
      return (data as List)
              .map((e) => deserialize<_i49.MarkerIconCategoryDefinition>(e))
              .toList()
          as T;
    }
    if (t == List<_i50.PmtilesFile>) {
      return (data as List)
              .map((e) => deserialize<_i50.PmtilesFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i51.PmtilesGroup>) {
      return (data as List)
              .map((e) => deserialize<_i51.PmtilesGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_i52.SeasonalOverlay>) {
      return (data as List)
              .map((e) => deserialize<_i52.SeasonalOverlay>(e))
              .toList()
          as T;
    }
    if (t == List<_i53.RestApiKey>) {
      return (data as List).map((e) => deserialize<_i53.RestApiKey>(e)).toList()
          as T;
    }
    if (t == List<_i54.AppThemeDefinition>) {
      return (data as List)
              .map((e) => deserialize<_i54.AppThemeDefinition>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.TidePackInfo>) {
      return (data as List)
              .map((e) => deserialize<_i55.TidePackInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.TideCoastalRegion>) {
      return (data as List)
              .map((e) => deserialize<_i56.TideCoastalRegion>(e))
              .toList()
          as T;
    }
    if (t == List<_i57.WatchLogEntry>) {
      return (data as List)
              .map((e) => deserialize<_i57.WatchLogEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.MapZone>) {
      return (data as List).map((e) => deserialize<_i58.MapZone>(e)).toList()
          as T;
    }
    try {
      return _i59.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i60.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AccessRole => 'AccessRole',
      _i3.AccessRoleInfo => 'AccessRoleInfo',
      _i4.AccessSessionInfo => 'AccessSessionInfo',
      _i5.AccessUserInfo => 'AccessUserInfo',
      _i6.UserMembership => 'UserMembership',
      _i7.Category => 'Category',
      _i8.CommsPlan => 'CommsPlan',
      _i9.CommsPlanChange => 'CommsPlanChange',
      _i10.Greeting => 'Greeting',
      _i11.MapLayer => 'MapLayer',
      _i12.MapLayerChange => 'MapLayerChange',
      _i13.MapDataRestoreSummary => 'MapDataRestoreSummary',
      _i14.MapMarker => 'MapMarker',
      _i15.MapMarkerChange => 'MapMarkerChange',
      _i16.MapObjectAuditEvent => 'MapObjectAuditEvent',
      _i17.MarkerAttachment => 'MarkerAttachment',
      _i18.MarkerIconCatalogEntry => 'MarkerIconCatalogEntry',
      _i19.MarkerIconCategoryDefinition => 'MarkerIconCategoryDefinition',
      _i20.PmtilesFile => 'PmtilesFile',
      _i21.PmtilesFileGroupLink => 'PmtilesFileGroupLink',
      _i22.PmtilesGroup => 'PmtilesGroup',
      _i23.SeasonalOverlay => 'SeasonalOverlay',
      _i24.SeasonalOverlayChange => 'SeasonalOverlayChange',
      _i25.AppSettings => 'AppSettings',
      _i26.RestApiKey => 'RestApiKey',
      _i27.RestApiKeyCreated => 'RestApiKeyCreated',
      _i28.RestApiKeyInfo => 'RestApiKeyInfo',
      _i29.UserClientPreferences => 'UserClientPreferences',
      _i30.AppThemeDefinition => 'AppThemeDefinition',
      _i31.TideCoastalRegion => 'TideCoastalRegion',
      _i32.TideExtreme => 'TideExtreme',
      _i33.TidePackInfo => 'TidePackInfo',
      _i34.TideQueryResult => 'TideQueryResult',
      _i35.TideSample => 'TideSample',
      _i36.TideStationInfo => 'TideStationInfo',
      _i37.WatchLogEntry => 'WatchLogEntry',
      _i38.WatchLogEntryChange => 'WatchLogEntryChange',
      _i39.MapZone => 'MapZone',
      _i40.MapZoneChange => 'MapZoneChange',
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
      case _i2.AccessRole():
        return 'AccessRole';
      case _i3.AccessRoleInfo():
        return 'AccessRoleInfo';
      case _i4.AccessSessionInfo():
        return 'AccessSessionInfo';
      case _i5.AccessUserInfo():
        return 'AccessUserInfo';
      case _i6.UserMembership():
        return 'UserMembership';
      case _i7.Category():
        return 'Category';
      case _i8.CommsPlan():
        return 'CommsPlan';
      case _i9.CommsPlanChange():
        return 'CommsPlanChange';
      case _i10.Greeting():
        return 'Greeting';
      case _i11.MapLayer():
        return 'MapLayer';
      case _i12.MapLayerChange():
        return 'MapLayerChange';
      case _i13.MapDataRestoreSummary():
        return 'MapDataRestoreSummary';
      case _i14.MapMarker():
        return 'MapMarker';
      case _i15.MapMarkerChange():
        return 'MapMarkerChange';
      case _i16.MapObjectAuditEvent():
        return 'MapObjectAuditEvent';
      case _i17.MarkerAttachment():
        return 'MarkerAttachment';
      case _i18.MarkerIconCatalogEntry():
        return 'MarkerIconCatalogEntry';
      case _i19.MarkerIconCategoryDefinition():
        return 'MarkerIconCategoryDefinition';
      case _i20.PmtilesFile():
        return 'PmtilesFile';
      case _i21.PmtilesFileGroupLink():
        return 'PmtilesFileGroupLink';
      case _i22.PmtilesGroup():
        return 'PmtilesGroup';
      case _i23.SeasonalOverlay():
        return 'SeasonalOverlay';
      case _i24.SeasonalOverlayChange():
        return 'SeasonalOverlayChange';
      case _i25.AppSettings():
        return 'AppSettings';
      case _i26.RestApiKey():
        return 'RestApiKey';
      case _i27.RestApiKeyCreated():
        return 'RestApiKeyCreated';
      case _i28.RestApiKeyInfo():
        return 'RestApiKeyInfo';
      case _i29.UserClientPreferences():
        return 'UserClientPreferences';
      case _i30.AppThemeDefinition():
        return 'AppThemeDefinition';
      case _i31.TideCoastalRegion():
        return 'TideCoastalRegion';
      case _i32.TideExtreme():
        return 'TideExtreme';
      case _i33.TidePackInfo():
        return 'TidePackInfo';
      case _i34.TideQueryResult():
        return 'TideQueryResult';
      case _i35.TideSample():
        return 'TideSample';
      case _i36.TideStationInfo():
        return 'TideStationInfo';
      case _i37.WatchLogEntry():
        return 'WatchLogEntry';
      case _i38.WatchLogEntryChange():
        return 'WatchLogEntryChange';
      case _i39.MapZone():
        return 'MapZone';
      case _i40.MapZoneChange():
        return 'MapZoneChange';
    }
    className = _i59.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i60.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'AccessRole') {
      return deserialize<_i2.AccessRole>(data['data']);
    }
    if (dataClassName == 'AccessRoleInfo') {
      return deserialize<_i3.AccessRoleInfo>(data['data']);
    }
    if (dataClassName == 'AccessSessionInfo') {
      return deserialize<_i4.AccessSessionInfo>(data['data']);
    }
    if (dataClassName == 'AccessUserInfo') {
      return deserialize<_i5.AccessUserInfo>(data['data']);
    }
    if (dataClassName == 'UserMembership') {
      return deserialize<_i6.UserMembership>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i7.Category>(data['data']);
    }
    if (dataClassName == 'CommsPlan') {
      return deserialize<_i8.CommsPlan>(data['data']);
    }
    if (dataClassName == 'CommsPlanChange') {
      return deserialize<_i9.CommsPlanChange>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i10.Greeting>(data['data']);
    }
    if (dataClassName == 'MapLayer') {
      return deserialize<_i11.MapLayer>(data['data']);
    }
    if (dataClassName == 'MapLayerChange') {
      return deserialize<_i12.MapLayerChange>(data['data']);
    }
    if (dataClassName == 'MapDataRestoreSummary') {
      return deserialize<_i13.MapDataRestoreSummary>(data['data']);
    }
    if (dataClassName == 'MapMarker') {
      return deserialize<_i14.MapMarker>(data['data']);
    }
    if (dataClassName == 'MapMarkerChange') {
      return deserialize<_i15.MapMarkerChange>(data['data']);
    }
    if (dataClassName == 'MapObjectAuditEvent') {
      return deserialize<_i16.MapObjectAuditEvent>(data['data']);
    }
    if (dataClassName == 'MarkerAttachment') {
      return deserialize<_i17.MarkerAttachment>(data['data']);
    }
    if (dataClassName == 'MarkerIconCatalogEntry') {
      return deserialize<_i18.MarkerIconCatalogEntry>(data['data']);
    }
    if (dataClassName == 'MarkerIconCategoryDefinition') {
      return deserialize<_i19.MarkerIconCategoryDefinition>(data['data']);
    }
    if (dataClassName == 'PmtilesFile') {
      return deserialize<_i20.PmtilesFile>(data['data']);
    }
    if (dataClassName == 'PmtilesFileGroupLink') {
      return deserialize<_i21.PmtilesFileGroupLink>(data['data']);
    }
    if (dataClassName == 'PmtilesGroup') {
      return deserialize<_i22.PmtilesGroup>(data['data']);
    }
    if (dataClassName == 'SeasonalOverlay') {
      return deserialize<_i23.SeasonalOverlay>(data['data']);
    }
    if (dataClassName == 'SeasonalOverlayChange') {
      return deserialize<_i24.SeasonalOverlayChange>(data['data']);
    }
    if (dataClassName == 'AppSettings') {
      return deserialize<_i25.AppSettings>(data['data']);
    }
    if (dataClassName == 'RestApiKey') {
      return deserialize<_i26.RestApiKey>(data['data']);
    }
    if (dataClassName == 'RestApiKeyCreated') {
      return deserialize<_i27.RestApiKeyCreated>(data['data']);
    }
    if (dataClassName == 'RestApiKeyInfo') {
      return deserialize<_i28.RestApiKeyInfo>(data['data']);
    }
    if (dataClassName == 'UserClientPreferences') {
      return deserialize<_i29.UserClientPreferences>(data['data']);
    }
    if (dataClassName == 'AppThemeDefinition') {
      return deserialize<_i30.AppThemeDefinition>(data['data']);
    }
    if (dataClassName == 'TideCoastalRegion') {
      return deserialize<_i31.TideCoastalRegion>(data['data']);
    }
    if (dataClassName == 'TideExtreme') {
      return deserialize<_i32.TideExtreme>(data['data']);
    }
    if (dataClassName == 'TidePackInfo') {
      return deserialize<_i33.TidePackInfo>(data['data']);
    }
    if (dataClassName == 'TideQueryResult') {
      return deserialize<_i34.TideQueryResult>(data['data']);
    }
    if (dataClassName == 'TideSample') {
      return deserialize<_i35.TideSample>(data['data']);
    }
    if (dataClassName == 'TideStationInfo') {
      return deserialize<_i36.TideStationInfo>(data['data']);
    }
    if (dataClassName == 'WatchLogEntry') {
      return deserialize<_i37.WatchLogEntry>(data['data']);
    }
    if (dataClassName == 'WatchLogEntryChange') {
      return deserialize<_i38.WatchLogEntryChange>(data['data']);
    }
    if (dataClassName == 'MapZone') {
      return deserialize<_i39.MapZone>(data['data']);
    }
    if (dataClassName == 'MapZoneChange') {
      return deserialize<_i40.MapZoneChange>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i59.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i60.Protocol().deserializeByClassName(data);
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
      return _i59.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i60.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
