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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'access/access_role.dart' as _i5;
import 'access/access_role_info.dart' as _i6;
import 'access/access_session_info.dart' as _i7;
import 'access/access_user_info.dart' as _i8;
import 'access/user_membership.dart' as _i9;
import 'categories/category.dart' as _i10;
import 'comms/comms_plan.dart' as _i11;
import 'comms/comms_plan_change.dart' as _i12;
import 'greetings/greeting.dart' as _i13;
import 'layers/map_layer.dart' as _i14;
import 'layers/map_layer_change.dart' as _i15;
import 'map/map_data_restore_summary.dart' as _i16;
import 'map/map_marker.dart' as _i17;
import 'map/map_marker_change.dart' as _i18;
import 'map/map_object_audit_event.dart' as _i19;
import 'markers/marker_attachment.dart' as _i20;
import 'markers/marker_icon_catalog_entry.dart' as _i21;
import 'markers/marker_icon_category_definition.dart' as _i22;
import 'pmtiles/pmtiles_file.dart' as _i23;
import 'pmtiles/pmtiles_file_group_link.dart' as _i24;
import 'pmtiles/pmtiles_group.dart' as _i25;
import 'seasonal_overlays/seasonal_overlay.dart' as _i26;
import 'seasonal_overlays/seasonal_overlay_change.dart' as _i27;
import 'settings/app_settings.dart' as _i28;
import 'settings/rest_api_key.dart' as _i29;
import 'settings/rest_api_key_created.dart' as _i30;
import 'settings/rest_api_key_info.dart' as _i31;
import 'settings/user_client_preferences.dart' as _i32;
import 'themes/app_theme_definition.dart' as _i33;
import 'tides/tide_coastal_region.dart' as _i34;
import 'tides/tide_extreme.dart' as _i35;
import 'tides/tide_pack_info.dart' as _i36;
import 'tides/tide_query_result.dart' as _i37;
import 'tides/tide_sample.dart' as _i38;
import 'tides/tide_station_info.dart' as _i39;
import 'watch_log/watch_log_entry.dart' as _i40;
import 'watch_log/watch_log_entry_change.dart' as _i41;
import 'zones/map_zone.dart' as _i42;
import 'zones/map_zone_change.dart' as _i43;
import 'package:wayfinder_server/src/generated/access/access_user_info.dart'
    as _i44;
import 'package:wayfinder_server/src/generated/access/access_role_info.dart'
    as _i45;
import 'package:wayfinder_server/src/generated/categories/category.dart'
    as _i46;
import 'package:wayfinder_server/src/generated/comms/comms_plan.dart' as _i47;
import 'package:wayfinder_server/src/generated/layers/map_layer.dart' as _i48;
import 'package:wayfinder_server/src/generated/map/map_marker.dart' as _i49;
import 'package:wayfinder_server/src/generated/markers/marker_attachment.dart'
    as _i50;
import 'package:wayfinder_server/src/generated/markers/marker_icon_catalog_entry.dart'
    as _i51;
import 'package:wayfinder_server/src/generated/markers/marker_icon_category_definition.dart'
    as _i52;
import 'package:wayfinder_server/src/generated/pmtiles/pmtiles_file.dart'
    as _i53;
import 'package:wayfinder_server/src/generated/pmtiles/pmtiles_group.dart'
    as _i54;
import 'package:wayfinder_server/src/generated/seasonal_overlays/seasonal_overlay.dart'
    as _i55;
import 'package:wayfinder_server/src/generated/settings/rest_api_key.dart'
    as _i56;
import 'package:wayfinder_server/src/generated/themes/app_theme_definition.dart'
    as _i57;
import 'package:wayfinder_server/src/generated/tides/tide_pack_info.dart'
    as _i58;
import 'package:wayfinder_server/src/generated/tides/tide_coastal_region.dart'
    as _i59;
import 'package:wayfinder_server/src/generated/watch_log/watch_log_entry.dart'
    as _i60;
