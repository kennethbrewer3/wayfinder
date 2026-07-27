/// Decodes a Google-encoded polyline into [lat, lon] pairs.
///
/// GraphHopper returns polylines with five decimal places of precision by
/// default. We prefer `points_encoded: false` at request time, but keep this
/// helper for compatibility and unit tests.
List<List<double>> decodePolyline(String encoded) {
  final coordinates = <List<double>>[];
  var index = 0;
  var lat = 0;
  var lon = 0;

  while (index < encoded.length) {
    lat += _decodeComponent(encoded, index, (value) => index = value);
    lon += _decodeComponent(encoded, index, (value) => index = value);
    coordinates.add([lat / 1e5, lon / 1e5]);
  }

  return coordinates;
}

int _decodeComponent(
  String encoded,
  int startIndex,
  void Function(int nextIndex) setIndex,
) {
  var result = 0;
  var shift = 0;
  var index = startIndex;

  while (index < encoded.length) {
    final byte = encoded.codeUnitAt(index++) - 63;
    result |= (byte & 0x1f) << shift;
    shift += 5;
    if (byte < 0x20) {
      break;
    }
  }

  final decoded = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  setIndex(index);
  return decoded;
}
