import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../data/tides_repository.dart';

final tidesRepositoryProvider = Provider<TidesRepository>((ref) {
  return TidesRepository(ref.watch(serverClientProvider));
});

final tidePacksProvider = FutureProvider.autoDispose<List<TidePackInfo>>((
  ref,
) {
  return ref.watch(tidesRepositoryProvider).listPacks();
});

final tideCoastalRegionsProvider =
    FutureProvider.autoDispose<List<TideCoastalRegion>>((ref) {
      return ref.watch(tidesRepositoryProvider).listCoastalRegions();
    });

void refreshTidePacks(WidgetRef ref) {
  ref.invalidate(tidePacksProvider);
}
