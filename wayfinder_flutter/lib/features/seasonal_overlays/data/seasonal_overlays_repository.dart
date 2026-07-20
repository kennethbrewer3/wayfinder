import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';

class SeasonalOverlaysRepository {
  SeasonalOverlaysRepository(this._client);

  final Client _client;

  Future<List<SeasonalOverlay>> listOverlays() {
    return _client.seasonalOverlay.listOverlays();
  }

  Future<SeasonalOverlay> createOverlay(SeasonalOverlay overlay) {
    return _client.seasonalOverlay.createOverlay(overlay);
  }

  Future<SeasonalOverlay> updateOverlay(SeasonalOverlay overlay) {
    return _client.seasonalOverlay.updateOverlay(overlay);
  }

  Future<bool> deleteOverlay(UuidValue id) {
    return _client.seasonalOverlay.deleteOverlay(id);
  }

  Future<List<SeasonalOverlay>> reorderOverlays(
    List<SeasonalOverlay> overlays,
  ) {
    return _client.seasonalOverlay.reorderOverlays(overlays);
  }
}

final seasonalOverlaysRepositoryProvider = Provider<SeasonalOverlaysRepository>(
  (ref) => SeasonalOverlaysRepository(ref.watch(serverClientProvider)),
);
