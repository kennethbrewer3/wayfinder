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

abstract class RestApiKeyInfo implements _i1.SerializableModel {
  RestApiKeyInfo._({
    required this.enabled,
    this.keyPreview,
    this.apiKey,
  });

  factory RestApiKeyInfo({
    required bool enabled,
    String? keyPreview,
    String? apiKey,
  }) = _RestApiKeyInfoImpl;

  factory RestApiKeyInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestApiKeyInfo(
      enabled: _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      keyPreview: jsonSerialization['keyPreview'] as String?,
      apiKey: jsonSerialization['apiKey'] as String?,
    );
  }

  bool enabled;

  String? keyPreview;

  /// Plaintext key; only returned immediately after generate or rotate.
  String? apiKey;

  /// Returns a shallow copy of this [RestApiKeyInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RestApiKeyInfo copyWith({
    bool? enabled,
    String? keyPreview,
    String? apiKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestApiKeyInfo',
      'enabled': enabled,
      if (keyPreview != null) 'keyPreview': keyPreview,
      if (apiKey != null) 'apiKey': apiKey,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RestApiKeyInfoImpl extends RestApiKeyInfo {
  _RestApiKeyInfoImpl({
    required bool enabled,
    String? keyPreview,
    String? apiKey,
  }) : super._(
         enabled: enabled,
         keyPreview: keyPreview,
         apiKey: apiKey,
       );

  /// Returns a shallow copy of this [RestApiKeyInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RestApiKeyInfo copyWith({
    bool? enabled,
    Object? keyPreview = _Undefined,
    Object? apiKey = _Undefined,
  }) {
    return RestApiKeyInfo(
      enabled: enabled ?? this.enabled,
      keyPreview: keyPreview is String? ? keyPreview : this.keyPreview,
      apiKey: apiKey is String? ? apiKey : this.apiKey,
    );
  }
}
