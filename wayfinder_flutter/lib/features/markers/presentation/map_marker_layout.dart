import 'package:flutter/material.dart';

/// Bundled map pin SVG edited in design tools; icon slot read from element ids.
const mapMarkerPinAssetPath = 'assets/markers/marker_pin.svg';

/// On-map marker widget size in logical pixels.
const mapMarkerWidth = 44.0;
const mapMarkerHeight = 44.0;

/// Geographic [Marker.point] is anchored to the bottom-center of this widget
/// ([Alignment.topCenter] in flutter_map), so the painted tip at
/// `(width / 2, height)` sits on the coordinates.
const mapMarkerAnchorAlignment = Alignment.topCenter;
