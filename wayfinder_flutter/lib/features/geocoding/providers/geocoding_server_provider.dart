import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/geocoding_repository.dart';

final geocodingServerReachableProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(geocodingRepositoryProvider);
  if (!repository.isConfigured) {
    return false;
  }
  return repository.isServerReachable();
});
