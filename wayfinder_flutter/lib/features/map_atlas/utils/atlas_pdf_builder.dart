import 'dart:math' as math;
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../circles/models/circle_geometry.dart';
import '../../lines/models/line_geometry.dart';
import '../../lines/utils/line_distance.dart';
import '../../map/utils/mgrs_utils.dart';
import '../../polygons/models/polygon_geometry.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import '../../tracks/models/track_geometry.dart';
import '../models/atlas_bounds.dart';
import '../models/atlas_sheet.dart';
import 'atlas_basemap_renderer.dart';
import 'atlas_tiler.dart';
import 'atlas_web_mercator.dart';

// Matches the on-map MGRS line color (light theme).
const _mgrsLineColor = PdfColor.fromInt(0xE6C62828);
const _mgrsLabelColor = PdfColor.fromInt(0xFFB71C1C);

enum AtlasPageSize { letterLandscape, a4Landscape }

enum AtlasCoverageMode { currentMapView, fitMarkers }

class AtlasExportOptions {
  const AtlasExportOptions({
    required this.title,
    required this.coverageMode,
    required this.columns,
    required this.rows,
    required this.pageSize,
    this.includeMarkerIndex = true,
  });

  final String title;
  final AtlasCoverageMode coverageMode;
  final int columns;
  final int rows;
  final AtlasPageSize pageSize;
  final bool includeMarkerIndex;
}

PdfPageFormat _pdfFormat(AtlasPageSize size) {
  return switch (size) {
    AtlasPageSize.letterLandscape => PdfPageFormat.letter.landscape,
    AtlasPageSize.a4Landscape => PdfPageFormat.a4.landscape,
  };
}

Future<Uint8List> buildAtlasPdf({
  required AtlasExportOptions options,
  required AtlasBounds coverage,
  required List<MapMarker> markers,
  required List<MapZone> zones,
  List<PmtilesArchiveEntry> enabledPmtiles = const [],
  bool includeMgrsGrid = false,
}) async {
  final sheets = tileAtlasBounds(
    coverage: coverage,
    columns: options.columns,
    rows: options.rows,
  );
  if (sheets.isEmpty) {
    throw StateError('Atlas coverage produced no sheets');
  }

  final visibleMarkers = markers.where((marker) => marker.visible).toList();
  final visibleZones = zones.where((zone) => zone.visible).toList();
  final basemapBySheetId = <String, Uint8List>{};
  if (enabledPmtiles.isNotEmpty) {
    for (final sheet in sheets) {
      final png = await renderAtlasBasemapPng(
        bounds: sheet.bounds,
        enabledEntries: enabledPmtiles,
      );
      if (png != null) {
        basemapBySheetId[sheet.id] = png;
      }
    }
  }

  final doc = pw.Document(
    title: options.title,
    author: 'Wayfinder',
    creator: 'Wayfinder printable atlas',
  );
  final format = _pdfFormat(options.pageSize);
  final hasBasemap = basemapBySheetId.isNotEmpty;

  doc.addPage(
    pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => _IndexPage(
        title: options.title,
        coverage: coverage,
        sheets: sheets,
        markerCount: visibleMarkers.length,
        zoneCount: visibleZones.length,
        hasBasemap: hasBasemap,
        includeMgrsGrid: includeMgrsGrid,
      ),
    ),
  );

  for (final sheet in sheets) {
    final sheetMarkers = visibleMarkers
        .where(
          (marker) => sheet.bounds.contains(
            LatLng(marker.latitude, marker.longitude),
          ),
        )
        .toList();
    final sheetZoom = pickAtlasTileZoom(sheet.bounds).toDouble();
    final mgrsGeometry = includeMgrsGrid
        ? buildMgrsGrid(
            bounds: MgrsLatLngBounds(
              south: sheet.bounds.south,
              west: sheet.bounds.west,
              north: sheet.bounds.north,
              east: sheet.bounds.east,
              longitudeCenter: sheet.bounds.centerLongitude,
              longitudeWidth: sheet.bounds.lngSpan,
            ),
            zoom: sheetZoom,
          )
        : MgrsGridGeometry.empty;
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => _SheetPage(
          title: options.title,
          sheet: sheet,
          markers: sheetMarkers,
          zones: visibleZones,
          includeMarkerIndex: options.includeMarkerIndex,
          basemapPng: basemapBySheetId[sheet.id],
          mgrsGeometry: mgrsGeometry,
        ),
      ),
    );
  }

  return doc.save();
}

