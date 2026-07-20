import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../data/seasonal_overlays_repository.dart';
import '../models/seasonal_date_window.dart';

const _showInactivePrefsKey = 'seasonal_overlays_show_inactive';

final seasonalOverlaysProvider =
    AsyncNotifierProvider<SeasonalOverlaysNotifier, List<SeasonalOverlay>>(
      SeasonalOverlaysNotifier.new,
    );

class SeasonalOverlaysNotifier extends AsyncNotifier<List<SeasonalOverlay>> {
  @override
  Future<List<SeasonalOverlay>> build() {
    return _load();
  }

  Future<List<SeasonalOverlay>> _load() async {
    AppLogger.logMap.debug('📡 Fetching seasonal overlays');
    final overlays = await ref
        .read(seasonalOverlaysRepositoryProvider)
        .listOverlays();
    AppLogger.logMap.success(
      '📡 Seasonal overlays loaded',
      data: 'count=${overlays.length}',
    );
    return overlays;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<SeasonalOverlay> create(SeasonalOverlay overlay) async {
    final created = await ref
        .read(seasonalOverlaysRepositoryProvider)
        .createOverlay(overlay);
    await reload();
    return created;
  }

  Future<SeasonalOverlay> updateOverlay(SeasonalOverlay overlay) async {
    final updated = await ref
        .read(seasonalOverlaysRepositoryProvider)
        .updateOverlay(overlay);
    await reload();
    return updated;
  }

  Future<void> delete(UuidValue id) async {
    await ref.read(seasonalOverlaysRepositoryProvider).deleteOverlay(id);
    await reload();
  }

  Future<void> setVisible(UuidValue id, bool visible) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    SeasonalOverlay? overlay;
    for (final entry in current) {
      if (entry.id == id) {
        overlay = entry;
        break;
      }
    }
    if (overlay == null) {
      return;
    }
    await updateOverlay(
      overlay.copyWith(
        visible: visible,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}

/// When true, overlays outside their date window still render (dimmed).
final showInactiveSeasonalOverlaysProvider =
    NotifierProvider<ShowInactiveSeasonalOverlaysNotifier, bool>(
      ShowInactiveSeasonalOverlaysNotifier.new,
    );

class ShowInactiveSeasonalOverlaysNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_showInactivePrefsKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showInactivePrefsKey, enabled);
  }
}

bool shouldRenderSeasonalOverlay({
  required SeasonalOverlay overlay,
  required bool showInactive,
  DateTime? on,
}) {
  if (!overlay.visible) {
    return false;
  }
  final active = isSeasonalOverlayActive(
    dateMode: overlay.dateMode,
    dateWindowsJson: overlay.dateWindowsJson,
    on: on,
  );
  return active || showInactive;
}

bool isSeasonalOverlayCurrentlyActive(SeasonalOverlay overlay, {DateTime? on}) {
  return isSeasonalOverlayActive(
    dateMode: overlay.dateMode,
    dateWindowsJson: overlay.dateWindowsJson,
    on: on,
  );
}
