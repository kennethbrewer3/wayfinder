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
import '../settings/rest_api_key.dart' as _i2;
import 'package:wayfinder_server/src/generated/protocol.dart' as _i3;

abstract class RestApiKeyCreated
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RestApiKeyCreated._({
    required this.key,
    required this.apiKey,
  });

  factory RestApiKeyCreated({
    required _i2.RestApiKey key,
    required String apiKey,
  }) = _RestApiKeyCreatedImpl;

  factory RestApiKeyCreated.fromJson(Map<String, dynamic> jsonSerialization) {
    return RestApiKeyCreated(
      key: _i3.Protocol().deserialize<_i2.RestApiKey>(jsonSerialization['key']),
      apiKey: jsonSerialization['apiKey'] as String,
    );
  }

  _i2.RestApiKey key;

  /// Plaintext key; only returned immediately after create.
  String apiKey;

  /// Returns a shallow copy of this [RestApiKeyCreated]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RestApiKeyCreated copyWith({
    _i2.RestApiKey? key,
    String? apiKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RestApiKeyCreated',
      'key': key.toJson(),
      'apiKey': apiKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RestApiKeyCreated',
      'key': key.toJsonForProtocol(),
      'apiKey': apiKey,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RestApiKeyCreatedImpl extends RestApiKeyCreated {
  _RestApiKeyCreatedImpl({
    required _i2.RestApiKey key,
    required String apiKey,
  }) : super._(
         key: key,
         apiKey: apiKey,
       );

  /// Returns a shallow copy of this [RestApiKeyCreated]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RestApiKeyCreated copyWith({
    _i2.RestApiKey? key,
    String? apiKey,
  }) {
    return RestApiKeyCreated(
      key: key ?? this.key.copyWith(),
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
