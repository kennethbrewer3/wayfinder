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

abstract class GeocodingSettings
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  GeocodingSettings._({
    this.id,
    required this.sourceUrl,
    this.countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    this.importError,
    this.importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    this.housenumbersImportError,
    this.housenumbersImportedAt,
    required this.updatedAt,
  }) : importStatus = importStatus ?? 'idle',
       importedRowCount = importedRowCount ?? 0,
       importProgress = importProgress ?? 0.0,
       housenumbersSourceUrl =
           housenumbersSourceUrl ??
           'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_housenumbers.tsv.gz',
       housenumbersImportStatus = housenumbersImportStatus ?? 'idle',
       housenumbersImportedRowCount = housenumbersImportedRowCount ?? 0,
       housenumbersImportProgress = housenumbersImportProgress ?? 0.0;

  factory GeocodingSettings({
    int? id,
    required String sourceUrl,
    String? countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
    DateTime? importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    String? housenumbersImportError,
    DateTime? housenumbersImportedAt,
    required DateTime updatedAt,
  }) = _GeocodingSettingsImpl;

  factory GeocodingSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodingSettings(
      id: jsonSerialization['id'] as int?,
      sourceUrl: jsonSerialization['sourceUrl'] as String,
      countryCodes: jsonSerialization['countryCodes'] as String?,
      importStatus: jsonSerialization['importStatus'] as String?,
      importedRowCount: jsonSerialization['importedRowCount'] as int?,
      importProgress: (jsonSerialization['importProgress'] as num?)?.toDouble(),
      importError: jsonSerialization['importError'] as String?,
      importedAt: jsonSerialization['importedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['importedAt']),
      housenumbersSourceUrl:
          jsonSerialization['housenumbersSourceUrl'] as String?,
      housenumbersImportStatus:
          jsonSerialization['housenumbersImportStatus'] as String?,
      housenumbersImportedRowCount:
          jsonSerialization['housenumbersImportedRowCount'] as int?,
      housenumbersImportProgress:
          (jsonSerialization['housenumbersImportProgress'] as num?)?.toDouble(),
      housenumbersImportError:
          jsonSerialization['housenumbersImportError'] as String?,
      housenumbersImportedAt:
          jsonSerialization['housenumbersImportedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['housenumbersImportedAt'],
            ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = GeocodingSettingsTable();

  static const db = GeocodingSettingsRepository._();

  @override
  int? id;

  String sourceUrl;

  String? countryCodes;

  String importStatus;

  int importedRowCount;

  double importProgress;

  String? importError;

  DateTime? importedAt;

  String housenumbersSourceUrl;

  String housenumbersImportStatus;

  int housenumbersImportedRowCount;

  double housenumbersImportProgress;

  String? housenumbersImportError;

  DateTime? housenumbersImportedAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GeocodingSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodingSettings copyWith({
    int? id,
    String? sourceUrl,
    String? countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
    DateTime? importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    String? housenumbersImportError,
    DateTime? housenumbersImportedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodingSettings',
      if (id != null) 'id': id,
      'sourceUrl': sourceUrl,
      if (countryCodes != null) 'countryCodes': countryCodes,
      'importStatus': importStatus,
      'importedRowCount': importedRowCount,
      'importProgress': importProgress,
      if (importError != null) 'importError': importError,
      if (importedAt != null) 'importedAt': importedAt?.toJson(),
      'housenumbersSourceUrl': housenumbersSourceUrl,
      'housenumbersImportStatus': housenumbersImportStatus,
      'housenumbersImportedRowCount': housenumbersImportedRowCount,
      'housenumbersImportProgress': housenumbersImportProgress,
      if (housenumbersImportError != null)
        'housenumbersImportError': housenumbersImportError,
      if (housenumbersImportedAt != null)
        'housenumbersImportedAt': housenumbersImportedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeocodingSettings',
      if (id != null) 'id': id,
      'sourceUrl': sourceUrl,
      if (countryCodes != null) 'countryCodes': countryCodes,
      'importStatus': importStatus,
      'importedRowCount': importedRowCount,
      'importProgress': importProgress,
      if (importError != null) 'importError': importError,
      if (importedAt != null) 'importedAt': importedAt?.toJson(),
      'housenumbersSourceUrl': housenumbersSourceUrl,
      'housenumbersImportStatus': housenumbersImportStatus,
      'housenumbersImportedRowCount': housenumbersImportedRowCount,
      'housenumbersImportProgress': housenumbersImportProgress,
      if (housenumbersImportError != null)
        'housenumbersImportError': housenumbersImportError,
      if (housenumbersImportedAt != null)
        'housenumbersImportedAt': housenumbersImportedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static GeocodingSettingsInclude include() {
    return GeocodingSettingsInclude._();
  }

  static GeocodingSettingsIncludeList includeList({
    _i1.WhereExpressionBuilder<GeocodingSettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodingSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodingSettingsTable>? orderByList,
    GeocodingSettingsInclude? include,
  }) {
    return GeocodingSettingsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodingSettings.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GeocodingSettings.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodingSettingsImpl extends GeocodingSettings {
  _GeocodingSettingsImpl({
    int? id,
    required String sourceUrl,
    String? countryCodes,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
    DateTime? importedAt,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    String? housenumbersImportError,
    DateTime? housenumbersImportedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         sourceUrl: sourceUrl,
         countryCodes: countryCodes,
         importStatus: importStatus,
         importedRowCount: importedRowCount,
         importProgress: importProgress,
         importError: importError,
         importedAt: importedAt,
         housenumbersSourceUrl: housenumbersSourceUrl,
         housenumbersImportStatus: housenumbersImportStatus,
         housenumbersImportedRowCount: housenumbersImportedRowCount,
         housenumbersImportProgress: housenumbersImportProgress,
         housenumbersImportError: housenumbersImportError,
         housenumbersImportedAt: housenumbersImportedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [GeocodingSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodingSettings copyWith({
    Object? id = _Undefined,
    String? sourceUrl,
    Object? countryCodes = _Undefined,
    String? importStatus,
    int? importedRowCount,
    double? importProgress,
    Object? importError = _Undefined,
    Object? importedAt = _Undefined,
    String? housenumbersSourceUrl,
    String? housenumbersImportStatus,
    int? housenumbersImportedRowCount,
    double? housenumbersImportProgress,
    Object? housenumbersImportError = _Undefined,
    Object? housenumbersImportedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return GeocodingSettings(
      id: id is int? ? id : this.id,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      countryCodes: countryCodes is String? ? countryCodes : this.countryCodes,
      importStatus: importStatus ?? this.importStatus,
      importedRowCount: importedRowCount ?? this.importedRowCount,
      importProgress: importProgress ?? this.importProgress,
      importError: importError is String? ? importError : this.importError,
      importedAt: importedAt is DateTime? ? importedAt : this.importedAt,
      housenumbersSourceUrl:
          housenumbersSourceUrl ?? this.housenumbersSourceUrl,
      housenumbersImportStatus:
          housenumbersImportStatus ?? this.housenumbersImportStatus,
      housenumbersImportedRowCount:
          housenumbersImportedRowCount ?? this.housenumbersImportedRowCount,
      housenumbersImportProgress:
          housenumbersImportProgress ?? this.housenumbersImportProgress,
      housenumbersImportError: housenumbersImportError is String?
          ? housenumbersImportError
          : this.housenumbersImportError,
      housenumbersImportedAt: housenumbersImportedAt is DateTime?
          ? housenumbersImportedAt
          : this.housenumbersImportedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GeocodingSettingsUpdateTable
    extends _i1.UpdateTable<GeocodingSettingsTable> {
  GeocodingSettingsUpdateTable(super.table);

  _i1.ColumnValue<String, String> sourceUrl(String value) => _i1.ColumnValue(
    table.sourceUrl,
    value,
  );

  _i1.ColumnValue<String, String> countryCodes(String? value) =>
      _i1.ColumnValue(
        table.countryCodes,
        value,
      );

  _i1.ColumnValue<String, String> importStatus(String value) => _i1.ColumnValue(
    table.importStatus,
    value,
  );

  _i1.ColumnValue<int, int> importedRowCount(int value) => _i1.ColumnValue(
    table.importedRowCount,
    value,
  );

  _i1.ColumnValue<double, double> importProgress(double value) =>
      _i1.ColumnValue(
        table.importProgress,
        value,
      );

  _i1.ColumnValue<String, String> importError(String? value) => _i1.ColumnValue(
    table.importError,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> importedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.importedAt,
        value,
      );

  _i1.ColumnValue<String, String> housenumbersSourceUrl(String value) =>
      _i1.ColumnValue(
        table.housenumbersSourceUrl,
        value,
      );

  _i1.ColumnValue<String, String> housenumbersImportStatus(String value) =>
      _i1.ColumnValue(
        table.housenumbersImportStatus,
        value,
      );

  _i1.ColumnValue<int, int> housenumbersImportedRowCount(int value) =>
      _i1.ColumnValue(
        table.housenumbersImportedRowCount,
        value,
      );

  _i1.ColumnValue<double, double> housenumbersImportProgress(double value) =>
      _i1.ColumnValue(
        table.housenumbersImportProgress,
        value,
      );

  _i1.ColumnValue<String, String> housenumbersImportError(String? value) =>
      _i1.ColumnValue(
        table.housenumbersImportError,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> housenumbersImportedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.housenumbersImportedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class GeocodingSettingsTable extends _i1.Table<int?> {
  GeocodingSettingsTable({super.tableRelation})
    : super(tableName: 'geocoding_settings') {
    updateTable = GeocodingSettingsUpdateTable(this);
    sourceUrl = _i1.ColumnString(
      'sourceUrl',
      this,
    );
    countryCodes = _i1.ColumnString(
      'countryCodes',
      this,
    );
    importStatus = _i1.ColumnString(
      'importStatus',
      this,
      hasDefault: true,
    );
    importedRowCount = _i1.ColumnInt(
      'importedRowCount',
      this,
      hasDefault: true,
    );
    importProgress = _i1.ColumnDouble(
      'importProgress',
      this,
      hasDefault: true,
    );
    importError = _i1.ColumnString(
      'importError',
      this,
    );
    importedAt = _i1.ColumnDateTime(
      'importedAt',
      this,
    );
    housenumbersSourceUrl = _i1.ColumnString(
      'housenumbersSourceUrl',
      this,
      hasDefault: true,
    );
    housenumbersImportStatus = _i1.ColumnString(
      'housenumbersImportStatus',
      this,
      hasDefault: true,
    );
    housenumbersImportedRowCount = _i1.ColumnInt(
      'housenumbersImportedRowCount',
      this,
      hasDefault: true,
    );
    housenumbersImportProgress = _i1.ColumnDouble(
      'housenumbersImportProgress',
      this,
      hasDefault: true,
    );
    housenumbersImportError = _i1.ColumnString(
      'housenumbersImportError',
      this,
    );
    housenumbersImportedAt = _i1.ColumnDateTime(
      'housenumbersImportedAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final GeocodingSettingsUpdateTable updateTable;

  late final _i1.ColumnString sourceUrl;

  late final _i1.ColumnString countryCodes;

  late final _i1.ColumnString importStatus;

  late final _i1.ColumnInt importedRowCount;

  late final _i1.ColumnDouble importProgress;

  late final _i1.ColumnString importError;

  late final _i1.ColumnDateTime importedAt;

  late final _i1.ColumnString housenumbersSourceUrl;

  late final _i1.ColumnString housenumbersImportStatus;

  late final _i1.ColumnInt housenumbersImportedRowCount;

  late final _i1.ColumnDouble housenumbersImportProgress;

  late final _i1.ColumnString housenumbersImportError;

  late final _i1.ColumnDateTime housenumbersImportedAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    sourceUrl,
    countryCodes,
    importStatus,
    importedRowCount,
    importProgress,
    importError,
    importedAt,
    housenumbersSourceUrl,
    housenumbersImportStatus,
    housenumbersImportedRowCount,
    housenumbersImportProgress,
    housenumbersImportError,
    housenumbersImportedAt,
    updatedAt,
  ];
}

class GeocodingSettingsInclude extends _i1.IncludeObject {
  GeocodingSettingsInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => GeocodingSettings.t;
}

class GeocodingSettingsIncludeList extends _i1.IncludeList {
  GeocodingSettingsIncludeList._({
    _i1.WhereExpressionBuilder<GeocodingSettingsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GeocodingSettings.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GeocodingSettings.t;
}

class GeocodingSettingsRepository {
  const GeocodingSettingsRepository._();

  /// Returns a list of [GeocodingSettings]s matching the given query parameters.
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
  Future<List<GeocodingSettings>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodingSettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodingSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodingSettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GeocodingSettings>(
      where: where?.call(GeocodingSettings.t),
      orderBy: orderBy?.call(GeocodingSettings.t),
      orderByList: orderByList?.call(GeocodingSettings.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GeocodingSettings] matching the given query parameters.
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
  Future<GeocodingSettings?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodingSettingsTable>? where,
    int? offset,
    _i1.OrderByBuilder<GeocodingSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodingSettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GeocodingSettings>(
      where: where?.call(GeocodingSettings.t),
      orderBy: orderBy?.call(GeocodingSettings.t),
      orderByList: orderByList?.call(GeocodingSettings.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GeocodingSettings] by its [id] or null if no such row exists.
  Future<GeocodingSettings?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GeocodingSettings>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GeocodingSettings]s in the list and returns the inserted rows.
  ///
  /// The returned [GeocodingSettings]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<GeocodingSettings>> insert(
    _i1.DatabaseSession session,
    List<GeocodingSettings> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GeocodingSettings>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GeocodingSettings] and returns the inserted row.
  ///
  /// The returned [GeocodingSettings] will have its `id` field set.
  Future<GeocodingSettings> insertRow(
    _i1.DatabaseSession session,
    GeocodingSettings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GeocodingSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GeocodingSettings]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GeocodingSettings>> update(
    _i1.DatabaseSession session,
    List<GeocodingSettings> rows, {
    _i1.ColumnSelections<GeocodingSettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GeocodingSettings>(
      rows,
      columns: columns?.call(GeocodingSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodingSettings]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GeocodingSettings> updateRow(
    _i1.DatabaseSession session,
    GeocodingSettings row, {
    _i1.ColumnSelections<GeocodingSettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GeocodingSettings>(
      row,
      columns: columns?.call(GeocodingSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodingSettings] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GeocodingSettings?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<GeocodingSettingsUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GeocodingSettings>(
      id,
      columnValues: columnValues(GeocodingSettings.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GeocodingSettings]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GeocodingSettings>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<GeocodingSettingsUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GeocodingSettingsTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodingSettingsTable>? orderBy,
    _i1.OrderByListBuilder<GeocodingSettingsTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GeocodingSettings>(
      columnValues: columnValues(GeocodingSettings.t.updateTable),
      where: where(GeocodingSettings.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodingSettings.t),
      orderByList: orderByList?.call(GeocodingSettings.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GeocodingSettings]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GeocodingSettings>> delete(
    _i1.DatabaseSession session,
    List<GeocodingSettings> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GeocodingSettings>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GeocodingSettings].
  Future<GeocodingSettings> deleteRow(
    _i1.DatabaseSession session,
    GeocodingSettings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GeocodingSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GeocodingSettings>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodingSettingsTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GeocodingSettings>(
      where: where(GeocodingSettings.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodingSettingsTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GeocodingSettings>(
      where: where?.call(GeocodingSettings.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GeocodingSettings] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodingSettingsTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GeocodingSettings>(
      where: where(GeocodingSettings.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
