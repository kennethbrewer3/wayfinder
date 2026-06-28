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

abstract class GeocodeContribution
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  GeocodeContribution._({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.countryCode,
    required this.contentKey,
    bool? importedFromCrowd,
    required this.createdAt,
    required this.updatedAt,
  }) : importedFromCrowd = importedFromCrowd ?? false;

  factory GeocodeContribution({
    int? id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? countryCode,
    required String contentKey,
    bool? importedFromCrowd,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GeocodeContributionImpl;

  factory GeocodeContribution.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodeContribution(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      notes: jsonSerialization['notes'] as String?,
      countryCode: jsonSerialization['countryCode'] as String?,
      contentKey: jsonSerialization['contentKey'] as String,
      importedFromCrowd: jsonSerialization['importedFromCrowd'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['importedFromCrowd'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = GeocodeContributionTable();

  static const db = GeocodeContributionRepository._();

  @override
  int? id;

  String name;

  double latitude;

  double longitude;

  String? notes;

  String? countryCode;

  String contentKey;

  bool importedFromCrowd;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GeocodeContribution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodeContribution copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? notes,
    String? countryCode,
    String? contentKey,
    bool? importedFromCrowd,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodeContribution',
      if (id != null) 'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      if (countryCode != null) 'countryCode': countryCode,
      'contentKey': contentKey,
      'importedFromCrowd': importedFromCrowd,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeocodeContribution',
      if (id != null) 'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      if (countryCode != null) 'countryCode': countryCode,
      'contentKey': contentKey,
      'importedFromCrowd': importedFromCrowd,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static GeocodeContributionInclude include() {
    return GeocodeContributionInclude._();
  }

  static GeocodeContributionIncludeList includeList({
    _i1.WhereExpressionBuilder<GeocodeContributionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodeContributionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodeContributionTable>? orderByList,
    GeocodeContributionInclude? include,
  }) {
    return GeocodeContributionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodeContribution.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GeocodeContribution.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodeContributionImpl extends GeocodeContribution {
  _GeocodeContributionImpl({
    int? id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? countryCode,
    required String contentKey,
    bool? importedFromCrowd,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         latitude: latitude,
         longitude: longitude,
         notes: notes,
         countryCode: countryCode,
         contentKey: contentKey,
         importedFromCrowd: importedFromCrowd,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [GeocodeContribution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodeContribution copyWith({
    Object? id = _Undefined,
    String? name,
    double? latitude,
    double? longitude,
    Object? notes = _Undefined,
    Object? countryCode = _Undefined,
    String? contentKey,
    bool? importedFromCrowd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeocodeContribution(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes is String? ? notes : this.notes,
      countryCode: countryCode is String? ? countryCode : this.countryCode,
      contentKey: contentKey ?? this.contentKey,
      importedFromCrowd: importedFromCrowd ?? this.importedFromCrowd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GeocodeContributionUpdateTable
    extends _i1.UpdateTable<GeocodeContributionTable> {
  GeocodeContributionUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<double, double> latitude(double value) => _i1.ColumnValue(
    table.latitude,
    value,
  );

  _i1.ColumnValue<double, double> longitude(double value) => _i1.ColumnValue(
    table.longitude,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<String, String> countryCode(String? value) => _i1.ColumnValue(
    table.countryCode,
    value,
  );

  _i1.ColumnValue<String, String> contentKey(String value) => _i1.ColumnValue(
    table.contentKey,
    value,
  );

  _i1.ColumnValue<bool, bool> importedFromCrowd(bool value) => _i1.ColumnValue(
    table.importedFromCrowd,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class GeocodeContributionTable extends _i1.Table<int?> {
  GeocodeContributionTable({super.tableRelation})
    : super(tableName: 'geocode_contribution') {
    updateTable = GeocodeContributionUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    latitude = _i1.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _i1.ColumnDouble(
      'longitude',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    countryCode = _i1.ColumnString(
      'countryCode',
      this,
    );
    contentKey = _i1.ColumnString(
      'contentKey',
      this,
    );
    importedFromCrowd = _i1.ColumnBool(
      'importedFromCrowd',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final GeocodeContributionUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnString notes;

  late final _i1.ColumnString countryCode;

  late final _i1.ColumnString contentKey;

  late final _i1.ColumnBool importedFromCrowd;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    latitude,
    longitude,
    notes,
    countryCode,
    contentKey,
    importedFromCrowd,
    createdAt,
    updatedAt,
  ];
}

class GeocodeContributionInclude extends _i1.IncludeObject {
  GeocodeContributionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => GeocodeContribution.t;
}

class GeocodeContributionIncludeList extends _i1.IncludeList {
  GeocodeContributionIncludeList._({
    _i1.WhereExpressionBuilder<GeocodeContributionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GeocodeContribution.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GeocodeContribution.t;
}

class GeocodeContributionRepository {
  const GeocodeContributionRepository._();

  /// Returns a list of [GeocodeContribution]s matching the given query parameters.
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
  Future<List<GeocodeContribution>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodeContributionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodeContributionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodeContributionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GeocodeContribution>(
      where: where?.call(GeocodeContribution.t),
      orderBy: orderBy?.call(GeocodeContribution.t),
      orderByList: orderByList?.call(GeocodeContribution.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GeocodeContribution] matching the given query parameters.
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
  Future<GeocodeContribution?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodeContributionTable>? where,
    int? offset,
    _i1.OrderByBuilder<GeocodeContributionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodeContributionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GeocodeContribution>(
      where: where?.call(GeocodeContribution.t),
      orderBy: orderBy?.call(GeocodeContribution.t),
      orderByList: orderByList?.call(GeocodeContribution.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GeocodeContribution] by its [id] or null if no such row exists.
  Future<GeocodeContribution?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GeocodeContribution>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GeocodeContribution]s in the list and returns the inserted rows.
  ///
  /// The returned [GeocodeContribution]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<GeocodeContribution>> insert(
    _i1.DatabaseSession session,
    List<GeocodeContribution> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GeocodeContribution>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GeocodeContribution] and returns the inserted row.
  ///
  /// The returned [GeocodeContribution] will have its `id` field set.
  Future<GeocodeContribution> insertRow(
    _i1.DatabaseSession session,
    GeocodeContribution row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GeocodeContribution>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GeocodeContribution]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GeocodeContribution>> update(
    _i1.DatabaseSession session,
    List<GeocodeContribution> rows, {
    _i1.ColumnSelections<GeocodeContributionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GeocodeContribution>(
      rows,
      columns: columns?.call(GeocodeContribution.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodeContribution]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GeocodeContribution> updateRow(
    _i1.DatabaseSession session,
    GeocodeContribution row, {
    _i1.ColumnSelections<GeocodeContributionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GeocodeContribution>(
      row,
      columns: columns?.call(GeocodeContribution.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodeContribution] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GeocodeContribution?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<GeocodeContributionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GeocodeContribution>(
      id,
      columnValues: columnValues(GeocodeContribution.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GeocodeContribution]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GeocodeContribution>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<GeocodeContributionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GeocodeContributionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodeContributionTable>? orderBy,
    _i1.OrderByListBuilder<GeocodeContributionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GeocodeContribution>(
      columnValues: columnValues(GeocodeContribution.t.updateTable),
      where: where(GeocodeContribution.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodeContribution.t),
      orderByList: orderByList?.call(GeocodeContribution.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GeocodeContribution]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GeocodeContribution>> delete(
    _i1.DatabaseSession session,
    List<GeocodeContribution> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GeocodeContribution>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GeocodeContribution].
  Future<GeocodeContribution> deleteRow(
    _i1.DatabaseSession session,
    GeocodeContribution row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GeocodeContribution>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GeocodeContribution>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodeContributionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GeocodeContribution>(
      where: where(GeocodeContribution.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodeContributionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GeocodeContribution>(
      where: where?.call(GeocodeContribution.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GeocodeContribution] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodeContributionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GeocodeContribution>(
      where: where(GeocodeContribution.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
