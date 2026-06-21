import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pmtiles_load_status.dart';

final pmtilesLoadStatusProvider =
    NotifierProvider<PmtilesLoadStatusNotifier, PmtilesLoadStatus>(
  PmtilesLoadStatusNotifier.new,
);

class PmtilesLoadStatusNotifier extends Notifier<PmtilesLoadStatus> {
  @override
  PmtilesLoadStatus build() => PmtilesLoadStatus.initial;

  void update(PmtilesLoadStatus status) {
    state = status;
  }
}
