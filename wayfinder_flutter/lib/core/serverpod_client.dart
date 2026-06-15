import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import 'app_globals.dart';

final serverClientProvider = Provider<Client>((ref) => client);
