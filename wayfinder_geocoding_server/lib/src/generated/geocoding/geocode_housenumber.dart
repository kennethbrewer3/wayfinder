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

abstract class GeocodeHousenumber
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  GeocodeHousenumber._({
    this.id,
    required this.streetId,
    required this.street,
    required this.housenumber,
    required this.latitude,
    required this.longitude,
  });

  factory GeocodeHousenumber({
    int? id,
    required String streetId,
    required String street,
    required String housenumber,
    required double latitude,
    required double longitude,
  }) = _GeocodeHousenumberImpl;

  factory GeocodeHousenumber.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodeHousenumber(
      id: jsonSerialization['id'] as int?,
      streetId: jsonSerialization['streetId'] as String,
      street: jsonSerialization['street'] as String,
      housenumber: jsonSerialization['housenumber'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
    );
  }

  static final t = GeocodeHousenumberTable();

  static const db = GeocodeHousenumberRepository._();

  @override
  int? id;

  String streetId;

  String street;

  String housenumber;

  double latitude;

  double longitude;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [GeocodeHousenumber]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodeHousenumber copyWith({
    int? id,
    String? streetId,
    String? street,
    String? housenumber,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodeHousenumber',
      if (id != null) 'id': id,
      'streetId': streetId,
      'street': street,
      'housenumber': housenumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeocodeHousenumber',
      if (id != null) 'id': id,
      'streetId': streetId,
      'street': street,
      'housenumber': housenumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static GeocodeHousenumberInclude include() {
    return GeocodeHousenumberInclude._();
  }

  static GeocodeHousenumberIncludeList includeList({
    _i1.WhereExpressionBuilder<GeocodeHousenumberTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodeHousenumberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodeHousenumberTable>? orderByList,
    GeocodeHousenumberInclude? include,
  }) {
    return GeocodeHousenumberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodeHousenumber.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GeocodeHousenumber.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodeHousenumberImpl extends GeocodeHousenumber {
  _GeocodeHousenumberImpl({
    int? id,
    required String streetId,
    required String street,
    required String housenumber,
    required double latitude,
    required double longitude,
  }) : super._(
         id: id,
         streetId: streetId,
         street: street,
         housenumber: housenumber,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [GeocodeHousenumber]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodeHousenumber copyWith({
    Object? id = _Undefined,
    String? streetId,
    String? street,
    String? housenumber,
    double? latitude,
    double? longitude,
  }) {
    return GeocodeHousenumber(
      id: id is int? ? id : this.id,
      streetId: streetId ?? this.streetId,
      street: street ?? this.street,
      housenumber: housenumber ?? this.housenumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class GeocodeHousenumberUpdateTable
    extends _i1.UpdateTable<GeocodeHousenumberTable> {
  GeocodeHousenumberUpdateTable(super.table);

  _i1.ColumnValue<String, String> streetId(String value) => _i1.ColumnValue(
    table.streetId,
    value,
  );

  _i1.ColumnValue<String, String> street(String value) => _i1.ColumnValue(
    table.street,
    value,
  );

  _i1.ColumnValue<String, String> housenumber(String value) => _i1.ColumnValue(
    table.housenumber,
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
}

class GeocodeHousenumberTable extends _i1.Table<int?> {
  GeocodeHousenumberTable({super.tableRelation})
    : super(tableName: 'geocode_housenumber') {
    updateTable = GeocodeHousenumberUpdateTable(this);
    streetId = _i1.ColumnString(
      'streetId',
      this,
    );
    street = _i1.ColumnString(
      'street',
      this,
    );
    housenumber = _i1.ColumnString(
      'housenumber',
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
  }

  late final GeocodeHousenumberUpdateTable updateTable;

  late final _i1.ColumnString streetId;

  late final _i1.ColumnString street;

  late final _i1.ColumnString housenumber;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  @override
  List<_i1.Column> get columns => [
    id,
    streetId,
    street,
    housenumber,
    latitude,
    longitude,
  ];
}

class GeocodeHousenumberInclude extends _i1.IncludeObject {
  GeocodeHousenumberInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => GeocodeHousenumber.t;
}

class GeocodeHousenumberIncludeList extends _i1.IncludeList {
  GeocodeHousenumberIncludeList._({
    _i1.WhereExpressionBuilder<GeocodeHousenumberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GeocodeHousenumber.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => GeocodeHousenumber.t;
}

class GeocodeHousenumberRepository {
  const GeocodeHousenumberRepository._();

  /// Returns a list of [GeocodeHousenumber]s matching the given query parameters.
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
  Future<List<GeocodeHousenumber>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodeHousenumberTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodeHousenumberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodeHousenumberTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GeocodeHousenumber>(
      where: where?.call(GeocodeHousenumber.t),
      orderBy: orderBy?.call(GeocodeHousenumber.t),
      orderByList: orderByList?.call(GeocodeHousenumber.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GeocodeHousenumber] matching the given query parameters.
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
  Future<GeocodeHousenumber?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodeHousenumberTable>? where,
    int? offset,
    _i1.OrderByBuilder<GeocodeHousenumberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GeocodeHousenumberTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GeocodeHousenumber>(
      where: where?.call(GeocodeHousenumber.t),
      orderBy: orderBy?.call(GeocodeHousenumber.t),
      orderByList: orderByList?.call(GeocodeHousenumber.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GeocodeHousenumber] by its [id] or null if no such row exists.
  Future<GeocodeHousenumber?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GeocodeHousenumber>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GeocodeHousenumber]s in the list and returns the inserted rows.
  ///
  /// The returned [GeocodeHousenumber]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<GeocodeHousenumber>> insert(
    _i1.DatabaseSession session,
    List<GeocodeHousenumber> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<GeocodeHousenumber>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [GeocodeHousenumber] and returns the inserted row.
  ///
  /// The returned [GeocodeHousenumber] will have its `id` field set.
  Future<GeocodeHousenumber> insertRow(
    _i1.DatabaseSession session,
    GeocodeHousenumber row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GeocodeHousenumber>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GeocodeHousenumber]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GeocodeHousenumber>> update(
    _i1.DatabaseSession session,
    List<GeocodeHousenumber> rows, {
    _i1.ColumnSelections<GeocodeHousenumberTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GeocodeHousenumber>(
      rows,
      columns: columns?.call(GeocodeHousenumber.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodeHousenumber]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GeocodeHousenumber> updateRow(
    _i1.DatabaseSession session,
    GeocodeHousenumber row, {
    _i1.ColumnSelections<GeocodeHousenumberTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GeocodeHousenumber>(
      row,
      columns: columns?.call(GeocodeHousenumber.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GeocodeHousenumber] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GeocodeHousenumber?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<GeocodeHousenumberUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GeocodeHousenumber>(
      id,
      columnValues: columnValues(GeocodeHousenumber.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GeocodeHousenumber]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GeocodeHousenumber>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<GeocodeHousenumberUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<GeocodeHousenumberTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GeocodeHousenumberTable>? orderBy,
    _i1.OrderByListBuilder<GeocodeHousenumberTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GeocodeHousenumber>(
      columnValues: columnValues(GeocodeHousenumber.t.updateTable),
      where: where(GeocodeHousenumber.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GeocodeHousenumber.t),
      orderByList: orderByList?.call(GeocodeHousenumber.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GeocodeHousenumber]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GeocodeHousenumber>> delete(
    _i1.DatabaseSession session,
    List<GeocodeHousenumber> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GeocodeHousenumber>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GeocodeHousenumber].
  Future<GeocodeHousenumber> deleteRow(
    _i1.DatabaseSession session,
    GeocodeHousenumber row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GeocodeHousenumber>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GeocodeHousenumber>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodeHousenumberTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GeocodeHousenumber>(
      where: where(GeocodeHousenumber.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<GeocodeHousenumberTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GeocodeHousenumber>(
      where: where?.call(GeocodeHousenumber.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GeocodeHousenumber] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<GeocodeHousenumberTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GeocodeHousenumber>(
      where: where(GeocodeHousenumber.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
