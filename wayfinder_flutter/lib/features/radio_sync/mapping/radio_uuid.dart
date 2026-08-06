import 'package:wayfinder_client/wayfinder_client.dart';

/// Parse a UUID string; returns `null` if [raw] is not a valid UUID.
UuidValue? tryParseUuid(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    return UuidValue.fromString(raw);
  } catch (_) {
    return null;
  }
}

bool isUuidString(String? raw) => tryParseUuid(raw) != null;

DateTime radioSecondsToUtc(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

int radioUtcToSeconds(DateTime time) =>
    time.toUtc().millisecondsSinceEpoch ~/ 1000;
