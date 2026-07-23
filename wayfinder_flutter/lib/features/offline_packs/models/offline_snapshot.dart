import 'package:wayfinder_client/wayfinder_client.dart';

/// Cached map objects for an offline pack (selected layers + optional seasonal).
class OfflineSnapshot {
  const OfflineSnapshot({
    required this.layers,
    required this.markers,
    required this.zones,
    required this.watchLogEntries,
    required this.capturedAt,
    this.seasonalOverlays = const [],
  });

  final List<MapLayer> layers;
  final List<MapMarker> markers;
  final List<MapZone> zones;
  final List<WatchLogEntry> watchLogEntries;
  final List<SeasonalOverlay> seasonalOverlays;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
    'capturedAt': capturedAt.toIso8601String(),
    'layers': [for (final layer in layers) layer.toJson()],
    'markers': [for (final marker in markers) marker.toJson()],
    'zones': [for (final zone in zones) zone.toJson()],
    'watchLogEntries': [
      for (final entry in watchLogEntries) entry.toJson(),
    ],
    'seasonalOverlays': [
      for (final overlay in seasonalOverlays) overlay.toJson(),
    ],
  };

  factory OfflineSnapshot.fromJson(Map<String, dynamic> json) {
    return OfflineSnapshot(
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      layers: [
        for (final raw in json['layers'] as List? ?? const [])
          MapLayer.fromJson(raw as Map<String, dynamic>),
      ],
      markers: [
        for (final raw in json['markers'] as List? ?? const [])
          MapMarker.fromJson(raw as Map<String, dynamic>),
      ],
      zones: [
        for (final raw in json['zones'] as List? ?? const [])
          MapZone.fromJson(raw as Map<String, dynamic>),
      ],
      watchLogEntries: [
        for (final raw in json['watchLogEntries'] as List? ?? const [])
          WatchLogEntry.fromJson(raw as Map<String, dynamic>),
      ],
      seasonalOverlays: [
        for (final raw in json['seasonalOverlays'] as List? ?? const [])
          SeasonalOverlay.fromJson(raw as Map<String, dynamic>),
      ],
    );
  }

  OfflineSnapshot copyWith({
    List<MapLayer>? layers,
    List<MapMarker>? markers,
    List<MapZone>? zones,
    List<WatchLogEntry>? watchLogEntries,
    List<SeasonalOverlay>? seasonalOverlays,
    DateTime? capturedAt,
  }) {
    return OfflineSnapshot(
      layers: layers ?? this.layers,
      markers: markers ?? this.markers,
      zones: zones ?? this.zones,
      watchLogEntries: watchLogEntries ?? this.watchLogEntries,
      seasonalOverlays: seasonalOverlays ?? this.seasonalOverlays,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}
