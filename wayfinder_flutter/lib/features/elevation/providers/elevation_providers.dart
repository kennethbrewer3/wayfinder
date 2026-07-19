import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../data/elevation_sampler.dart';

/// Enabled DEM catalog entries (filename heuristic + enabled toggle/group).
final elevationDemEntriesProvider = FutureProvider<List<PmtilesArchiveEntry>>((
  ref,
) async {
  ref.watch(pmtilesRevisionProvider);
  final repository = ref.watch(pmtilesRepositoryProvider);
  final entries = await repository.resolveElevationDemEntries();
  AppLogger.logPmtiles.info(
    '⛰️ DEM catalog',
    data: entries.isEmpty
        ? 'none enabled'
        : entries
              .map(
                (e) =>
                    '${e.name} z${e.minZoom}-${e.maxZoom} '
                    'boundsKnown=${e.boundsKnown}',
              )
              .join('; '),
  );
  return entries;
});

final elevationSamplerProvider = FutureProvider<ElevationSampler>((ref) async {
  final entries = await ref.watch(elevationDemEntriesProvider.future);
  final sampler = ElevationSampler(demEntries: entries);
  ref.onDispose(() {
    unawaited(sampler.dispose());
  });
  return sampler;
});

/// Spot elevation at [point], null when unavailable.
final elevationAtProvider = FutureProvider.family<double?, LatLng>((
  ref,
  point,
) async {
  final sampler = await ref.watch(elevationSamplerProvider.future);
  if (!sampler.hasDem) {
    return null;
  }
  return sampler.elevationAt(point);
});
