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

abstract class GeocodeSearchResult implements _i1.SerializableModel {
  GeocodeSearchResult._({
    required this.id,
    required this.name,
    this.displayName,
    required this.latitude,
    required this.longitude,
    this.countryCode,
    required this.importance,
    String? resultType,
  }) : resultType = resultType ?? 'place';

  factory GeocodeSearchResult({
    required int id,
    required String name,
    String? displayName,
    required double latitude,
    required double longitude,
    String? countryCode,
    required double importance,
    String? resultType,
  }) = _GeocodeSearchResultImpl;

  factory GeocodeSearchResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return GeocodeSearchResult(
      id: jsonSerialization['id'] as int,
      name: jsonSerialization['name'] as String,
      displayName: jsonSerialization['displayName'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      countryCode: jsonSerialization['countryCode'] as String?,
      importance: (jsonSerialization['importance'] as num).toDouble(),
      resultType: jsonSerialization['resultType'] as String?,
    );
  }

  int id;

  String name;

  String? displayName;

  double latitude;

  double longitude;

  String? countryCode;

  double importance;

  String resultType;

  /// Returns a shallow copy of this [GeocodeSearchResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeocodeSearchResult copyWith({
    int? id,
    String? name,
    String? displayName,
    double? latitude,
    double? longitude,
    String? countryCode,
    double? importance,
    String? resultType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeocodeSearchResult',
      'id': id,
      'name': name,
      if (displayName != null) 'displayName': displayName,
      'latitude': latitude,
      'longitude': longitude,
      if (countryCode != null) 'countryCode': countryCode,
      'importance': importance,
      'resultType': resultType,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeocodeSearchResultImpl extends GeocodeSearchResult {
  _GeocodeSearchResultImpl({
    required int id,
    required String name,
    String? displayName,
    required double latitude,
    required double longitude,
    String? countryCode,
    required double importance,
    String? resultType,
  }) : super._(
         id: id,
         name: name,
         displayName: displayName,
         latitude: latitude,
         longitude: longitude,
         countryCode: countryCode,
         importance: importance,
         resultType: resultType,
       );

  /// Returns a shallow copy of this [GeocodeSearchResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeocodeSearchResult copyWith({
    int? id,
    String? name,
    Object? displayName = _Undefined,
    double? latitude,
    double? longitude,
    Object? countryCode = _Undefined,
    double? importance,
    String? resultType,
  }) {
    return GeocodeSearchResult(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName is String? ? displayName : this.displayName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      countryCode: countryCode is String? ? countryCode : this.countryCode,
      importance: importance ?? this.importance,
      resultType: resultType ?? this.resultType,
    );
  }
}