class _IndexPage extends pw.StatelessWidget {
  _IndexPage({
    required this.title,
    required this.coverage,
    required this.sheets,
    required this.markerCount,
    required this.zoneCount,
    required this.hasBasemap,
    required this.includeMgrsGrid,
  });

  final String title;
  final AtlasBounds coverage;
  final List<AtlasSheet> sheets;
  final int markerCount;
  final int zoneCount;
  final bool hasBasemap;
  final bool includeMgrsGrid;

  @override
  pw.Widget build(pw.Context context) {
    final generated = DateTime.now().toUtc();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Printable atlas · generated ${generated.toIso8601String()}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Coverage ${coverage.south.toStringAsFixed(5)}, '
          '${coverage.west.toStringAsFixed(5)} to '
          '${coverage.north.toStringAsFixed(5)}, '
          '${coverage.east.toStringAsFixed(5)}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '${sheets.length} sheets · $markerCount markers · $zoneCount zones',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 12),
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 1),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.CustomPaint(
                painter: (canvas, size) => _paintIndexOverview(
                  canvas: canvas,
                  size: size,
                  coverage: coverage,
                  sheets: sheets,
                ),
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          [
            if (hasBasemap)
              'Sheets include the enabled PMTiles basemap plus overlays.'
            else
              'No PMTiles basemap was available for this export; sheets show '
                  'overlays on a grid. Enable map tiles and try again for a '
                  'full basemap.',
            if (includeMgrsGrid)
              'MGRS grid is included because it was enabled on the map.',
            'Edge sheets overlap slightly. Center MGRS labels are approximate.',
          ].join(' '),
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }
}

class _SheetPage extends pw.StatelessWidget {
  _SheetPage({
    required this.title,
    required this.sheet,
    required this.markers,
    required this.zones,
    required this.includeMarkerIndex,
    this.basemapPng,
    this.mgrsGeometry = MgrsGridGeometry.empty,
  });

  final String title;
  final AtlasSheet sheet;
  final List<MapMarker> markers;
  final List<MapZone> zones;
  final bool includeMarkerIndex;
  final Uint8List? basemapPng;
  final MgrsGridGeometry mgrsGeometry;

