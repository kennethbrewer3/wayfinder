import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../data/map_data_repository.dart';

final mapDataRepositoryProvider = Provider<MapDataRepository>(
  (ref) => MapDataRepository(client: ref.watch(serverClientProvider)),
);

void refreshMapData(WidgetRef ref) {
  ref.invalidate(layersProvider);
  ref.invalidate(markersProvider);
  ref.read(zonesProvider.notifier).reload();
}
