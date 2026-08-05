import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../data/comms_plan_repository.dart';

final commsPlansProvider =
    AsyncNotifierProvider<CommsPlansNotifier, List<CommsPlan>>(
      CommsPlansNotifier.new,
    );

class CommsPlansNotifier extends AsyncNotifier<List<CommsPlan>> {
  @override
  Future<List<CommsPlan>> build() {
    ref.watch(offlineModeActiveProvider);
    return _load();
  }

  Future<List<CommsPlan>> _load() async {
    if (ref.read(offlineModeActiveProvider)) {
      AppLogger.logMap.info('📡 Comms plans unavailable offline');
      return const [];
    }
    final plans = await ref.read(commsPlanRepositoryProvider).listPlans();
    AppLogger.logMap.success(
      '📡 Comms plans loaded',
      data: 'count=${plans.length}',
    );
    return plans;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CommsPlan> create(CommsPlan plan) async {
    if (ref.read(offlineModeActiveProvider)) {
      throw StateError('Comms plans are read-only offline.');
    }
    final created = await ref
        .read(commsPlanRepositoryProvider)
        .createPlan(plan);
    await reload();
    return created;
  }

  Future<CommsPlan> updatePlan(CommsPlan plan) async {
    if (ref.read(offlineModeActiveProvider)) {
      throw StateError('Comms plans are read-only offline.');
    }
    final updated = await ref
        .read(commsPlanRepositoryProvider)
        .updatePlan(plan);
    await reload();
    return updated;
  }

  Future<void> delete(UuidValue id) async {
    if (ref.read(offlineModeActiveProvider)) {
      throw StateError('Comms plans are read-only offline.');
    }
    await ref.read(commsPlanRepositoryProvider).deletePlan(id);
    await reload();
  }
}

/// Prefer the first active plan; otherwise the first plan by sort order.
CommsPlan? activeCommsPlan(List<CommsPlan> plans) {
  for (final plan in plans) {
    if (plan.active) {
      return plan;
    }
  }
  return plans.isEmpty ? null : plans.first;
}