  @override
  pw.Widget build(pw.Context context) {
    final centerMgrs = _safeMgrs(sheet.bounds.center);
    final widthMeters = lineLengthMeters(
      LatLng(sheet.bounds.centerLatitude, sheet.bounds.west),
      LatLng(sheet.bounds.centerLatitude, sheet.bounds.east),
    );
    final basemapImage = basemapPng == null
        ? null
        : PdfImage.file(context.document, bytes: basemapPng!);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$title · Sheet ${sheet.id}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'SW ${sheet.bounds.south.toStringAsFixed(5)}, '
                    '${sheet.bounds.west.toStringAsFixed(5)}   '
                    'NE ${sheet.bounds.north.toStringAsFixed(5)}, '
                    '${sheet.bounds.east.toStringAsFixed(5)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Center MGRS: $centerMgrs',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
            pw.Text(
              'Sheet ${sheet.column + 1}/${sheet.columns} · '
              'Row ${sheet.row + 1}/${sheet.rows}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Expanded(
          flex: includeMarkerIndex && markers.isNotEmpty ? 7 : 10,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey800, width: 1.2),
              color: PdfColors.grey100,
            ),
            child: pw.CustomPaint(
              painter: (canvas, size) => _paintSheetMap(
                canvas: canvas,
                size: size,
                sheet: sheet,
                markers: markers,
                zones: zones,
                widthMeters: widthMeters,
                basemap: basemapImage,
                mgrsGeometry: mgrsGeometry,
              ),
            ),
          ),
        ),
        if (includeMarkerIndex && markers.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'Markers on this sheet',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Expanded(
            flex: 3,
            child: pw.ListView(
              children: [
                for (final marker in markers.take(20))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text(
                      '${marker.name}  ·  '
                      '${marker.latitude.toStringAsFixed(5)}, '
                      '${marker.longitude.toStringAsFixed(5)}  ·  '
                      '${_safeMgrs(LatLng(marker.latitude, marker.longitude))}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                if (markers.length > 20)
                  pw.Text(
                    '+${markers.length - 20} more markers on this sheet',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String _safeMgrs(LatLng point) {
  try {
    return formatMgrs(latLngToMgrs(point, accuracy: 3));
  } catch (_) {
    return 'n/a';
  }
}

void _paintIndexOverview({
  required PdfGraphics canvas,
  required PdfPoint size,
  required AtlasBounds coverage,
  required List<AtlasSheet> sheets,
}) {
  final map = _SheetProjector(coverage, size);
  final font = canvas.defaultFont;
  canvas
    ..setStrokeColor(PdfColors.blueGrey800)
    ..setLineWidth(1.2)
    ..drawRect(0, 0, size.x, size.y)
    ..strokePath();

  for (final sheet in sheets) {
    final sw = map.project(LatLng(sheet.bounds.south, sheet.bounds.west));
    final ne = map.project(LatLng(sheet.bounds.north, sheet.bounds.east));
    final left = math.min(sw.x, ne.x);
    final right = math.max(sw.x, ne.x);
    final top = math.min(sw.y, ne.y);
    final bottom = math.max(sw.y, ne.y);
    canvas
      ..setStrokeColor(PdfColors.blue700)
      ..setLineWidth(0.8)
      ..drawRect(left, top, right - left, bottom - top)
      ..strokePath();
    if (font != null) {
      canvas
        ..setFillColor(PdfColors.blue900)
        ..drawString(
          font,
          10,
          sheet.id,
          (left + right) / 2 - 8,
          (top + bottom) / 2 - 4,
        );
    }
  }
}

void _paintSheetMap({
  required PdfGraphics canvas,
  required PdfPoint size,
  required AtlasSheet sheet,
  required List<MapMarker> markers,
  required List<MapZone> zones,
  required double widthMeters,
  PdfImage? basemap,
  MgrsGridGeometry mgrsGeometry = MgrsGridGeometry.empty,
}) {
  final font = canvas.defaultFont;
  final margin = 10.0;
  final plot = PdfPoint(size.x - margin * 2, size.y - margin * 2 - 28);
  final plotOrigin = PdfPoint(margin, margin);
  final plotMap = _SheetProjector(
    sheet.bounds,
    plot,
    origin: plotOrigin,
  );
  final showMgrs = mgrsGeometry.lines.isNotEmpty;

  canvas
    ..setFillColor(PdfColors.grey100)
    ..drawRect(0, 0, size.x, size.y)
    ..fillPath();

  if (basemap != null) {
    canvas.drawImage(
      basemap,
      plotOrigin.x,
      plotOrigin.y,
      plot.x,
      plot.y,
    );
  }

  canvas
    ..setStrokeColor(PdfColors.blueGrey800)
    ..setLineWidth(1)
    ..drawRect(plotOrigin.x, plotOrigin.y, plot.x, plot.y)
    ..strokePath();

  // Lat/lng reference grid only when MGRS is off (both together is confusing).
  if (!showMgrs) {
    canvas
      ..setStrokeColor(basemap == null ? PdfColors.grey400 : PdfColors.grey600)
      ..setLineWidth(basemap == null ? 0.4 : 0.25);
    for (var i = 1; i < 5; i++) {
      final lat = sheet.bounds.south + sheet.bounds.latSpan * i / 5;
      final lng = sheet.bounds.west + sheet.bounds.lngSpan * i / 5;
      final west = plotMap.project(LatLng(lat, sheet.bounds.west));
      final east = plotMap.project(LatLng(lat, sheet.bounds.east));
      final south = plotMap.project(LatLng(sheet.bounds.south, lng));
      final north = plotMap.project(LatLng(sheet.bounds.north, lng));
      canvas
        ..drawLine(west.x, west.y, east.x, east.y)
        ..drawLine(south.x, south.y, north.x, north.y);
    }
    canvas.strokePath();
  }

  if (showMgrs) {
    _paintMgrsGrid(
      canvas: canvas,
      plotMap: plotMap,
      plotOrigin: plotOrigin,
      plot: plot,
      geometry: mgrsGeometry,
      font: font,
    );
  }

  for (final zone in zones) {
    _paintZone(canvas, plotMap, zone);
  }

  for (final marker in markers) {
    final point = plotMap.project(
      LatLng(marker.latitude, marker.longitude),
    );
    canvas
      ..setFillColor(PdfColors.red800)
      ..drawEllipse(point.x - 3, point.y - 3, 6, 6)
      ..fillPath();
    if (font != null) {
      canvas
        ..setFillColor(PdfColors.black)
        ..drawString(font, 7, marker.name, point.x + 5, point.y - 3);
    }
  }

  // PDF y increases upward — tip must be at higher y for true north.
  final nx = plotOrigin.x + plot.x - 22;
  final ny = plotOrigin.y + plot.y - 28;
  canvas
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(1.2)
    ..drawLine(nx, ny - 14, nx, ny + 14)
    ..drawLine(nx, ny + 14, nx - 4, ny + 6)
    ..drawLine(nx, ny + 14, nx + 4, ny + 6)
    ..strokePath();
  if (font != null) {
    canvas
      ..setFillColor(PdfColors.black)
      ..drawString(font, 8, 'N', nx - 3, ny + 16);
  }

  final barMeters = _niceScaleMeters(widthMeters / 4);
  final barFraction = (barMeters / widthMeters).clamp(0.05, 0.45);
  final barWidth = plot.x * barFraction;
  final bx = plotOrigin.x + 12;
  final by = plotOrigin.y + plot.y + 14;
  canvas
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(1.5)
    ..drawLine(bx, by, bx + barWidth, by)
    ..drawLine(bx, by - 4, bx, by + 4)
    ..drawLine(bx + barWidth, by - 4, bx + barWidth, by + 4)
    ..strokePath();
  if (font != null) {
    canvas
      ..setFillColor(PdfColors.black)
      ..drawString(font, 8, _formatScaleLabel(barMeters), bx, by + 6)
      ..setFillColor(PdfColors.grey800)
      ..drawString(
        font,
        6.5,
        sheet.bounds.south.toStringAsFixed(4),
        plotOrigin.x + 2,
        plotOrigin.y + 2,
      )
      ..drawString(
        font,
        6.5,
        sheet.bounds.north.toStringAsFixed(4),
        plotOrigin.x + 2,
        plotOrigin.y + plot.y - 10,
      );
  }
}

void _paintMgrsGrid({
  required PdfGraphics canvas,
  required _SheetProjector plotMap,
  required PdfPoint plotOrigin,
  required PdfPoint plot,
  required MgrsGridGeometry geometry,
  required PdfFont? font,
}) {
  canvas
    ..saveContext()
    ..drawRect(plotOrigin.x, plotOrigin.y, plot.x, plot.y)
    ..clipPath()
    ..setStrokeColor(_mgrsLineColor)
    ..setLineWidth(geometry.accuracy <= 1 ? 1.1 : 0.8);

  for (final line in geometry.lines) {
    if (line.length < 2) {
      continue;
    }
    for (var i = 0; i < line.length - 1; i++) {
      final a = plotMap.project(line[i]);
      final b = plotMap.project(line[i + 1]);
      canvas.drawLine(a.x, a.y, b.x, b.y);
    }
  }
  canvas.strokePath();

  if (font != null) {
    for (final label in geometry.labels.take(40)) {
      final point = plotMap.project(label.point);
      if (point.x < plotOrigin.x ||
          point.x > plotOrigin.x + plot.x ||
          point.y < plotOrigin.y ||
          point.y > plotOrigin.y + plot.y) {
        continue;
      }
      canvas
        ..setFillColor(PdfColors.white)
        ..drawRect(point.x - 2, point.y - 2, label.text.length * 4.2 + 4, 9)
        ..fillPath()
        ..setFillColor(_mgrsLabelColor)
        ..drawString(font, 7, label.text, point.x, point.y);
    }
  }

  canvas.restoreContext();
}

void _paintZone(
  PdfGraphics canvas,
  _SheetProjector map,
  MapZone zone,
) {
  switch (zone.type) {
    case lineZoneType:
      final geometry = LineGeometry.fromZone(zone);
      if (geometry == null || !geometry.isValid) {
        return;
      }
      _paintPolyline(canvas, map, geometry.points, PdfColors.indigo700);
    case trackZoneType:
      final geometry = TrackGeometry.fromZone(zone);
      if (geometry == null || !geometry.hasRenderablePath) {
        return;
      }
      _paintPolyline(canvas, map, geometry.pathPoints, PdfColors.teal700);
    case circleZoneType:
      final geometry = CircleGeometry.fromZone(zone);
      if (geometry == null || !geometry.isValid) {
        return;
      }
      _paintCircleApprox(canvas, map, geometry);
    case rectangleZoneType:
      final rectangle = RectangleGeometry.fromZone(zone);
      if (rectangle == null || !rectangle.isValid) {
        return;
      }
      _paintRectangle(canvas, map, rectangle);
    case polygonZoneType:
      final polygon = PolygonGeometry.fromZone(zone);
      if (polygon == null || !polygon.isValid) {
        return;
      }
      _paintPolygon(canvas, map, polygon);
    default:
      break;
  }
}

void _paintPolyline(
  PdfGraphics canvas,
  _SheetProjector map,
  List<LatLng> points,
  PdfColor color,
) {
  if (points.length < 2) {
    return;
  }
  canvas
    ..setStrokeColor(color)
    ..setLineWidth(1.1);
  for (var i = 0; i < points.length - 1; i++) {
    final a = map.project(points[i]);
    final b = map.project(points[i + 1]);
    canvas.drawLine(a.x, a.y, b.x, b.y);
  }
  canvas.strokePath();
}

void _paintCircleApprox(
  PdfGraphics canvas,
  _SheetProjector map,
  CircleGeometry geometry,
) {
  const metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng =
      metersPerDegreeLat * math.cos(geometry.center.latitude * math.pi / 180);
  final dLat = geometry.radiusMeters / metersPerDegreeLat;
  final dLng = geometry.radiusMeters / math.max(metersPerDegreeLng, 1);
  final sw = map.project(
    LatLng(geometry.center.latitude - dLat, geometry.center.longitude - dLng),
  );
  final ne = map.project(
    LatLng(geometry.center.latitude + dLat, geometry.center.longitude + dLng),
  );
  final left = math.min(sw.x, ne.x);
  final top = math.min(sw.y, ne.y);
  final width = (sw.x - ne.x).abs();
  final height = (sw.y - ne.y).abs();
  canvas
    ..setStrokeColor(PdfColors.deepOrange700)
    ..setLineWidth(1)
    ..drawEllipse(left, top, width, height)
    ..strokePath();
}

void _paintRectangle(
  PdfGraphics canvas,
  _SheetProjector map,
  RectangleGeometry rectangle,
) {
  final b = rectangle.bounds;
  final corners = [
    LatLng(b.south, b.west),
    LatLng(b.south, b.east),
    LatLng(b.north, b.east),
    LatLng(b.north, b.west),
  ];
  canvas
    ..setStrokeColor(PdfColors.purple700)
    ..setLineWidth(1);
  for (var i = 0; i < corners.length; i++) {
    final a = map.project(corners[i]);
    final c = map.project(corners[(i + 1) % corners.length]);
    canvas.drawLine(a.x, a.y, c.x, c.y);
  }
  canvas.strokePath();
}

void _paintPolygon(
  PdfGraphics canvas,
  _SheetProjector map,
  PolygonGeometry polygon,
) {
  final points = polygon.points;
  if (points.length < 3) {
    return;
  }
  canvas
    ..setStrokeColor(PdfColors.pink800)
    ..setLineWidth(1.1);
  for (var i = 0; i < points.length; i++) {
    final a = map.project(points[i]);
    final b = map.project(points[(i + 1) % points.length]);
    canvas.drawLine(a.x, a.y, b.x, b.y);
  }
  canvas.strokePath();
}

double _niceScaleMeters(double raw) {
  if (raw <= 0 || raw.isNaN) {
    return 100;
  }
  final exponent = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final fraction = raw / exponent;
  final nice = fraction < 1.5
      ? 1.0
      : fraction < 3
      ? 2.0
      : fraction < 7
      ? 5.0
      : 10.0;
  return nice * exponent;
}

String _formatScaleLabel(double meters) {
  if (meters >= 1000) {
    final km = meters / 1000;
    return km >= 10 ? '${km.round()} km' : '${km.toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}

/// Projects lat/lng into the sheet plot using Web Mercator (matches basemap).
class _SheetProjector {
  _SheetProjector(
    this.bounds,
    this.size, {
    PdfPoint? origin,
  }) : origin = origin ?? const PdfPoint(0, 0),
       _westX = lngToMercatorX(bounds.west),
       _eastX = lngToMercatorX(bounds.east),
       _southY = latToMercatorY(bounds.south),
       _northY = latToMercatorY(bounds.north);

  final AtlasBounds bounds;
  final PdfPoint size;
  final PdfPoint origin;
  final double _westX;
  final double _eastX;
  final double _southY;
  final double _northY;

  PdfPoint project(LatLng point) {
    final mx = lngToMercatorX(point.longitude);
    final my = latToMercatorY(point.latitude);
    final xSpan = _eastX - _westX;
    final ySpan = _southY - _northY; // south mercY > north mercY
    final x = origin.x + ((mx - _westX) / xSpan) * size.x;
    // PDF y increases upward; smaller mercY (north) maps to higher PDF y.
    final y = origin.y + ((_southY - my) / ySpan) * size.y;
    return PdfPoint(x, y);
  }
}
