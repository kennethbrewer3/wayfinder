import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Stable anonymous deduplication key for geocoding contributions.
abstract final class GeocodingContributionContentKey {
  static String compute({
    required String name,
    required double latitude,
    required double longitude,
  }) {
    final normalizedName = name.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final lat = latitude.toStringAsFixed(5);
    final lng = longitude.toStringAsFixed(5);
    final payload = '$normalizedName|$lat|$lng';
    return sha256.convert(utf8.encode(payload)).toString();
  }
}
