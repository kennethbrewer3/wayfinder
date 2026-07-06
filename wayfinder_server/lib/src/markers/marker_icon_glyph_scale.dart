const markerIconGlyphScaleMin = 0.5;
const markerIconGlyphScaleMax = 5.0;

double parseMarkerIconGlyphScale(double raw) {
  if (raw < markerIconGlyphScaleMin || raw > markerIconGlyphScaleMax) {
    throw FormatException(
      'Field "glyphScale" must be between '
      '$markerIconGlyphScaleMin and $markerIconGlyphScaleMax',
    );
  }
  return raw;
}
