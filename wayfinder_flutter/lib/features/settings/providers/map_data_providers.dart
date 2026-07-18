import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/serverpod_client.dart';
import '../../circles/providers/circle_size_display_provider.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/angle_display_format_provider.dart';
import '../../lines/providers/measurement_units_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../map/providers/home_location_provider.dart';
import '../../map/providers/map_zoom_range_provider.dart';
import '../../map/providers/map_compass_rose_provider.dart';
import '../../map/providers/map_mgrs_grid_provider.dart';
import '../../map/providers/map_viewport_debug_provider.dart';
import '../../markers/providers/map_marker_size_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../markers/providers/marker_icon_providers.dart';
import '../providers/app_locale_provider.dart';
import '../providers/app_theme_provider.dart';
import '../providers/pmtiles_providers.dart';
import '../data/map_data_repository.dart';

final mapDataRepositoryProvider = Provider<MapDataRepository>(
  (ref) => MapDataRepository(client: ref.watch(serverClientProvider)),
);

void refreshMapData(WidgetRef ref) {
  ref.invalidate(layersProvider);
  ref.invalidate(markersProvider);
  ref.read(zonesProvider.notifier).reload();
  refreshMarkerIcons(ref);
  refreshUserSettings(ref);
}

void refreshUserSettings(WidgetRef ref) {
  ref.read(homeLocationProvider.notifier).reload();
  ref.read(measurementUnitsProvider.notifier).reload();
  ref.read(angleDisplayFormatProvider.notifier).reload();
  ref.read(circleSizeDisplayProvider.notifier).reload();
  ref.read(appThemeProvider.notifier).reload();
  ref.read(appLocaleProvider.notifier).reload();
  ref.read(mapMarkerSizeScaleProvider.notifier).reload();
  ref.read(mapViewportDebugBorderProvider.notifier).reload();
  ref.read(mapTileBorderDebugProvider.notifier).reload();
  ref.read(mapCompassRoseEnabledProvider.notifier).reload();
  ref.read(mapMgrsGridEnabledProvider.notifier).reload();
  ref.read(mapZoomRangeProvider.notifier).reload();
  refreshPmtiles(ref);
}
