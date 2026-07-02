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
import 'categories/category.dart' as _i5;
import 'greetings/greeting.dart' as _i6;
import 'layers/map_layer.dart' as _i7;
import 'layers/map_layer_change.dart' as _i8;
import 'map/map_data_restore_summary.dart' as _i9;
import 'map/map_marker.dart' as _i10;
import 'map/map_marker_change.dart' as _i11;
import 'pmtiles/pmtiles_file.dart' as _i12;
import 'pmtiles/pmtiles_file_group_link.dart' as _i13;
import 'pmtiles/pmtiles_group.dart' as _i14;
import 'settings/app_settings.dart' as _i15;
import 'settings/rest_api_key.dart' as _i16;
import 'settings/rest_api_key_created.dart' as _i17;
import 'settings/rest_api_key_info.dart' as _i18;
import 'zones/map_zone.dart' as _i19;
import 'package:wayfinder_server/src/generated/categories/category.dart'
    as _i20;
import 'package:wayfinder_server/src/generated/layers/map_layer.dart' as _i21;
import 'package:wayfinder_server/src/generated/map/map_marker.dart' as _i22;
import 'package:wayfinder_server/src/generated/pmtiles/pmtiles_file.dart'
    as _i23;
import 'package:wayfinder_server/src/generated/pmtiles/pmtiles_group.dart'
    as _i24;
import 'package:wayfinder_server/src/generated/settings/rest_api_key.dart'
    as _i25;