import 'package:wayfinder_server/src/generated/zones/map_zone.dart' as _i61;
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

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'access_role',
      dartName: 'AccessRole',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'key',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'isSystem',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'permissionsJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'access_role_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'access_role_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_settings',
      dartName: 'AppSettings',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_settings_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'homeLatitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'homeLongitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'homeZoom',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'pmtilesStoragePath',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'measurementUnits',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'metric\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'angleDisplayFormat',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'decimal\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'bearingReference',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'true\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'circleSizeDisplay',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'radius\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'appTheme',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'light\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'appLocale',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'system\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'mapMarkerSizeScale',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '1.0',
        ),
        _i2.ColumnDefinition(
          name: 'mapViewportDebugBorder',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'mapTileBorderDebug',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'mapCompassRoseEnabled',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'mapMgrsGridEnabled',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'darkMapTilesInDarkMode',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'polygonSnapRightAngles',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'polygonSnap45Angles',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'mapMinZoom',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '2.0',
        ),
        _i2.ColumnDefinition(
          name: 'mapMaxZoom',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '18.0',
        ),
        _i2.ColumnDefinition(
          name: 'restApiKeyHash',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_settings_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_theme_definition',
      dartName: 'AppThemeDefinition',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'brightness',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'seedColor',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'overridesJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_theme_definition_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_theme_definition_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'category',
      dartName: 'Category',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'parentId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'category_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'category_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'comms_plan',
      dartName: 'CommsPlan',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'notes',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'timezoneIana',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'UTC\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'active',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'channelsJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'challengeTableJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'oneTimePadJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'cardOfTheDayJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'comms_plan_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'comms_plan_sort_order_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'comms_plan_active_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'active',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'map_layer',
      dartName: 'MapLayer',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'visible',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'map_layer_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'map_layer_sort_order_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'map_marker',
      dartName: 'MapMarker',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'notes',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'latitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'longitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'elevation',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'color',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'icon',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'visible',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'isTracking',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'trackZoneId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'weatherJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'inventoryJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'radioJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'checklistsJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'resourceType',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'layerId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'createdByAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedByAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedByUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'map_marker_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'map_marker_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_marker_layer_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'layerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_marker_resource_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'resourceType',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_marker_deleted_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'deletedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'map_object_audit_event',
      dartName: 'MapObjectAuditEvent',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'entityType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'entityId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'entityName',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'action',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'actorAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'actorUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'snapshotJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'map_object_audit_event_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'map_object_audit_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_object_audit_entity_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'entityType',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'map_zone',
      dartName: 'MapZone',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'color',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'borderColor',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'borderPattern',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fillColor',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'visible',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'geometryJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'layerId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'createdByAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedByAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedByUsername',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'map_zone_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'map_zone_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_zone_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'type',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_zone_layer_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'layerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'map_zone_deleted_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'deletedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'marker_attachment',
      dartName: 'MarkerAttachment',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'markerId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'fileName',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'contentType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sizeBytes',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'storageId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'addedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'marker_attachment_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'marker_attachment_marker_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'markerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'marker_attachment_storage_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'storageId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'marker_icon_catalog',
      dartName: 'MarkerIconCatalogEntry',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'key',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'label',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'category',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'custom\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'iconBackgroundColor',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'#FFFFFF\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'materialIcon',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'coloredAsset',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'glyphScale',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'hasCustomSvg',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'marker_icon_catalog_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'marker_icon_catalog_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'marker_icon_category',
      dartName: 'MarkerIconCategoryDefinition',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'key',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'label',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'marker_icon_category_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'marker_icon_category_key_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'pmtiles_file',
      dartName: 'PmtilesFile',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sizeBytes',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'addedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'minZoom',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'maxZoom',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'minLatitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'minLongitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'maxLatitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'maxLongitude',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'pmtiles_file_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'pmtiles_file_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'pmtiles_file_group',
      dartName: 'PmtilesFileGroupLink',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'fileId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'groupId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'pmtiles_file_group_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'pmtiles_file_group_file_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'fileId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'pmtiles_file_group_group_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'groupId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'pmtiles_file_group_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'fileId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'groupId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'pmtiles_group',
      dartName: 'PmtilesGroup',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'showOnMap',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'pmtiles_group_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'pmtiles_group_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'rest_api_key',
      dartName: 'RestApiKey',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'keyHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'keyPreview',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'rest_api_key_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'rest_api_key_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'seasonal_overlay',
      dartName: 'SeasonalOverlay',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'color',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'borderColor',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fillColor',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'visible',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'notes',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'dateMode',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'dateWindowsJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'geometryJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'seasonal_overlay_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'seasonal_overlay_sort_order_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'user_client_preferences',
      dartName: 'UserClientPreferences',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'measurementUnits',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'metric\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'angleDisplayFormat',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'decimal\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'bearingReference',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'true\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'circleSizeDisplay',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'radius\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'appTheme',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'light\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'appLocale',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'system\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'mapMarkerSizeScale',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '1.0',
        ),
        _i2.ColumnDefinition(
          name: 'mapViewportDebugBorder',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'mapTileBorderDebug',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'mapCompassRoseEnabled',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'mapMgrsGridEnabled',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'darkMapTilesInDarkMode',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'polygonSnapRightAngles',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'polygonSnap45Angles',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'user_client_preferences_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_client_preferences_auth_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'user_membership',
      dartName: 'UserMembership',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'roleId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'displayName',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'user_membership_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_membership_auth_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'user_membership_email_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'watch_log_entry',
      dartName: 'WatchLogEntry',
      schema: 'public',
      module: 'wayfinder',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'gen_random_uuid()',
        ),
        _i2.ColumnDefinition(
          name: 'occurredAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'author',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'severity',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'text',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'markerId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'zoneId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'watch_log_entry_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'watch_log_occurred_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'occurredAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'watch_log_marker_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'markerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'watch_log_zone_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'zoneId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

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

    if (t == _i5.AccessRole) {
      return _i5.AccessRole.fromJson(data) as T;
    }
    if (t == _i6.AccessRoleInfo) {
      return _i6.AccessRoleInfo.fromJson(data) as T;
    }
    if (t == _i7.AccessSessionInfo) {
      return _i7.AccessSessionInfo.fromJson(data) as T;
    }
    if (t == _i8.AccessUserInfo) {
      return _i8.AccessUserInfo.fromJson(data) as T;
    }
    if (t == _i9.UserMembership) {
      return _i9.UserMembership.fromJson(data) as T;
    }
    if (t == _i10.Category) {
      return _i10.Category.fromJson(data) as T;
    }
    if (t == _i11.CommsPlan) {
      return _i11.CommsPlan.fromJson(data) as T;
    }
    if (t == _i12.CommsPlanChange) {
      return _i12.CommsPlanChange.fromJson(data) as T;
    }
    if (t == _i13.Greeting) {
      return _i13.Greeting.fromJson(data) as T;
    }
    if (t == _i14.MapLayer) {
      return _i14.MapLayer.fromJson(data) as T;
    }
    if (t == _i15.MapLayerChange) {
      return _i15.MapLayerChange.fromJson(data) as T;
    }
    if (t == _i16.MapDataRestoreSummary) {
      return _i16.MapDataRestoreSummary.fromJson(data) as T;
    }
    if (t == _i17.MapMarker) {
      return _i17.MapMarker.fromJson(data) as T;
    }
    if (t == _i18.MapMarkerChange) {
      return _i18.MapMarkerChange.fromJson(data) as T;
    }
    if (t == _i19.MapObjectAuditEvent) {
      return _i19.MapObjectAuditEvent.fromJson(data) as T;
    }
    if (t == _i20.MarkerAttachment) {
      return _i20.MarkerAttachment.fromJson(data) as T;
    }
    if (t == _i21.MarkerIconCatalogEntry) {
      return _i21.MarkerIconCatalogEntry.fromJson(data) as T;
    }
    if (t == _i22.MarkerIconCategoryDefinition) {
      return _i22.MarkerIconCategoryDefinition.fromJson(data) as T;
    }
    if (t == _i23.PmtilesFile) {
      return _i23.PmtilesFile.fromJson(data) as T;
    }
    if (t == _i24.PmtilesFileGroupLink) {
      return _i24.PmtilesFileGroupLink.fromJson(data) as T;
    }
    if (t == _i25.PmtilesGroup) {
      return _i25.PmtilesGroup.fromJson(data) as T;
    }
    if (t == _i26.SeasonalOverlay) {
      return _i26.SeasonalOverlay.fromJson(data) as T;
    }
    if (t == _i27.SeasonalOverlayChange) {
      return _i27.SeasonalOverlayChange.fromJson(data) as T;
    }
    if (t == _i28.AppSettings) {
      return _i28.AppSettings.fromJson(data) as T;
    }
    if (t == _i29.RestApiKey) {
      return _i29.RestApiKey.fromJson(data) as T;
    }
    if (t == _i30.RestApiKeyCreated) {
      return _i30.RestApiKeyCreated.fromJson(data) as T;
    }
    if (t == _i31.RestApiKeyInfo) {
      return _i31.RestApiKeyInfo.fromJson(data) as T;
    }
    if (t == _i32.UserClientPreferences) {
      return _i32.UserClientPreferences.fromJson(data) as T;
    }
    if (t == _i33.AppThemeDefinition) {
      return _i33.AppThemeDefinition.fromJson(data) as T;
    }
    if (t == _i34.TideCoastalRegion) {
      return _i34.TideCoastalRegion.fromJson(data) as T;
    }
    if (t == _i35.TideExtreme) {
      return _i35.TideExtreme.fromJson(data) as T;
    }
    if (t == _i36.TidePackInfo) {
      return _i36.TidePackInfo.fromJson(data) as T;
    }
    if (t == _i37.TideQueryResult) {
      return _i37.TideQueryResult.fromJson(data) as T;
    }
    if (t == _i38.TideSample) {
      return _i38.TideSample.fromJson(data) as T;
    }
    if (t == _i39.TideStationInfo) {
      return _i39.TideStationInfo.fromJson(data) as T;
    }
    if (t == _i40.WatchLogEntry) {
      return _i40.WatchLogEntry.fromJson(data) as T;
    }
    if (t == _i41.WatchLogEntryChange) {
      return _i41.WatchLogEntryChange.fromJson(data) as T;
    }
    if (t == _i42.MapZone) {
      return _i42.MapZone.fromJson(data) as T;
    }
    if (t == _i43.MapZoneChange) {
      return _i43.MapZoneChange.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AccessRole?>()) {
      return (data != null ? _i5.AccessRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AccessRoleInfo?>()) {
      return (data != null ? _i6.AccessRoleInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AccessSessionInfo?>()) {
      return (data != null ? _i7.AccessSessionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AccessUserInfo?>()) {
      return (data != null ? _i8.AccessUserInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.UserMembership?>()) {
      return (data != null ? _i9.UserMembership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Category?>()) {
      return (data != null ? _i10.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.CommsPlan?>()) {
      return (data != null ? _i11.CommsPlan.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.CommsPlanChange?>()) {
      return (data != null ? _i12.CommsPlanChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Greeting?>()) {
      return (data != null ? _i13.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.MapLayer?>()) {
      return (data != null ? _i14.MapLayer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.MapLayerChange?>()) {
      return (data != null ? _i15.MapLayerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.MapDataRestoreSummary?>()) {
      return (data != null ? _i16.MapDataRestoreSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.MapMarker?>()) {
      return (data != null ? _i17.MapMarker.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.MapMarkerChange?>()) {
      return (data != null ? _i18.MapMarkerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.MapObjectAuditEvent?>()) {
      return (data != null ? _i19.MapObjectAuditEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.MarkerAttachment?>()) {
      return (data != null ? _i20.MarkerAttachment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.MarkerIconCatalogEntry?>()) {
      return (data != null ? _i21.MarkerIconCatalogEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.MarkerIconCategoryDefinition?>()) {
      return (data != null
              ? _i22.MarkerIconCategoryDefinition.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i23.PmtilesFile?>()) {
      return (data != null ? _i23.PmtilesFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.PmtilesFileGroupLink?>()) {
      return (data != null ? _i24.PmtilesFileGroupLink.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.PmtilesGroup?>()) {
      return (data != null ? _i25.PmtilesGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.SeasonalOverlay?>()) {
      return (data != null ? _i26.SeasonalOverlay.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.SeasonalOverlayChange?>()) {
      return (data != null ? _i27.SeasonalOverlayChange.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.AppSettings?>()) {
      return (data != null ? _i28.AppSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.RestApiKey?>()) {
      return (data != null ? _i29.RestApiKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.RestApiKeyCreated?>()) {
      return (data != null ? _i30.RestApiKeyCreated.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.RestApiKeyInfo?>()) {
      return (data != null ? _i31.RestApiKeyInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.UserClientPreferences?>()) {
      return (data != null ? _i32.UserClientPreferences.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.AppThemeDefinition?>()) {
      return (data != null ? _i33.AppThemeDefinition.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.TideCoastalRegion?>()) {
      return (data != null ? _i34.TideCoastalRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.TideExtreme?>()) {
      return (data != null ? _i35.TideExtreme.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.TidePackInfo?>()) {
      return (data != null ? _i36.TidePackInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.TideQueryResult?>()) {
      return (data != null ? _i37.TideQueryResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.TideSample?>()) {
      return (data != null ? _i38.TideSample.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.TideStationInfo?>()) {
      return (data != null ? _i39.TideStationInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.WatchLogEntry?>()) {
      return (data != null ? _i40.WatchLogEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.WatchLogEntryChange?>()) {
      return (data != null ? _i41.WatchLogEntryChange.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.MapZone?>()) {
      return (data != null ? _i42.MapZone.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.MapZoneChange?>()) {
      return (data != null ? _i43.MapZoneChange.fromJson(data) : null) as T;
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
    if (t == List<_i38.TideSample>) {
      return (data as List).map((e) => deserialize<_i38.TideSample>(e)).toList()
          as T;
    }
    if (t == List<_i35.TideExtreme>) {
      return (data as List)
              .map((e) => deserialize<_i35.TideExtreme>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i44.AccessUserInfo>) {
      return (data as List)
              .map((e) => deserialize<_i44.AccessUserInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.AccessRoleInfo>) {
      return (data as List)
              .map((e) => deserialize<_i45.AccessRoleInfo>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i46.Category>) {
      return (data as List).map((e) => deserialize<_i46.Category>(e)).toList()
          as T;
    }
    if (t == List<_i47.CommsPlan>) {
      return (data as List).map((e) => deserialize<_i47.CommsPlan>(e)).toList()
          as T;
    }
    if (t == List<_i48.MapLayer>) {
      return (data as List).map((e) => deserialize<_i48.MapLayer>(e)).toList()
          as T;
    }
    if (t == List<_i49.MapMarker>) {
      return (data as List).map((e) => deserialize<_i49.MapMarker>(e)).toList()
          as T;
    }
    if (t == List<_i50.MarkerAttachment>) {
      return (data as List)
              .map((e) => deserialize<_i50.MarkerAttachment>(e))
              .toList()
          as T;
    }
    if (t == List<_i51.MarkerIconCatalogEntry>) {
      return (data as List)
              .map((e) => deserialize<_i51.MarkerIconCatalogEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i52.MarkerIconCategoryDefinition>) {
      return (data as List)
              .map((e) => deserialize<_i52.MarkerIconCategoryDefinition>(e))
              .toList()
          as T;
    }
    if (t == List<_i53.PmtilesFile>) {
      return (data as List)
              .map((e) => deserialize<_i53.PmtilesFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i54.PmtilesGroup>) {
      return (data as List)
              .map((e) => deserialize<_i54.PmtilesGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.SeasonalOverlay>) {
      return (data as List)
              .map((e) => deserialize<_i55.SeasonalOverlay>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.RestApiKey>) {
      return (data as List).map((e) => deserialize<_i56.RestApiKey>(e)).toList()
          as T;
    }
    if (t == List<_i57.AppThemeDefinition>) {
      return (data as List)
              .map((e) => deserialize<_i57.AppThemeDefinition>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.TidePackInfo>) {
      return (data as List)
              .map((e) => deserialize<_i58.TidePackInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i59.TideCoastalRegion>) {
      return (data as List)
              .map((e) => deserialize<_i59.TideCoastalRegion>(e))
              .toList()
          as T;
    }
    if (t == List<_i60.WatchLogEntry>) {
      return (data as List)
              .map((e) => deserialize<_i60.WatchLogEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i61.MapZone>) {
      return (data as List).map((e) => deserialize<_i61.MapZone>(e)).toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AccessRole => 'AccessRole',
      _i6.AccessRoleInfo => 'AccessRoleInfo',
      _i7.AccessSessionInfo => 'AccessSessionInfo',
      _i8.AccessUserInfo => 'AccessUserInfo',
      _i9.UserMembership => 'UserMembership',
      _i10.Category => 'Category',
      _i11.CommsPlan => 'CommsPlan',
      _i12.CommsPlanChange => 'CommsPlanChange',
      _i13.Greeting => 'Greeting',
      _i14.MapLayer => 'MapLayer',
      _i15.MapLayerChange => 'MapLayerChange',
      _i16.MapDataRestoreSummary => 'MapDataRestoreSummary',
      _i17.MapMarker => 'MapMarker',
      _i18.MapMarkerChange => 'MapMarkerChange',
      _i19.MapObjectAuditEvent => 'MapObjectAuditEvent',
      _i20.MarkerAttachment => 'MarkerAttachment',
      _i21.MarkerIconCatalogEntry => 'MarkerIconCatalogEntry',
      _i22.MarkerIconCategoryDefinition => 'MarkerIconCategoryDefinition',
      _i23.PmtilesFile => 'PmtilesFile',
      _i24.PmtilesFileGroupLink => 'PmtilesFileGroupLink',
      _i25.PmtilesGroup => 'PmtilesGroup',
      _i26.SeasonalOverlay => 'SeasonalOverlay',
      _i27.SeasonalOverlayChange => 'SeasonalOverlayChange',
      _i28.AppSettings => 'AppSettings',
      _i29.RestApiKey => 'RestApiKey',
      _i30.RestApiKeyCreated => 'RestApiKeyCreated',
      _i31.RestApiKeyInfo => 'RestApiKeyInfo',
      _i32.UserClientPreferences => 'UserClientPreferences',
      _i33.AppThemeDefinition => 'AppThemeDefinition',
      _i34.TideCoastalRegion => 'TideCoastalRegion',
      _i35.TideExtreme => 'TideExtreme',
      _i36.TidePackInfo => 'TidePackInfo',
      _i37.TideQueryResult => 'TideQueryResult',
      _i38.TideSample => 'TideSample',
      _i39.TideStationInfo => 'TideStationInfo',
      _i40.WatchLogEntry => 'WatchLogEntry',
      _i41.WatchLogEntryChange => 'WatchLogEntryChange',
      _i42.MapZone => 'MapZone',
      _i43.MapZoneChange => 'MapZoneChange',
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
      case _i5.AccessRole():
        return 'AccessRole';
      case _i6.AccessRoleInfo():
        return 'AccessRoleInfo';
      case _i7.AccessSessionInfo():
        return 'AccessSessionInfo';
      case _i8.AccessUserInfo():
        return 'AccessUserInfo';
      case _i9.UserMembership():
        return 'UserMembership';
      case _i10.Category():
        return 'Category';
      case _i11.CommsPlan():
        return 'CommsPlan';
      case _i12.CommsPlanChange():
        return 'CommsPlanChange';
      case _i13.Greeting():
        return 'Greeting';
      case _i14.MapLayer():
        return 'MapLayer';
      case _i15.MapLayerChange():
        return 'MapLayerChange';
      case _i16.MapDataRestoreSummary():
        return 'MapDataRestoreSummary';
      case _i17.MapMarker():
        return 'MapMarker';
      case _i18.MapMarkerChange():
        return 'MapMarkerChange';
      case _i19.MapObjectAuditEvent():
        return 'MapObjectAuditEvent';
      case _i20.MarkerAttachment():
        return 'MarkerAttachment';
      case _i21.MarkerIconCatalogEntry():
        return 'MarkerIconCatalogEntry';
      case _i22.MarkerIconCategoryDefinition():
        return 'MarkerIconCategoryDefinition';
      case _i23.PmtilesFile():
        return 'PmtilesFile';
      case _i24.PmtilesFileGroupLink():
        return 'PmtilesFileGroupLink';
      case _i25.PmtilesGroup():
        return 'PmtilesGroup';
      case _i26.SeasonalOverlay():
        return 'SeasonalOverlay';
      case _i27.SeasonalOverlayChange():
        return 'SeasonalOverlayChange';
      case _i28.AppSettings():
        return 'AppSettings';
      case _i29.RestApiKey():
        return 'RestApiKey';
      case _i30.RestApiKeyCreated():
        return 'RestApiKeyCreated';
      case _i31.RestApiKeyInfo():
        return 'RestApiKeyInfo';
      case _i32.UserClientPreferences():
        return 'UserClientPreferences';
      case _i33.AppThemeDefinition():
        return 'AppThemeDefinition';
      case _i34.TideCoastalRegion():
        return 'TideCoastalRegion';
      case _i35.TideExtreme():
        return 'TideExtreme';
      case _i36.TidePackInfo():
        return 'TidePackInfo';
      case _i37.TideQueryResult():
        return 'TideQueryResult';
      case _i38.TideSample():
        return 'TideSample';
      case _i39.TideStationInfo():
        return 'TideStationInfo';
      case _i40.WatchLogEntry():
        return 'WatchLogEntry';
      case _i41.WatchLogEntryChange():
        return 'WatchLogEntryChange';
      case _i42.MapZone():
        return 'MapZone';
      case _i43.MapZoneChange():
        return 'MapZoneChange';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
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
      return deserialize<_i5.AccessRole>(data['data']);
    }
    if (dataClassName == 'AccessRoleInfo') {
      return deserialize<_i6.AccessRoleInfo>(data['data']);
    }
    if (dataClassName == 'AccessSessionInfo') {
      return deserialize<_i7.AccessSessionInfo>(data['data']);
    }
    if (dataClassName == 'AccessUserInfo') {
      return deserialize<_i8.AccessUserInfo>(data['data']);
    }
    if (dataClassName == 'UserMembership') {
      return deserialize<_i9.UserMembership>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i10.Category>(data['data']);
    }
    if (dataClassName == 'CommsPlan') {
      return deserialize<_i11.CommsPlan>(data['data']);
    }
    if (dataClassName == 'CommsPlanChange') {
      return deserialize<_i12.CommsPlanChange>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i13.Greeting>(data['data']);
    }
    if (dataClassName == 'MapLayer') {
      return deserialize<_i14.MapLayer>(data['data']);
    }
    if (dataClassName == 'MapLayerChange') {
      return deserialize<_i15.MapLayerChange>(data['data']);
    }
    if (dataClassName == 'MapDataRestoreSummary') {
      return deserialize<_i16.MapDataRestoreSummary>(data['data']);
    }
    if (dataClassName == 'MapMarker') {
      return deserialize<_i17.MapMarker>(data['data']);
    }
    if (dataClassName == 'MapMarkerChange') {
      return deserialize<_i18.MapMarkerChange>(data['data']);
    }
    if (dataClassName == 'MapObjectAuditEvent') {
      return deserialize<_i19.MapObjectAuditEvent>(data['data']);
    }
    if (dataClassName == 'MarkerAttachment') {
      return deserialize<_i20.MarkerAttachment>(data['data']);
    }
    if (dataClassName == 'MarkerIconCatalogEntry') {
      return deserialize<_i21.MarkerIconCatalogEntry>(data['data']);
    }
    if (dataClassName == 'MarkerIconCategoryDefinition') {
      return deserialize<_i22.MarkerIconCategoryDefinition>(data['data']);
    }
    if (dataClassName == 'PmtilesFile') {
      return deserialize<_i23.PmtilesFile>(data['data']);
    }
    if (dataClassName == 'PmtilesFileGroupLink') {
      return deserialize<_i24.PmtilesFileGroupLink>(data['data']);
    }
    if (dataClassName == 'PmtilesGroup') {
      return deserialize<_i25.PmtilesGroup>(data['data']);
    }
    if (dataClassName == 'SeasonalOverlay') {
      return deserialize<_i26.SeasonalOverlay>(data['data']);
    }
    if (dataClassName == 'SeasonalOverlayChange') {
      return deserialize<_i27.SeasonalOverlayChange>(data['data']);
    }
    if (dataClassName == 'AppSettings') {
      return deserialize<_i28.AppSettings>(data['data']);
    }
    if (dataClassName == 'RestApiKey') {
      return deserialize<_i29.RestApiKey>(data['data']);
    }
    if (dataClassName == 'RestApiKeyCreated') {
      return deserialize<_i30.RestApiKeyCreated>(data['data']);
    }
    if (dataClassName == 'RestApiKeyInfo') {
      return deserialize<_i31.RestApiKeyInfo>(data['data']);
    }
    if (dataClassName == 'UserClientPreferences') {
      return deserialize<_i32.UserClientPreferences>(data['data']);
    }
    if (dataClassName == 'AppThemeDefinition') {
      return deserialize<_i33.AppThemeDefinition>(data['data']);
    }
    if (dataClassName == 'TideCoastalRegion') {
      return deserialize<_i34.TideCoastalRegion>(data['data']);
    }
    if (dataClassName == 'TideExtreme') {
      return deserialize<_i35.TideExtreme>(data['data']);
    }
    if (dataClassName == 'TidePackInfo') {
      return deserialize<_i36.TidePackInfo>(data['data']);
    }
    if (dataClassName == 'TideQueryResult') {
      return deserialize<_i37.TideQueryResult>(data['data']);
    }
    if (dataClassName == 'TideSample') {
      return deserialize<_i38.TideSample>(data['data']);
    }
    if (dataClassName == 'TideStationInfo') {
      return deserialize<_i39.TideStationInfo>(data['data']);
    }
    if (dataClassName == 'WatchLogEntry') {
      return deserialize<_i40.WatchLogEntry>(data['data']);
    }
    if (dataClassName == 'WatchLogEntryChange') {
      return deserialize<_i41.WatchLogEntryChange>(data['data']);
    }
    if (dataClassName == 'MapZone') {
      return deserialize<_i42.MapZone>(data['data']);
    }
    if (dataClassName == 'MapZoneChange') {
      return deserialize<_i43.MapZoneChange>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.AccessRole:
        return _i5.AccessRole.t;
      case _i9.UserMembership:
        return _i9.UserMembership.t;
      case _i10.Category:
        return _i10.Category.t;
      case _i11.CommsPlan:
        return _i11.CommsPlan.t;
      case _i14.MapLayer:
        return _i14.MapLayer.t;
      case _i17.MapMarker:
        return _i17.MapMarker.t;
      case _i19.MapObjectAuditEvent:
        return _i19.MapObjectAuditEvent.t;
      case _i20.MarkerAttachment:
        return _i20.MarkerAttachment.t;
      case _i21.MarkerIconCatalogEntry:
        return _i21.MarkerIconCatalogEntry.t;
      case _i22.MarkerIconCategoryDefinition:
        return _i22.MarkerIconCategoryDefinition.t;
      case _i23.PmtilesFile:
        return _i23.PmtilesFile.t;
      case _i24.PmtilesFileGroupLink:
        return _i24.PmtilesFileGroupLink.t;
      case _i25.PmtilesGroup:
        return _i25.PmtilesGroup.t;
      case _i26.SeasonalOverlay:
        return _i26.SeasonalOverlay.t;
      case _i28.AppSettings:
        return _i28.AppSettings.t;
      case _i29.RestApiKey:
        return _i29.RestApiKey.t;
      case _i32.UserClientPreferences:
        return _i32.UserClientPreferences.t;
      case _i33.AppThemeDefinition:
        return _i33.AppThemeDefinition.t;
      case _i40.WatchLogEntry:
        return _i40.WatchLogEntry.t;
      case _i42.MapZone:
        return _i42.MapZone.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'wayfinder';

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
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
