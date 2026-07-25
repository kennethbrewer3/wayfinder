import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import 'app_globals.dart';

/// Bumped when [applyAppServerConfig] rebuilds the global [client].
final serverClientEpochProvider = StateProvider<int>((ref) => 0);

final serverClientProvider = Provider<Client>((ref) {
  ref.watch(serverClientEpochProvider);
  return client;
});
