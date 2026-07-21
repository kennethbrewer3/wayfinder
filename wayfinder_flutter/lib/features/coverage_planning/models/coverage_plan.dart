import 'package:latlong2/latlong.dart';

import '../../lines/utils/bearing_utils.dart';
import '../../markers/models/marker_radio.dart';
import '../../viewshed/utils/viewshed_compute.dart';

/// Built-in coverage planning templates (geometric + LOS-oriented defaults).
enum CoverageTemplateKind {
  mesh,
  repeater,
  shack;

  String get markerIcon => switch (this) {
    CoverageTemplateKind.mesh => 'mesh_network_node',
    CoverageTemplateKind.repeater => 'radio_repeater',
    CoverageTemplateKind.shack => 'ham_shack',
  };

  MarkerRadioRole get radioRole => switch (this) {
    CoverageTemplateKind.mesh => MarkerRadioRole.station,
    CoverageTemplateKind.repeater => MarkerRadioRole.repeater,
    CoverageTemplateKind.shack => MarkerRadioRole.shack,
  };

  /// Suggested coverage radius for range circles (meters).
  double get defaultCoverageRadiusMeters => switch (this) {
    CoverageTemplateKind.mesh => 3000,
    CoverageTemplateKind.repeater => 25000,
    CoverageTemplateKind.shack => 10000,
  };

  /// Suggested center-to-center spacing for a hex ring (meters).
  ///
  /// Slightly less than 2× radius so neighboring coverage circles overlap.
  double get defaultSpacingMeters => defaultCoverageRadiusMeters * 1.7;

  double get defaultAntennaHeightMeters =>
      defaultAntennaHeightForMarkerIcon(markerIcon);

  /// Marker / circle accent color (ARGB).
  int get accentColorValue => switch (this) {
    CoverageTemplateKind.mesh => 0xFF2A9D8F,
    CoverageTemplateKind.repeater => 0xFFE76F51,
    CoverageTemplateKind.shack => 0xFF1B4965,
  };
}

enum CoverageLayoutKind {
  /// Seed site only (one marker + one coverage circle).
  single,

  /// Seed plus six neighbors on a hex ring at [spacingMeters].
  hexRing,
}

class CoveragePlanSite {
  const CoveragePlanSite({
    required this.center,
    required this.label,
    required this.isSeed,
  });

  final LatLng center;
  final String label;
  final bool isSeed;
}

class CoveragePlanSpec {
  const CoveragePlanSpec({
    required this.template,
    required this.layout,
    required this.seed,
    required this.coverageRadiusMeters,
    required this.spacingMeters,
    this.createMarkers = true,
    this.createCircles = true,
    this.runViewshedOnSeed = false,
  });

  final CoverageTemplateKind template;
  final CoverageLayoutKind layout;
  final LatLng seed;
  final double coverageRadiusMeters;
  final double spacingMeters;
  final bool createMarkers;
  final bool createCircles;
  final bool runViewshedOnSeed;

  List<CoveragePlanSite> sites() {
    return buildCoveragePlanSites(
      seed: seed,
      layout: layout,
      spacingMeters: spacingMeters,
    );
  }
}

/// Builds candidate site centers for a coverage plan.
List<CoveragePlanSite> buildCoveragePlanSites({
  required LatLng seed,
  required CoverageLayoutKind layout,
  required double spacingMeters,
}) {
  final sites = <CoveragePlanSite>[
    CoveragePlanSite(center: seed, label: '1', isSeed: true),
  ];
  if (layout == CoverageLayoutKind.single) {
    return sites;
  }

  final spacing = spacingMeters.clamp(50.0, 100000.0);
  for (var i = 0; i < 6; i++) {
    final bearing = i * 60.0;
    sites.add(
      CoveragePlanSite(
        center: pointAtTrueBearing(
          anchor: seed,
          bearingDegrees: bearing,
          distanceMeters: spacing,
        ),
        label: '${i + 2}',
        isSeed: false,
      ),
    );
  }
  return sites;
}
