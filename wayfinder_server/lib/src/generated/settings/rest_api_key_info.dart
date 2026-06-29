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

abstract class RestApiKeyInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RestApiKeyInfo._({
    required this.enabled,
    required this.envKeyConfigured,
    this.apiKey,
  });

  factory RestApiKeyInfo({
    required bool enabled,
    required bool envKeyConfigured,
    String? apiKey,
  }) = _RestApiKeyInfoImpl;

  factory RestApiKeyInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestApiKeyInfo(
      enabled: _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      envKeyConfigured: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['envKeyConfigured'],
      ),
      apiKey: jsonSerialization['apiKey'] as String?,
    );
  }

  bool enabled;

  /// True when WAYFINDER_REST_API_KEY is set in the server environment.
  bool envKeyConfigured;

  /// Plaintext key; only returned immediately after create.
  String? apiKey;

  /// Returns a shallow copy of this [RestApiKeyInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RestApiKeyInfo copyWith({
    bool? enabled,
    bool? envKeyConfigured,
    String? apiKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestApiKeyInfo',
      'enabled': enabled,
      'envKeyConfigured': envKeyConfigured,
      if (apiKey != null) 'apiKey': apiKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RestApiKeyInfo',
      'enabled': enabled,
      'envKeyConfigured': envKeyConfigured,
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
    required bool envKeyConfigured,
    String? apiKey,
  }) : super._(
         enabled: enabled,
         envKeyConfigured: envKeyConfigured,
         apiKey: apiKey,
       );

  /// Returns a shallow copy of this [RestApiKeyInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RestApiKeyInfo copyWith({
    bool? enabled,
    bool? envKeyConfigured,
    Object? apiKey = _Undefined,
  }) {
    return RestApiKeyInfo(
      enabled: enabled ?? this.enabled,
      envKeyConfigured: envKeyConfigured ?? this.envKeyConfigured,
      apiKey: apiKey is String? ? apiKey : this.apiKey,
    );
  }
}
