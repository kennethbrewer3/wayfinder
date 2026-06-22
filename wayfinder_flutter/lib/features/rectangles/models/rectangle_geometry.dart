import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../utils/rectangle_bounds.dart';
import 'rectangle_size_display.dart';

const rectangleZoneType = 'rectangle';

enum RectangleCreationMode {
  centerExtent,
  corners,
}

extension RectangleCreationModeLabel on RectangleCreationMode {
  String get storageValue => switch (this) {
        RectangleCreationMode.centerExtent => 'center_extent',
        RectangleCreationMode.corners => 'corners',
      };

  String get label => switch (this) {
        RectangleCreationMode.centerExtent => 'Center rectangle',
        RectangleCreationMode.corners => 'Corner rectangle',
      };
}

RectangleCreationMode rectangleCreationModeFromJson(String? value) {
  return switch (value) {
    'corners' => RectangleCreationMode.corners,
    _ => RectangleCreationMode.centerExtent,
  };
}

class RectangleGeometry {
  const RectangleGeometry({
    required this.creationMode,
    required this.bounds,
    this.center,
    this.extentPoint,
    this.cornerA,
    this.cornerB,
    this.notes,
    this.sizeDisplay = RectangleSizeDisplay.dimensions,
    this.showNameLabel = false,
  });

  final RectangleCreationMode creationMode;
  final RectangleBounds bounds;
  final LatLng? center;
  final LatLng? extentPoint;
  final LatLng? cornerA;
  final LatLng? cornerB;
  final String? notes;
  final RectangleSizeDisplay sizeDisplay;
  final bool showNameLabel;

  bool get isValid => bounds.isValid;

  LatLng get labelPoint => bounds.center;

  LatLng? get centerMarkerPoint =>
      creationMode == RectangleCreationMode.centerExtent ? center : null;

  RectangleGeometry copyWith({
    RectangleCreationMode? creationMode,
    RectangleBounds? bounds,
    LatLng? center,
    LatLng? extentPoint,
    LatLng? cornerA,
    LatLng? cornerB,
    String? notes,
    RectangleSizeDisplay? sizeDisplay,
    bool? showNameLabel,
    bool clearNotes = false,
  }) {
    return RectangleGeometry(
      creationMode: creationMode ?? this.creationMode,
      bounds: bounds ?? this.bounds,
      center: center ?? this.center,
      extentPoint: extentPoint ?? this.extentPoint,
      cornerA: cornerA ?? this.cornerA,
      cornerB: cornerB ?? this.cornerB,
      notes: clearNotes ? null : notes ?? this.notes,
      sizeDisplay: sizeDisplay ?? this.sizeDisplay,
      showNameLabel: showNameLabel ?? this.showNameLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationMode': creationMode.storageValue,
      'bounds': bounds.toJson(),
      if (center != null) 'center': latLngToJson(center!),
      if (extentPoint != null) 'extentPoint': latLngToJson(extentPoint!),
      if (cornerA != null) 'cornerA': latLngToJson(cornerA!),
      if (cornerB != null) 'cornerB': latLngToJson(cornerB!),
      'sizeDisplay': rectangleSizeDisplayToJson(sizeDisplay),
      'showNameLabel': showNameLabel,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }

  String encode() => jsonEncode(toJson());

  static RectangleGeometry? fromZone(MapZone zone) {
    if (zone.type != rectangleZoneType) {
      return null;
    }
    return fromJsonString(zone.geometryJson);
  }

  static RectangleGeometry? fromJsonString(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return null;
      }
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static RectangleGeometry? fromJson(Map<String, dynamic> json) {
    final bounds = RectangleBounds.fromJson(json['bounds']);
    if (bounds == null) {
      return null;
    }

    return RectangleGeometry(
      creationMode: rectangleCreationModeFromJson(json['creationMode'] as String?),
      bounds: bounds,
      center: parseLatLng(json['center']),
      extentPoint: parseLatLng(json['extentPoint']),
      cornerA: parseLatLng(json['cornerA']),
      cornerB: parseLatLng(json['cornerB']),
      notes: json['notes'] as String?,
      sizeDisplay: rectangleSizeDisplayFromJson(json['sizeDisplay'] as String?),
      showNameLabel: json['showNameLabel'] == true,
    );
  }

  static RectangleGeometry centerExtent({
    required LatLng center,
    required LatLng extentPoint,
    RectangleSizeDisplay sizeDisplay = RectangleSizeDisplay.dimensions,
    bool showNameLabel = false,
    String? notes,
  }) {
    return RectangleGeometry(
      creationMode: RectangleCreationMode.centerExtent,
      center: center,
      extentPoint: extentPoint,
      bounds: boundsFromCenterExtent(center, extentPoint),
      sizeDisplay: sizeDisplay,
      showNameLabel: showNameLabel,
      notes: notes,
    );
  }

  static RectangleGeometry corners({
    required LatLng cornerA,
    required LatLng cornerB,
    RectangleSizeDisplay sizeDisplay = RectangleSizeDisplay.dimensions,
    bool showNameLabel = false,
    String? notes,
  }) {
    return RectangleGeometry(
      creationMode: RectangleCreationMode.corners,
      cornerA: cornerA,
      cornerB: cornerB,
      bounds: boundsFromCorners(cornerA, cornerB),
      sizeDisplay: sizeDisplay,
      showNameLabel: showNameLabel,
      notes: notes,
    );
  }
}

RectangleBounds translateBounds(RectangleBounds bounds, LatLng delta) {
  return RectangleBounds(
    north: bounds.north + delta.latitude,
    south: bounds.south + delta.latitude,
    east: bounds.east + delta.longitude,
    west: bounds.west + delta.longitude,
  );
}

RectangleGeometry applyRectangleCoordinateEdits(
  RectangleGeometry geometry, {
  required LatLng? center,
  required LatLng? cornerA,
  required LatLng? cornerB,
}) {
  switch (geometry.creationMode) {
    case RectangleCreationMode.centerExtent:
      final oldCenter = geometry.center ?? geometry.bounds.center;
      final newCenter = center ?? oldCenter;
      final delta = LatLng(
        newCenter.latitude - oldCenter.latitude,
        newCenter.longitude - oldCenter.longitude,
      );
      return geometry.copyWith(
        center: newCenter,
        extentPoint: geometry.extentPoint == null
            ? null
            : LatLng(
                geometry.extentPoint!.latitude + delta.latitude,
                geometry.extentPoint!.longitude + delta.longitude,
              ),
        bounds: translateBounds(geometry.bounds, delta),
      );
    case RectangleCreationMode.corners:
      final a = cornerA ?? geometry.cornerA ?? geometry.bounds.center;
      final b = cornerB ?? geometry.cornerB ?? geometry.bounds.center;
      return geometry.copyWith(
        cornerA: a,
        cornerB: b,
        bounds: boundsFromCorners(a, b),
      );
  }
}

LatLng? rectangleZoneCenter(MapZone zone) {
  return RectangleGeometry.fromZone(zone)?.bounds.center;
}

MapZone updateZoneRectangleGeometry(MapZone zone, RectangleGeometry geometry) {
  return zone.copyWith(
    geometryJson: geometry.encode(),
    updatedAt: DateTime.now().toUtc(),
  );
}
