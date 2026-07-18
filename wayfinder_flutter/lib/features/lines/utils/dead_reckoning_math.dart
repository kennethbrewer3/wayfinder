/// Converts a pace count and pace length into ground distance in meters.
double distanceMetersFromPaces({
  required double paceCount,
  required double paceLengthMeters,
}) {
  if (paceCount.isNaN ||
      paceLengthMeters.isNaN ||
      paceCount < 0 ||
      paceLengthMeters <= 0) {
    return 0;
  }
  return paceCount * paceLengthMeters;
}
