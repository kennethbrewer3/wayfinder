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

abstract class UserClientPreferences
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  UserClientPreferences._({
    _i1.UuidValue? id,
    required this.authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       measurementUnits = measurementUnits ?? 'metric',
       angleDisplayFormat = angleDisplayFormat ?? 'decimal',
       bearingReference = bearingReference ?? 'true',
       circleSizeDisplay = circleSizeDisplay ?? 'radius',
       appTheme = appTheme ?? 'light',
       appLocale = appLocale ?? 'system',
       mapMarkerSizeScale = mapMarkerSizeScale ?? 1.0,
       mapViewportDebugBorder = mapViewportDebugBorder ?? false,
       mapTileBorderDebug = mapTileBorderDebug ?? false,
       mapCompassRoseEnabled = mapCompassRoseEnabled ?? true,
       mapMgrsGridEnabled = mapMgrsGridEnabled ?? false,
       darkMapTilesInDarkMode = darkMapTilesInDarkMode ?? true,
       polygonSnapRightAngles = polygonSnapRightAngles ?? true,
       polygonSnap45Angles = polygonSnap45Angles ?? false;

  factory UserClientPreferences({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    required DateTime updatedAt,
  }) = _UserClientPreferencesImpl;

  factory UserClientPreferences.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UserClientPreferences(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      measurementUnits: jsonSerialization['measurementUnits'] as String?,
      angleDisplayFormat: jsonSerialization['angleDisplayFormat'] as String?,
      bearingReference: jsonSerialization['bearingReference'] as String?,
      circleSizeDisplay: jsonSerialization['circleSizeDisplay'] as String?,
      appTheme: jsonSerialization['appTheme'] as String?,
      appLocale: jsonSerialization['appLocale'] as String?,
      mapMarkerSizeScale: (jsonSerialization['mapMarkerSizeScale'] as num?)
          ?.toDouble(),
      mapViewportDebugBorder:
          jsonSerialization['mapViewportDebugBorder'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapViewportDebugBorder'],
            ),
      mapTileBorderDebug: jsonSerialization['mapTileBorderDebug'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapTileBorderDebug'],
            ),
      mapCompassRoseEnabled: jsonSerialization['mapCompassRoseEnabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapCompassRoseEnabled'],
            ),
      mapMgrsGridEnabled: jsonSerialization['mapMgrsGridEnabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['mapMgrsGridEnabled'],
            ),
      darkMapTilesInDarkMode:
          jsonSerialization['darkMapTilesInDarkMode'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['darkMapTilesInDarkMode'],
            ),
      polygonSnapRightAngles:
          jsonSerialization['polygonSnapRightAngles'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['polygonSnapRightAngles'],
            ),
      polygonSnap45Angles: jsonSerialization['polygonSnap45Angles'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['polygonSnap45Angles'],
            ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = UserClientPreferencesTable();

  static const db = UserClientPreferencesRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue authUserId;

  String measurementUnits;

  String angleDisplayFormat;

  String bearingReference;

  String circleSizeDisplay;

  String appTheme;

  String appLocale;

  double mapMarkerSizeScale;

  bool mapViewportDebugBorder;

  bool mapTileBorderDebug;

  bool mapCompassRoseEnabled;

  bool mapMgrsGridEnabled;

  bool darkMapTilesInDarkMode;

  bool polygonSnapRightAngles;

  bool polygonSnap45Angles;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [UserClientPreferences]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserClientPreferences copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserClientPreferences',
      'id': id.toJson(),
      'authUserId': authUserId.toJson(),
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'bearingReference': bearingReference,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'mapMarkerSizeScale': mapMarkerSizeScale,
      'mapViewportDebugBorder': mapViewportDebugBorder,
      'mapTileBorderDebug': mapTileBorderDebug,
      'mapCompassRoseEnabled': mapCompassRoseEnabled,
      'mapMgrsGridEnabled': mapMgrsGridEnabled,
      'darkMapTilesInDarkMode': darkMapTilesInDarkMode,
      'polygonSnapRightAngles': polygonSnapRightAngles,
      'polygonSnap45Angles': polygonSnap45Angles,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserClientPreferences',
      'id': id.toJson(),
      'authUserId': authUserId.toJson(),
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'bearingReference': bearingReference,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'mapMarkerSizeScale': mapMarkerSizeScale,
      'mapViewportDebugBorder': mapViewportDebugBorder,
      'mapTileBorderDebug': mapTileBorderDebug,
      'mapCompassRoseEnabled': mapCompassRoseEnabled,
      'mapMgrsGridEnabled': mapMgrsGridEnabled,
      'darkMapTilesInDarkMode': darkMapTilesInDarkMode,
      'polygonSnapRightAngles': polygonSnapRightAngles,
      'polygonSnap45Angles': polygonSnap45Angles,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static UserClientPreferencesInclude include() {
    return UserClientPreferencesInclude._();
  }

  static UserClientPreferencesIncludeList includeList({
    _i1.WhereExpressionBuilder<UserClientPreferencesTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserClientPreferencesTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserClientPreferencesTable>? orderByList,
    UserClientPreferencesInclude? include,
  }) {
    return UserClientPreferencesIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserClientPreferences.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserClientPreferences.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UserClientPreferencesImpl extends UserClientPreferences {
  _UserClientPreferencesImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         measurementUnits: measurementUnits,
         angleDisplayFormat: angleDisplayFormat,
         bearingReference: bearingReference,
         circleSizeDisplay: circleSizeDisplay,
         appTheme: appTheme,
         appLocale: appLocale,
         mapMarkerSizeScale: mapMarkerSizeScale,
         mapViewportDebugBorder: mapViewportDebugBorder,
         mapTileBorderDebug: mapTileBorderDebug,
         mapCompassRoseEnabled: mapCompassRoseEnabled,
         mapMgrsGridEnabled: mapMgrsGridEnabled,
         darkMapTilesInDarkMode: darkMapTilesInDarkMode,
         polygonSnapRightAngles: polygonSnapRightAngles,
         polygonSnap45Angles: polygonSnap45Angles,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserClientPreferences]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserClientPreferences copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? bearingReference,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    DateTime? updatedAt,
  }) {
    return UserClientPreferences(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      measurementUnits: measurementUnits ?? this.measurementUnits,
      angleDisplayFormat: angleDisplayFormat ?? this.angleDisplayFormat,
      bearingReference: bearingReference ?? this.bearingReference,
      circleSizeDisplay: circleSizeDisplay ?? this.circleSizeDisplay,
      appTheme: appTheme ?? this.appTheme,
      appLocale: appLocale ?? this.appLocale,
      mapMarkerSizeScale: mapMarkerSizeScale ?? this.mapMarkerSizeScale,
      mapViewportDebugBorder:
          mapViewportDebugBorder ?? this.mapViewportDebugBorder,
      mapTileBorderDebug: mapTileBorderDebug ?? this.mapTileBorderDebug,
      mapCompassRoseEnabled:
          mapCompassRoseEnabled ?? this.mapCompassRoseEnabled,
      mapMgrsGridEnabled: mapMgrsGridEnabled ?? this.mapMgrsGridEnabled,
      darkMapTilesInDarkMode:
          darkMapTilesInDarkMode ?? this.darkMapTilesInDarkMode,
      polygonSnapRightAngles:
          polygonSnapRightAngles ?? this.polygonSnapRightAngles,
      polygonSnap45Angles: polygonSnap45Angles ?? this.polygonSnap45Angles,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserClientPreferencesUpdateTable
    extends _i1.UpdateTable<UserClientPreferencesTable> {
  UserClientPreferencesUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> measurementUnits(String value) =>
      _i1.ColumnValue(
        table.measurementUnits,
        value,
      );

  _i1.ColumnValue<String, String> angleDisplayFormat(String value) =>
      _i1.ColumnValue(
        table.angleDisplayFormat,
        value,
      );

  _i1.ColumnValue<String, String> bearingReference(String value) =>
      _i1.ColumnValue(
        table.bearingReference,
        value,
      );

  _i1.ColumnValue<String, String> circleSizeDisplay(String value) =>
      _i1.ColumnValue(
        table.circleSizeDisplay,
        value,
      );

  _i1.ColumnValue<String, String> appTheme(String value) => _i1.ColumnValue(
    table.appTheme,
    value,
  );

  _i1.ColumnValue<String, String> appLocale(String value) => _i1.ColumnValue(
    table.appLocale,
    value,
  );

  _i1.ColumnValue<double, double> mapMarkerSizeScale(double value) =>
      _i1.ColumnValue(
        table.mapMarkerSizeScale,
        value,
      );

  _i1.ColumnValue<bool, bool> mapViewportDebugBorder(bool value) =>
      _i1.ColumnValue(
        table.mapViewportDebugBorder,
        value,
      );

  _i1.ColumnValue<bool, bool> mapTileBorderDebug(bool value) => _i1.ColumnValue(
    table.mapTileBorderDebug,
    value,
  );

  _i1.ColumnValue<bool, bool> mapCompassRoseEnabled(bool value) =>
      _i1.ColumnValue(
        table.mapCompassRoseEnabled,
        value,
      );

  _i1.ColumnValue<bool, bool> mapMgrsGridEnabled(bool value) => _i1.ColumnValue(
    table.mapMgrsGridEnabled,
    value,
  );

  _i1.ColumnValue<bool, bool> darkMapTilesInDarkMode(bool value) =>
      _i1.ColumnValue(
        table.darkMapTilesInDarkMode,
        value,
      );

  _i1.ColumnValue<bool, bool> polygonSnapRightAngles(bool value) =>
      _i1.ColumnValue(
        table.polygonSnapRightAngles,
        value,
      );

  _i1.ColumnValue<bool, bool> polygonSnap45Angles(bool value) =>
      _i1.ColumnValue(
        table.polygonSnap45Angles,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class UserClientPreferencesTable extends _i1.Table<_i1.UuidValue> {
  UserClientPreferencesTable({super.tableRelation})
    : super(tableName: 'user_client_preferences') {
    updateTable = UserClientPreferencesUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    measurementUnits = _i1.ColumnString(
      'measurementUnits',
      this,
      hasDefault: true,
    );
    angleDisplayFormat = _i1.ColumnString(
      'angleDisplayFormat',
      this,
      hasDefault: true,
    );
    bearingReference = _i1.ColumnString(
      'bearingReference',
      this,
      hasDefault: true,
    );
    circleSizeDisplay = _i1.ColumnString(
      'circleSizeDisplay',
      this,
      hasDefault: true,
    );
    appTheme = _i1.ColumnString(
      'appTheme',
      this,
      hasDefault: true,
    );
    appLocale = _i1.ColumnString(
      'appLocale',
      this,
      hasDefault: true,
    );
    mapMarkerSizeScale = _i1.ColumnDouble(
      'mapMarkerSizeScale',
      this,
      hasDefault: true,
    );
    mapViewportDebugBorder = _i1.ColumnBool(
      'mapViewportDebugBorder',
      this,
      hasDefault: true,
    );
    mapTileBorderDebug = _i1.ColumnBool(
      'mapTileBorderDebug',
      this,
      hasDefault: true,
    );
    mapCompassRoseEnabled = _i1.ColumnBool(
      'mapCompassRoseEnabled',
      this,
      hasDefault: true,
    );
    mapMgrsGridEnabled = _i1.ColumnBool(
      'mapMgrsGridEnabled',
      this,
      hasDefault: true,
    );
    darkMapTilesInDarkMode = _i1.ColumnBool(
      'darkMapTilesInDarkMode',
      this,
      hasDefault: true,
    );
    polygonSnapRightAngles = _i1.ColumnBool(
      'polygonSnapRightAngles',
      this,
      hasDefault: true,
    );
    polygonSnap45Angles = _i1.ColumnBool(
      'polygonSnap45Angles',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final UserClientPreferencesUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  late final _i1.ColumnString measurementUnits;

  late final _i1.ColumnString angleDisplayFormat;

  late final _i1.ColumnString bearingReference;

  late final _i1.ColumnString circleSizeDisplay;

  late final _i1.ColumnString appTheme;

  late final _i1.ColumnString appLocale;

  late final _i1.ColumnDouble mapMarkerSizeScale;

  late final _i1.ColumnBool mapViewportDebugBorder;

  late final _i1.ColumnBool mapTileBorderDebug;

  late final _i1.ColumnBool mapCompassRoseEnabled;

  late final _i1.ColumnBool mapMgrsGridEnabled;

  late final _i1.ColumnBool darkMapTilesInDarkMode;

  late final _i1.ColumnBool polygonSnapRightAngles;

  late final _i1.ColumnBool polygonSnap45Angles;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    measurementUnits,
    angleDisplayFormat,
    bearingReference,
    circleSizeDisplay,
    appTheme,
    appLocale,
    mapMarkerSizeScale,
    mapViewportDebugBorder,
    mapTileBorderDebug,
    mapCompassRoseEnabled,
    mapMgrsGridEnabled,
    darkMapTilesInDarkMode,
    polygonSnapRightAngles,
    polygonSnap45Angles,
    updatedAt,
  ];
}

class UserClientPreferencesInclude extends _i1.IncludeObject {
  UserClientPreferencesInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => UserClientPreferences.t;
}

class UserClientPreferencesIncludeList extends _i1.IncludeList {
  UserClientPreferencesIncludeList._({
    _i1.WhereExpressionBuilder<UserClientPreferencesTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserClientPreferences.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => UserClientPreferences.t;
}

class UserClientPreferencesRepository {
  const UserClientPreferencesRepository._();

  /// Returns a list of [UserClientPreferences]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserClientPreferences>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserClientPreferencesTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserClientPreferencesTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserClientPreferencesTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserClientPreferences>(
      where: where?.call(UserClientPreferences.t),
      orderBy: orderBy?.call(UserClientPreferences.t),
      orderByList: orderByList?.call(UserClientPreferences.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserClientPreferences] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserClientPreferences?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserClientPreferencesTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserClientPreferencesTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserClientPreferencesTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserClientPreferences>(
      where: where?.call(UserClientPreferences.t),
      orderBy: orderBy?.call(UserClientPreferences.t),
      orderByList: orderByList?.call(UserClientPreferences.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserClientPreferences] by its [id] or null if no such row exists.
  Future<UserClientPreferences?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserClientPreferences>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserClientPreferences]s in the list and returns the inserted rows.
  ///
  /// The returned [UserClientPreferences]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserClientPreferences>> insert(
    _i1.DatabaseSession session,
    List<UserClientPreferences> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserClientPreferences>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserClientPreferences] and returns the inserted row.
  ///
  /// The returned [UserClientPreferences] will have its `id` field set.
  Future<UserClientPreferences> insertRow(
    _i1.DatabaseSession session,
    UserClientPreferences row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserClientPreferences>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserClientPreferences]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserClientPreferences>> update(
    _i1.DatabaseSession session,
    List<UserClientPreferences> rows, {
    _i1.ColumnSelections<UserClientPreferencesTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserClientPreferences>(
      rows,
      columns: columns?.call(UserClientPreferences.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserClientPreferences]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserClientPreferences> updateRow(
    _i1.DatabaseSession session,
    UserClientPreferences row, {
    _i1.ColumnSelections<UserClientPreferencesTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserClientPreferences>(
      row,
      columns: columns?.call(UserClientPreferences.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserClientPreferences] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserClientPreferences?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<UserClientPreferencesUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserClientPreferences>(
      id,
      columnValues: columnValues(UserClientPreferences.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserClientPreferences]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserClientPreferences>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserClientPreferencesUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<UserClientPreferencesTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserClientPreferencesTable>? orderBy,
    _i1.OrderByListBuilder<UserClientPreferencesTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserClientPreferences>(
      columnValues: columnValues(UserClientPreferences.t.updateTable),
      where: where(UserClientPreferences.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserClientPreferences.t),
      orderByList: orderByList?.call(UserClientPreferences.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserClientPreferences]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserClientPreferences>> delete(
    _i1.DatabaseSession session,
    List<UserClientPreferences> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserClientPreferences>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserClientPreferences].
  Future<UserClientPreferences> deleteRow(
    _i1.DatabaseSession session,
    UserClientPreferences row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserClientPreferences>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserClientPreferences>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserClientPreferencesTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserClientPreferences>(
      where: where(UserClientPreferences.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserClientPreferencesTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserClientPreferences>(
      where: where?.call(UserClientPreferences.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserClientPreferences] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserClientPreferencesTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserClientPreferences>(
      where: where(UserClientPreferences.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
