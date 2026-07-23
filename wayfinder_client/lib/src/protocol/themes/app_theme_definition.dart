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

abstract class AppThemeDefinition implements _i1.SerializableModel {
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

  /// The id of the object.
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
