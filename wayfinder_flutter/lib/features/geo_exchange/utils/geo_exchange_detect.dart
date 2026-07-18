import '../models/geo_exchange_models.dart';

GeoExchangeFormat? detectGeoExchangeFormat({
  required String fileName,
  required String contents,
}) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.gpx')) {
    return GeoExchangeFormat.gpx;
  }
  if (lower.endsWith('.kml')) {
    return GeoExchangeFormat.kml;
  }
  if (lower.endsWith('.geojson') || lower.endsWith('.json')) {
    final trimmed = contents.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return GeoExchangeFormat.geojson;
    }
  }

  final head = contents.trimLeft().toLowerCase();
  if (head.contains('<gpx')) {
    return GeoExchangeFormat.gpx;
  }
  if (head.contains('<kml')) {
    return GeoExchangeFormat.kml;
  }
  if (head.startsWith('{') || head.startsWith('[')) {
    return GeoExchangeFormat.geojson;
  }
  return null;
}
