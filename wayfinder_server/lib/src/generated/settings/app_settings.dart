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

abstract class AppSettings
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AppSettings._({
    this.id,
    required this.homeLatitude,
    required this.homeLongitude,
    required this.homeZoom,
    required this.pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    required this.updatedAt,
  }) : measurementUnits = measurementUnits ?? 'metric',
       angleDisplayFormat = angleDisplayFormat ?? 'decimal',
       circleSizeDisplay = circleSizeDisplay ?? 'radius',
       appTheme = appTheme ?? 'light',
       appLocale = appLocale ?? 'system';

  factory AppSettings({
    int? id,
    required double homeLatitude,
    required double homeLongitude,
    required double homeZoom,
    required String pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    required DateTime updatedAt,
  }) = _AppSettingsImpl;

  factory AppSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppSettings(
      id: jsonSerialization['id'] as int?,
      homeLatitude: (jsonSerialization['homeLatitude'] as num).toDouble(),
      homeLongitude: (jsonSerialization['homeLongitude'] as num).toDouble(),
      homeZoom: (jsonSerialization['homeZoom'] as num).toDouble(),
      pmtilesStoragePath: jsonSerialization['pmtilesStoragePath'] as String,
      measurementUnits: jsonSerialization['measurementUnits'] as String?,
      angleDisplayFormat: jsonSerialization['angleDisplayFormat'] as String?,
      circleSizeDisplay: jsonSerialization['circleSizeDisplay'] as String?,
      appTheme: jsonSerialization['appTheme'] as String?,
      appLocale: jsonSerialization['appLocale'] as String?,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = AppSettingsTable();

  static const db = AppSettingsRepository._();

  @override
  int? id;

  double homeLatitude;

  double homeLongitude;

  double homeZoom;

  String pmtilesStoragePath;

  String measurementUnits;

  String angleDisplayFormat;

  String circleSizeDisplay;

  String appTheme;

  String appLocale;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AppSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppSettings copyWith({
    int? id,
    double? homeLatitude,
    double? homeLongitude,
    double? homeZoom,
    String? pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppSettings',
      if (id != null) 'id': id,
      'homeLatitude': homeLatitude,
      'homeLongitude': homeLongitude,
      'homeZoom': homeZoom,
      'pmtilesStoragePath': pmtilesStoragePath,
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppSettings',
      if (id != null) 'id': id,
      'homeLatitude': homeLatitude,
      'homeLongitude': homeLongitude,
      'homeZoom': homeZoom,
      'pmtilesStoragePath': pmtilesStoragePath,
      'measurementUnits': measurementUnits,
      'angleDisplayFormat': angleDisplayFormat,
      'circleSizeDisplay': circleSizeDisplay,
      'appTheme': appTheme,
      'appLocale': appLocale,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AppSettingsInclude include() {
    return AppSettingsInclude._();
  }

  static AppSettingsIncludeList includeList({
    _i1.WhereExpressionBuilder<AppSettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppSettingsTable>? orderByList,
    AppSettingsInclude? include,
  }) {
    return AppSettingsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppSettings.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AppSettings.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppSettingsImpl extends AppSettings {
  _AppSettingsImpl({
    int? id,
    required double homeLatitude,
    required double homeLongitude,
    required double homeZoom,
    required String pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         homeLatitude: homeLatitude,
         homeLongitude: homeLongitude,
         homeZoom: homeZoom,
         pmtilesStoragePath: pmtilesStoragePath,
         measurementUnits: measurementUnits,
         angleDisplayFormat: angleDisplayFormat,
         circleSizeDisplay: circleSizeDisplay,
         appTheme: appTheme,
         appLocale: appLocale,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AppSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppSettings copyWith({
    Object? id = _Undefined,
    double? homeLatitude,
    double? homeLongitude,
    double? homeZoom,
    String? pmtilesStoragePath,
    String? measurementUnits,
    String? angleDisplayFormat,
    String? circleSizeDisplay,
    String? appTheme,
    String? appLocale,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id is int? ? id : this.id,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      homeZoom: homeZoom ?? this.homeZoom,
      pmtilesStoragePath: pmtilesStoragePath ?? this.pmtilesStoragePath,
      measurementUnits: measurementUnits ?? this.measurementUnits,
      angleDisplayFormat: angleDisplayFormat ?? this.angleDisplayFormat,
      circleSizeDisplay: circleSizeDisplay ?? this.circleSizeDisplay,
      appTheme: appTheme ?? this.appTheme,
      appLocale: appLocale ?? this.appLocale,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AppSettingsUpdateTable extends _i1.UpdateTable<AppSettingsTable> {
  AppSettingsUpdateTable(super.table);

  _i1.ColumnValue<double, double> homeLatitude(double value) => _i1.ColumnValue(
    table.homeLatitude,
    value,
  );

  _i1.ColumnValue<double, double> homeLongitude(double value) =>
      _i1.ColumnValue(
        table.homeLongitude,
        value,
      );

  _i1.ColumnValue<double, double> homeZoom(double value) => _i1.ColumnValue(
    table.homeZoom,
    value,
  );

  _i1.ColumnValue<String, String> pmtilesStoragePath(String value) =>
      _i1.ColumnValue(
        table.pmtilesStoragePath,
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

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AppSettingsTable extends _i1.Table<int?> {
  AppSettingsTable({super.tableRelation}) : super(tableName: 'app_settings') {
    updateTable = AppSettingsUpdateTable(this);
    homeLatitude = _i1.ColumnDouble(
      'homeLatitude',
      this,
    );
    homeLongitude = _i1.ColumnDouble(
      'homeLongitude',
      this,
    );
    homeZoom = _i1.ColumnDouble(
      'homeZoom',
      this,
    );
    pmtilesStoragePath = _i1.ColumnString(
      'pmtilesStoragePath',
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
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final AppSettingsUpdateTable updateTable;

  late final _i1.ColumnDouble homeLatitude;

  late final _i1.ColumnDouble homeLongitude;

  late final _i1.ColumnDouble homeZoom;

  late final _i1.ColumnString pmtilesStoragePath;

  late final _i1.ColumnString measurementUnits;

  late final _i1.ColumnString angleDisplayFormat;

  late final _i1.ColumnString circleSizeDisplay;

  late final _i1.ColumnString appTheme;

  late final _i1.ColumnString appLocale;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    homeLatitude,
    homeLongitude,
    homeZoom,
    pmtilesStoragePath,
    measurementUnits,
    angleDisplayFormat,
    circleSizeDisplay,
    appTheme,
    appLocale,
    updatedAt,
  ];
}

class AppSettingsInclude extends _i1.IncludeObject {
  AppSettingsInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AppSettings.t;
}

class AppSettingsIncludeList extends _i1.IncludeList {
  AppSettingsIncludeList._({
    _i1.WhereExpressionBuilder<AppSettingsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppSettings.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AppSettings.t;
}

class AppSettingsRepository {
  const AppSettingsRepository._();

  /// Returns a list of [AppSettings]s matching the given query parameters.
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
  Future<List<AppSettings>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppSettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppSettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AppSettings>(
      where: where?.call(AppSettings.t),
      orderBy: orderBy?.call(AppSettings.t),
      orderByList: orderByList?.call(AppSettings.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AppSettings] matching the given query parameters.
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
  Future<AppSettings?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppSettingsTable>? where,
    int? offset,
    _i1.OrderByBuilder<AppSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppSettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AppSettings>(
      where: where?.call(AppSettings.t),
      orderBy: orderBy?.call(AppSettings.t),
      orderByList: orderByList?.call(AppSettings.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AppSettings] by its [id] or null if no such row exists.
  Future<AppSettings?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AppSettings>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AppSettings]s in the list and returns the inserted rows.
  ///
  /// The returned [AppSettings]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AppSettings>> insert(
    _i1.DatabaseSession session,
    List<AppSettings> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AppSettings>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AppSettings] and returns the inserted row.
  ///
  /// The returned [AppSettings] will have its `id` field set.
  Future<AppSettings> insertRow(
    _i1.DatabaseSession session,
    AppSettings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AppSettings]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AppSettings>> update(
    _i1.DatabaseSession session,
    List<AppSettings> rows, {
    _i1.ColumnSelections<AppSettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AppSettings>(
      rows,
      columns: columns?.call(AppSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppSettings]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppSettings> updateRow(
    _i1.DatabaseSession session,
    AppSettings row, {
    _i1.ColumnSelections<AppSettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppSettings>(
      row,
      columns: columns?.call(AppSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppSettings] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppSettings?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AppSettingsUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AppSettings>(
      id,
      columnValues: columnValues(AppSettings.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppSettings]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AppSettings>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AppSettingsUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AppSettingsTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppSettingsTable>? orderBy,
    _i1.OrderByListBuilder<AppSettingsTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AppSettings>(
      columnValues: columnValues(AppSettings.t.updateTable),
      where: where(AppSettings.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppSettings.t),
      orderByList: orderByList?.call(AppSettings.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AppSettings]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AppSettings>> delete(
    _i1.DatabaseSession session,
    List<AppSettings> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AppSettings>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AppSettings].
  Future<AppSettings> deleteRow(
    _i1.DatabaseSession session,
    AppSettings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AppSettings>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AppSettingsTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AppSettings>(
      where: where(AppSettings.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppSettingsTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AppSettings>(
      where: where?.call(AppSettings.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AppSettings] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AppSettingsTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AppSettings>(
      where: where(AppSettings.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
