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
import '../seasonal_overlays/seasonal_overlay.dart' as _i2;
import 'package:wayfinder_client/src/protocol/protocol.dart' as _i3;

abstract class SeasonalOverlayChange implements _i1.SerializableModel {
  SeasonalOverlayChange._({
    required this.type,
    this.overlay,
    this.overlayId,
  });

  factory SeasonalOverlayChange({
    required String type,
    _i2.SeasonalOverlay? overlay,
    _i1.UuidValue? overlayId,
  }) = _SeasonalOverlayChangeImpl;

  factory SeasonalOverlayChange.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SeasonalOverlayChange(
      type: jsonSerialization['type'] as String,
      overlay: jsonSerialization['overlay'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.SeasonalOverlay>(
              jsonSerialization['overlay'],
            ),
      overlayId: jsonSerialization['overlayId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['overlayId']),
    );
  }

  /// One of: created, updated, deleted, bulk
  String type;

  _i2.SeasonalOverlay? overlay;

  _i1.UuidValue? overlayId;

  /// Returns a shallow copy of this [SeasonalOverlayChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SeasonalOverlayChange copyWith({
    String? type,
    _i2.SeasonalOverlay? overlay,
    _i1.UuidValue? overlayId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeasonalOverlayChange',
      'type': type,
      if (overlay != null) 'overlay': overlay?.toJson(),
      if (overlayId != null) 'overlayId': overlayId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeasonalOverlayChangeImpl extends SeasonalOverlayChange {
  _SeasonalOverlayChangeImpl({
    required String type,
    _i2.SeasonalOverlay? overlay,
    _i1.UuidValue? overlayId,
  }) : super._(
         type: type,
         overlay: overlay,
         overlayId: overlayId,
       );

  /// Returns a shallow copy of this [SeasonalOverlayChange]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SeasonalOverlayChange copyWith({
    String? type,
    Object? overlay = _Undefined,
    Object? overlayId = _Undefined,
  }) {
    return SeasonalOverlayChange(
      type: type ?? this.type,
      overlay: overlay is _i2.SeasonalOverlay?
          ? overlay
          : this.overlay?.copyWith(),
      overlayId: overlayId is _i1.UuidValue? ? overlayId : this.overlayId,
    );
  }
}
