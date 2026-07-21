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
import '../watch_log/watch_log_entry.dart' as _i2;
import 'package:wayfinder_server/src/generated/protocol.dart' as _i3;

abstract class WatchLogEntryChange
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  WatchLogEntryChange._({
    required this.type,
    this.entry,
    this.entryId,
  });

  factory WatchLogEntryChange({
    required String type,
    _i2.WatchLogEntry? entry,
    _i1.UuidValue? entryId,
  }) = _WatchLogEntryChangeImpl;

  factory WatchLogEntryChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return WatchLogEntryChange(
      type: jsonSerialization['type'] as String,
      entry: jsonSerialization['entry'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.WatchLogEntry>(
              jsonSerialization['entry'],
            ),
      entryId: jsonSerialization['entryId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['entryId']),
    );
  }

  /// One of: created, updated, deleted, bulk
  String type;

  _i2.WatchLogEntry? entry;

  _i1.UuidValue? entryId;

  /// Returns a shallow copy of this [WatchLogEntryChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WatchLogEntryChange copyWith({
    String? type,
    _i2.WatchLogEntry? entry,
    _i1.UuidValue? entryId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WatchLogEntryChange',
      'type': type,
      if (entry != null) 'entry': entry?.toJson(),
      if (entryId != null) 'entryId': entryId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WatchLogEntryChange',
      'type': type,
      if (entry != null) 'entry': entry?.toJsonForProtocol(),
      if (entryId != null) 'entryId': entryId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WatchLogEntryChangeImpl extends WatchLogEntryChange {
  _WatchLogEntryChangeImpl({
    required String type,
    _i2.WatchLogEntry? entry,
    _i1.UuidValue? entryId,
  }) : super._(
         type: type,
         entry: entry,
         entryId: entryId,
       );

  /// Returns a shallow copy of this [WatchLogEntryChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WatchLogEntryChange copyWith({
    String? type,
    Object? entry = _Undefined,
    Object? entryId = _Undefined,
  }) {
    return WatchLogEntryChange(
      type: type ?? this.type,
      entry: entry is _i2.WatchLogEntry? ? entry : this.entry?.copyWith(),
      entryId: entryId is _i1.UuidValue? ? entryId : this.entryId,
    );
  }
}
