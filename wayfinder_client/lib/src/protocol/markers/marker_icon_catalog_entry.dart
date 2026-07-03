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

abstract class MarkerIconCatalogEntry implements _i1.SerializableModel {
  MarkerIconCatalogEntry._({
    _i1.UuidValue? id,
    required this.key,
    required this.label,
    this.materialIcon,
    required this.coloredAsset,
    required this.glyphScale,
    required this.hasCustomSvg,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory MarkerIconCatalogEntry({
    _i1.UuidValue? id,
    required String key,
    required String label,
    String? materialIcon,
    required bool coloredAsset,
    required double glyphScale,
    required bool hasCustomSvg,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarkerIconCatalogEntryImpl;

  factory MarkerIconCatalogEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MarkerIconCatalogEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
      materialIcon: jsonSerialization['materialIcon'] as String?,
      coloredAsset: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['coloredAsset'],
      ),
      glyphScale: (jsonSerialization['glyphScale'] as num).toDouble(),
      hasCustomSvg: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasCustomSvg'],
      ),
      sortOrder: jsonSerialization['sortOrder'] as int,
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

  String key;

  String label;

  String? materialIcon;

  bool coloredAsset;

  double glyphScale;

  bool hasCustomSvg;

  int sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MarkerIconCatalogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarkerIconCatalogEntry copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    String? materialIcon,
    bool? coloredAsset,
    double? glyphScale,
    bool? hasCustomSvg,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarkerIconCatalogEntry',
      'id': id.toJson(),
      'key': key,
      'label': label,
      if (materialIcon != null) 'materialIcon': materialIcon,
      'coloredAsset': coloredAsset,
      'glyphScale': glyphScale,
      'hasCustomSvg': hasCustomSvg,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MarkerIconCatalogEntryImpl extends MarkerIconCatalogEntry {
  _MarkerIconCatalogEntryImpl({
    _i1.UuidValue? id,
    required String key,
    required String label,
    String? materialIcon,
    required bool coloredAsset,
    required double glyphScale,
    required bool hasCustomSvg,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         key: key,
         label: label,
         materialIcon: materialIcon,
         coloredAsset: coloredAsset,
         glyphScale: glyphScale,
         hasCustomSvg: hasCustomSvg,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MarkerIconCatalogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarkerIconCatalogEntry copyWith({
    _i1.UuidValue? id,
    String? key,
    String? label,
    Object? materialIcon = _Undefined,
    bool? coloredAsset,
    double? glyphScale,
    bool? hasCustomSvg,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarkerIconCatalogEntry(
      id: id ?? this.id,
      key: key ?? this.key,
      label: label ?? this.label,
      materialIcon: materialIcon is String? ? materialIcon : this.materialIcon,
      coloredAsset: coloredAsset ?? this.coloredAsset,
      glyphScale: glyphScale ?? this.glyphScale,
      hasCustomSvg: hasCustomSvg ?? this.hasCustomSvg,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
