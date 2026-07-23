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

abstract class MapDataRestoreSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MapDataRestoreSummary._({
    required this.layers,
    required this.markers,
    required this.zones,
    required this.seasonalOverlays,
    required this.watchLogEntries,
    required this.markerIconCategories,
    required this.markerIcons,
    int? markerAttachments,
  }) : markerAttachments = markerAttachments ?? 0;

  factory MapDataRestoreSummary({
    required int layers,
    required int markers,
    required int zones,
    required int seasonalOverlays,
    required int watchLogEntries,
    required int markerIconCategories,
    required int markerIcons,
    int? markerAttachments,
  }) = _MapDataRestoreSummaryImpl;

  factory MapDataRestoreSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MapDataRestoreSummary(
      layers: jsonSerialization['layers'] as int,
      markers: jsonSerialization['markers'] as int,
      zones: jsonSerialization['zones'] as int,
      seasonalOverlays: jsonSerialization['seasonalOverlays'] as int,
      watchLogEntries: jsonSerialization['watchLogEntries'] as int,
      markerIconCategories: jsonSerialization['markerIconCategories'] as int,
      markerIcons: jsonSerialization['markerIcons'] as int,
      markerAttachments: jsonSerialization['markerAttachments'] as int?,
    );
  }

  int layers;

  int markers;

  int zones;

  int seasonalOverlays;

  int watchLogEntries;

  int markerIconCategories;

  int markerIcons;

  int markerAttachments;

  /// Returns a shallow copy of this [MapDataRestoreSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MapDataRestoreSummary copyWith({
    int? layers,
    int? markers,
    int? zones,
    int? seasonalOverlays,
    int? watchLogEntries,
    int? markerIconCategories,
    int? markerIcons,
    int? markerAttachments,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapDataRestoreSummary',
      'layers': layers,
      'markers': markers,
      'zones': zones,
      'seasonalOverlays': seasonalOverlays,
      'watchLogEntries': watchLogEntries,
      'markerIconCategories': markerIconCategories,
      'markerIcons': markerIcons,
      'markerAttachments': markerAttachments,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MapDataRestoreSummary',
      'layers': layers,
      'markers': markers,
      'zones': zones,
      'seasonalOverlays': seasonalOverlays,
      'watchLogEntries': watchLogEntries,
      'markerIconCategories': markerIconCategories,
      'markerIcons': markerIcons,
      'markerAttachments': markerAttachments,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MapDataRestoreSummaryImpl extends MapDataRestoreSummary {
  _MapDataRestoreSummaryImpl({
    required int layers,
    required int markers,
    required int zones,
    required int seasonalOverlays,
    required int watchLogEntries,
    required int markerIconCategories,
    required int markerIcons,
    int? markerAttachments,
  }) : super._(
         layers: layers,
         markers: markers,
         zones: zones,
         seasonalOverlays: seasonalOverlays,
         watchLogEntries: watchLogEntries,
         markerIconCategories: markerIconCategories,
         markerIcons: markerIcons,
         markerAttachments: markerAttachments,
       );

  /// Returns a shallow copy of this [MapDataRestoreSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MapDataRestoreSummary copyWith({
    int? layers,
    int? markers,
    int? zones,
    int? seasonalOverlays,
    int? watchLogEntries,
    int? markerIconCategories,
    int? markerIcons,
    int? markerAttachments,
  }) {
    return MapDataRestoreSummary(
      layers: layers ?? this.layers,
      markers: markers ?? this.markers,
      zones: zones ?? this.zones,
      seasonalOverlays: seasonalOverlays ?? this.seasonalOverlays,
      watchLogEntries: watchLogEntries ?? this.watchLogEntries,
      markerIconCategories: markerIconCategories ?? this.markerIconCategories,
      markerIcons: markerIcons ?? this.markerIcons,
      markerAttachments: markerAttachments ?? this.markerAttachments,
    );
  }
}