import 'package:wayfinder_server/src/generated/zones/map_zone.dart' as _i26;
export 'categories/category.dart';
export 'greetings/greeting.dart';
export 'layers/map_layer.dart';
export 'layers/map_layer_change.dart';
export 'map/map_data_restore_summary.dart';
export 'map/map_marker.dart';
export 'map/map_marker_change.dart';
export 'pmtiles/pmtiles_file.dart';
export 'pmtiles/pmtiles_file_group_link.dart';
export 'pmtiles/pmtiles_group.dart';
export 'settings/app_settings.dart';
export 'settings/rest_api_key.dart';
export 'settings/rest_api_key_created.dart';
export 'settings/rest_api_key_info.dart';
export 'zones/map_zone.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
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
          name: 'layerId',
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

    if (t == _i5.Category) {
      return _i5.Category.fromJson(data) as T;
    }
    if (t == _i6.Greeting) {
      return _i6.Greeting.fromJson(data) as T;
    }
    if (t == _i7.MapLayer) {
      return _i7.MapLayer.fromJson(data) as T;
    }
    if (t == _i8.MapLayerChange) {
      return _i8.MapLayerChange.fromJson(data) as T;
    }
    if (t == _i9.MapDataRestoreSummary) {
      return _i9.MapDataRestoreSummary.fromJson(data) as T;
    }
    if (t == _i10.MapMarker) {
      return _i10.MapMarker.fromJson(data) as T;
    }
    if (t == _i11.MapMarkerChange) {
      return _i11.MapMarkerChange.fromJson(data) as T;
    }
    if (t == _i12.PmtilesFile) {
      return _i12.PmtilesFile.fromJson(data) as T;
    }
    if (t == _i13.PmtilesFileGroupLink) {
      return _i13.PmtilesFileGroupLink.fromJson(data) as T;
    }
    if (t == _i14.PmtilesGroup) {
      return _i14.PmtilesGroup.fromJson(data) as T;
    }
    if (t == _i15.AppSettings) {
      return _i15.AppSettings.fromJson(data) as T;
    }
    if (t == _i16.RestApiKey) {
      return _i16.RestApiKey.fromJson(data) as T;
    }
    if (t == _i17.RestApiKeyCreated) {
      return _i17.RestApiKeyCreated.fromJson(data) as T;
    }
    if (t == _i18.RestApiKeyInfo) {
      return _i18.RestApiKeyInfo.fromJson(data) as T;
    }
    if (t == _i19.MapZone) {
      return _i19.MapZone.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.Category?>()) {
      return (data != null ? _i5.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Greeting?>()) {
      return (data != null ? _i6.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MapLayer?>()) {
      return (data != null ? _i7.MapLayer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MapLayerChange?>()) {
      return (data != null ? _i8.MapLayerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.MapDataRestoreSummary?>()) {
      return (data != null ? _i9.MapDataRestoreSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.MapMarker?>()) {
      return (data != null ? _i10.MapMarker.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MapMarkerChange?>()) {
      return (data != null ? _i11.MapMarkerChange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PmtilesFile?>()) {
      return (data != null ? _i12.PmtilesFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.PmtilesFileGroupLink?>()) {
      return (data != null ? _i13.PmtilesFileGroupLink.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.PmtilesGroup?>()) {
      return (data != null ? _i14.PmtilesGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.AppSettings?>()) {
      return (data != null ? _i15.AppSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.RestApiKey?>()) {
      return (data != null ? _i16.RestApiKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.RestApiKeyCreated?>()) {
      return (data != null ? _i17.RestApiKeyCreated.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.RestApiKeyInfo?>()) {
      return (data != null ? _i18.RestApiKeyInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.MapZone?>()) {
      return (data != null ? _i19.MapZone.fromJson(data) : null) as T;
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
    if (t == List<_i20.Category>) {
      return (data as List).map((e) => deserialize<_i20.Category>(e)).toList()
          as T;
    }
    if (t == List<_i21.MapLayer>) {
      return (data as List).map((e) => deserialize<_i21.MapLayer>(e)).toList()
          as T;
    }
    if (t == List<_i22.MapMarker>) {
      return (data as List).map((e) => deserialize<_i22.MapMarker>(e)).toList()
          as T;
    }
    if (t == List<_i23.PmtilesFile>) {
      return (data as List)
              .map((e) => deserialize<_i23.PmtilesFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.PmtilesGroup>) {
      return (data as List)
              .map((e) => deserialize<_i24.PmtilesGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.RestApiKey>) {
      return (data as List).map((e) => deserialize<_i25.RestApiKey>(e)).toList()
          as T;
    }
    if (t == List<_i26.MapZone>) {
      return (data as List).map((e) => deserialize<_i26.MapZone>(e)).toList()
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
      _i5.Category => 'Category',
      _i6.Greeting => 'Greeting',
      _i7.MapLayer => 'MapLayer',
      _i8.MapLayerChange => 'MapLayerChange',
      _i9.MapDataRestoreSummary => 'MapDataRestoreSummary',
      _i10.MapMarker => 'MapMarker',
      _i11.MapMarkerChange => 'MapMarkerChange',
      _i12.PmtilesFile => 'PmtilesFile',
      _i13.PmtilesFileGroupLink => 'PmtilesFileGroupLink',
      _i14.PmtilesGroup => 'PmtilesGroup',
      _i15.AppSettings => 'AppSettings',
      _i16.RestApiKey => 'RestApiKey',
      _i17.RestApiKeyCreated => 'RestApiKeyCreated',
      _i18.RestApiKeyInfo => 'RestApiKeyInfo',
      _i19.MapZone => 'MapZone',
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
      case _i5.Category():
        return 'Category';
      case _i6.Greeting():
        return 'Greeting';
      case _i7.MapLayer():
        return 'MapLayer';
      case _i8.MapLayerChange():
        return 'MapLayerChange';
      case _i9.MapDataRestoreSummary():
        return 'MapDataRestoreSummary';
      case _i10.MapMarker():
        return 'MapMarker';
      case _i11.MapMarkerChange():
        return 'MapMarkerChange';
      case _i12.PmtilesFile():
        return 'PmtilesFile';
      case _i13.PmtilesFileGroupLink():
        return 'PmtilesFileGroupLink';
      case _i14.PmtilesGroup():
        return 'PmtilesGroup';
      case _i15.AppSettings():
        return 'AppSettings';
      case _i16.RestApiKey():
        return 'RestApiKey';
      case _i17.RestApiKeyCreated():
        return 'RestApiKeyCreated';
      case _i18.RestApiKeyInfo():
        return 'RestApiKeyInfo';
      case _i19.MapZone():
        return 'MapZone';
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
    if (dataClassName == 'Category') {
      return deserialize<_i5.Category>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i6.Greeting>(data['data']);
    }
    if (dataClassName == 'MapLayer') {
      return deserialize<_i7.MapLayer>(data['data']);
    }
    if (dataClassName == 'MapLayerChange') {
      return deserialize<_i8.MapLayerChange>(data['data']);
    }
    if (dataClassName == 'MapDataRestoreSummary') {
      return deserialize<_i9.MapDataRestoreSummary>(data['data']);
    }
    if (dataClassName == 'MapMarker') {
      return deserialize<_i10.MapMarker>(data['data']);
    }
    if (dataClassName == 'MapMarkerChange') {
      return deserialize<_i11.MapMarkerChange>(data['data']);
    }
    if (dataClassName == 'PmtilesFile') {
      return deserialize<_i12.PmtilesFile>(data['data']);
    }
    if (dataClassName == 'PmtilesFileGroupLink') {
      return deserialize<_i13.PmtilesFileGroupLink>(data['data']);
    }
    if (dataClassName == 'PmtilesGroup') {
      return deserialize<_i14.PmtilesGroup>(data['data']);
    }
    if (dataClassName == 'AppSettings') {
      return deserialize<_i15.AppSettings>(data['data']);
    }
    if (dataClassName == 'RestApiKey') {
      return deserialize<_i16.RestApiKey>(data['data']);
    }
    if (dataClassName == 'RestApiKeyCreated') {
      return deserialize<_i17.RestApiKeyCreated>(data['data']);
    }
    if (dataClassName == 'RestApiKeyInfo') {
      return deserialize<_i18.RestApiKeyInfo>(data['data']);
    }
    if (dataClassName == 'MapZone') {
      return deserialize<_i19.MapZone>(data['data']);
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
      case _i5.Category:
        return _i5.Category.t;
      case _i7.MapLayer:
        return _i7.MapLayer.t;
      case _i10.MapMarker:
        return _i10.MapMarker.t;
      case _i12.PmtilesFile:
        return _i12.PmtilesFile.t;
      case _i13.PmtilesFileGroupLink:
        return _i13.PmtilesFileGroupLink.t;
      case _i14.PmtilesGroup:
        return _i14.PmtilesGroup.t;
      case _i15.AppSettings:
        return _i15.AppSettings.t;
      case _i16.RestApiKey:
        return _i16.RestApiKey.t;
      case _i19.MapZone:
        return _i19.MapZone.t;
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
