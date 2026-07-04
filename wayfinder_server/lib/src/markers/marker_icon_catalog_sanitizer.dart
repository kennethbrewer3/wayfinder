import '../generated/protocol.dart';
import 'marker_icon_storage.dart';

/// Ensures catalog entries do not advertise missing SVG files.
abstract final class MarkerIconCatalogSanitizer {
  static MarkerIconCatalogEntry effectiveEntry(
    MarkerIconCatalogEntry entry, {
    required MarkerIconStorage storage,
  }) {
    if (entry.hasCustomSvg && !storage.exists(entry.key)) {
      return entry.copyWith(hasCustomSvg: false);
    }
    return entry;
  }

  static List<MarkerIconCatalogEntry> effectiveEntries(
    Iterable<MarkerIconCatalogEntry> entries, {
    MarkerIconStorage? storage,
  }) {
    final resolvedStorage = storage ?? MarkerIconStorage();
    return [
      for (final entry in entries)
        effectiveEntry(entry, storage: resolvedStorage),
    ];
  }
}
