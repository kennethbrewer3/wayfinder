import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../main.dart';

final serverClientProvider = Provider<Client>((ref) => client);
