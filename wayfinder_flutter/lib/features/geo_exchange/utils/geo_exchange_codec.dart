import '../models/geo_exchange_models.dart';
import 'geo_exchange_detect.dart';
import 'geojson_codec.dart';
import 'gpx_codec.dart';
import 'kml_codec.dart';

GeoExchangeBundle parseGeoExchange({
  required String contents,
  required String fileName,
  GeoExchangeFormat? format,
}) {
  final resolved =
      format ?? detectGeoExchangeFormat(fileName: fileName, contents: contents);
  if (resolved == null) {
    throw FormatException(
      'Unrecognized geographic file. Use GPX, KML, or GeoJSON.',
    );
  }
  return switch (resolved) {
    GeoExchangeFormat.gpx => parseGpx(contents),
    GeoExchangeFormat.kml => parseKml(contents),
    GeoExchangeFormat.geojson => parseGeoJson(contents),
  };
}

String encodeGeoExchange(
  GeoExchangeBundle bundle, {
  required GeoExchangeFormat format,
}) {
  return switch (format) {
    GeoExchangeFormat.gpx => encodeGpx(bundle),
    GeoExchangeFormat.kml => encodeKml(bundle),
    GeoExchangeFormat.geojson => encodeGeoJson(bundle),
  };
}
