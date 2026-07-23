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

abstract class AppThemeDefinition
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  AppThemeDefinition._({
    _i1.UuidValue? id,
    required this.name,
    required this.brightness,
    required this.seedColor,
    required this.overridesJson,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory AppThemeDefinition({
    _i1.UuidValue? id,
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppThemeDefinitionImpl;

  factory AppThemeDefinition.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppThemeDefinition(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      brightness: jsonSerialization['brightness'] as String,
      seedColor: jsonSerialization['seedColor'] as String,
      overridesJson: jsonSerialization['overridesJson'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = AppThemeDefinitionTable();

  static const db = AppThemeDefinitionRepository._();

  @override
  _i1.UuidValue id;

  String name;

  /// light or dark
  String brightness;

  /// Hex color used as ColorScheme.fromSeed seed (#RRGGBB or #AARRGGBB)
  String seedColor;

  /// JSON object of optional ColorScheme role overrides (role -> hex)
  String overridesJson;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [AppThemeDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppThemeDefinition copyWith({
    _i1.UuidValue? id,
    String? name,
    String? brightness,
    String? seedColor,
    String? overridesJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppThemeDefinition',
      'id': id.toJson(),
      'name': name,
      'brightness': brightness,
      'seedColor': seedColor,
      'overridesJson': overridesJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppThemeDefinition',
      'id': id.toJson(),
      'name': name,
      'brightness': brightness,
      'seedColor': seedColor,
      'overridesJson': overridesJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AppThemeDefinitionInclude include() {
    return AppThemeDefinitionInclude._();
  }

  static AppThemeDefinitionIncludeList includeList({
    _i1.WhereExpressionBuilder<AppThemeDefinitionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppThemeDefinitionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppThemeDefinitionTable>? orderByList,
    AppThemeDefinitionInclude? include,
  }) {
    return AppThemeDefinitionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppThemeDefinition.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AppThemeDefinition.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AppThemeDefinitionImpl extends AppThemeDefinition {
  _AppThemeDefinitionImpl({
    _i1.UuidValue? id,
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         brightness: brightness,
         seedColor: seedColor,
         overridesJson: overridesJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AppThemeDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppThemeDefinition copyWith({
    _i1.UuidValue? id,
    String? name,
    String? brightness,
    String? seedColor,
    String? overridesJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppThemeDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
      overridesJson: overridesJson ?? this.overridesJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AppThemeDefinitionUpdateTable
    extends _i1.UpdateTable<AppThemeDefinitionTable> {
  AppThemeDefinitionUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> brightness(String value) => _i1.ColumnValue(
    table.brightness,
    value,
  );

  _i1.ColumnValue<String, String> seedColor(String value) => _i1.ColumnValue(
    table.seedColor,
    value,
  );

  _i1.ColumnValue<String, String> overridesJson(String value) =>
      _i1.ColumnValue(
        table.overridesJson,
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

class AppThemeDefinitionTable extends _i1.Table<_i1.UuidValue> {
  AppThemeDefinitionTable({super.tableRelation})
    : super(tableName: 'app_theme_definition') {
    updateTable = AppThemeDefinitionUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    brightness = _i1.ColumnString(
      'brightness',
      this,
    );
    seedColor = _i1.ColumnString(
      'seedColor',
      this,
    );
    overridesJson = _i1.ColumnString(
      'overridesJson',
      this,
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

  late final AppThemeDefinitionUpdateTable updateTable;

  late final _i1.ColumnString name;

  /// light or dark
  late final _i1.ColumnString brightness;

  /// Hex color used as ColorScheme.fromSeed seed (#RRGGBB or #AARRGGBB)
  late final _i1.ColumnString seedColor;

  /// JSON object of optional ColorScheme role overrides (role -> hex)
  late final _i1.ColumnString overridesJson;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    brightness,
    seedColor,
    overridesJson,
    createdAt,
    updatedAt,
  ];
}

class AppThemeDefinitionInclude extends _i1.IncludeObject {
  AppThemeDefinitionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => AppThemeDefinition.t;
}

class AppThemeDefinitionIncludeList extends _i1.IncludeList {
  AppThemeDefinitionIncludeList._({
    _i1.WhereExpressionBuilder<AppThemeDefinitionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppThemeDefinition.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => AppThemeDefinition.t;
}

class AppThemeDefinitionRepository {
  const AppThemeDefinitionRepository._();

  /// Returns a list of [AppThemeDefinition]s matching the given query parameters.
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
  Future<List<AppThemeDefinition>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppThemeDefinitionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppThemeDefinitionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppThemeDefinitionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AppThemeDefinition>(
      where: where?.call(AppThemeDefinition.t),
      orderBy: orderBy?.call(AppThemeDefinition.t),
      orderByList: orderByList?.call(AppThemeDefinition.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AppThemeDefinition] matching the given query parameters.
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
  Future<AppThemeDefinition?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppThemeDefinitionTable>? where,
    int? offset,
    _i1.OrderByBuilder<AppThemeDefinitionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AppThemeDefinitionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AppThemeDefinition>(
      where: where?.call(AppThemeDefinition.t),
      orderBy: orderBy?.call(AppThemeDefinition.t),
      orderByList: orderByList?.call(AppThemeDefinition.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AppThemeDefinition] by its [id] or null if no such row exists.
  Future<AppThemeDefinition?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AppThemeDefinition>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AppThemeDefinition]s in the list and returns the inserted rows.
  ///
  /// The returned [AppThemeDefinition]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AppThemeDefinition>> insert(
    _i1.DatabaseSession session,
    List<AppThemeDefinition> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AppThemeDefinition>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AppThemeDefinition] and returns the inserted row.
  ///
  /// The returned [AppThemeDefinition] will have its `id` field set.
  Future<AppThemeDefinition> insertRow(
    _i1.DatabaseSession session,
    AppThemeDefinition row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppThemeDefinition>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AppThemeDefinition]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AppThemeDefinition>> update(
    _i1.DatabaseSession session,
    List<AppThemeDefinition> rows, {
    _i1.ColumnSelections<AppThemeDefinitionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AppThemeDefinition>(
      rows,
      columns: columns?.call(AppThemeDefinition.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppThemeDefinition]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppThemeDefinition> updateRow(
    _i1.DatabaseSession session,
    AppThemeDefinition row, {
    _i1.ColumnSelections<AppThemeDefinitionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppThemeDefinition>(
      row,
      columns: columns?.call(AppThemeDefinition.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppThemeDefinition] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppThemeDefinition?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AppThemeDefinitionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AppThemeDefinition>(
      id,
      columnValues: columnValues(AppThemeDefinition.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppThemeDefinition]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AppThemeDefinition>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AppThemeDefinitionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AppThemeDefinitionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AppThemeDefinitionTable>? orderBy,
    _i1.OrderByListBuilder<AppThemeDefinitionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AppThemeDefinition>(
      columnValues: columnValues(AppThemeDefinition.t.updateTable),
      where: where(AppThemeDefinition.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppThemeDefinition.t),
      orderByList: orderByList?.call(AppThemeDefinition.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AppThemeDefinition]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AppThemeDefinition>> delete(
    _i1.DatabaseSession session,
    List<AppThemeDefinition> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AppThemeDefinition>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AppThemeDefinition].
  Future<AppThemeDefinition> deleteRow(
    _i1.DatabaseSession session,
    AppThemeDefinition row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppThemeDefinition>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AppThemeDefinition>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AppThemeDefinitionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AppThemeDefinition>(
      where: where(AppThemeDefinition.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AppThemeDefinitionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AppThemeDefinition>(
      where: where?.call(AppThemeDefinition.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AppThemeDefinition] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AppThemeDefinitionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AppThemeDefinition>(
      where: where(AppThemeDefinition.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
