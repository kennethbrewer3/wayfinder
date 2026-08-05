import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';

class CommsPlanRepository {
  CommsPlanRepository(this._client);

  final Client _client;

  Future<List<CommsPlan>> listPlans() => _client.commsPlan.listPlans();

  Future<CommsPlan> createPlan(CommsPlan plan) =>
      _client.commsPlan.createPlan(plan);

  Future<CommsPlan> updatePlan(CommsPlan plan) =>
      _client.commsPlan.updatePlan(plan);

  Future<bool> deletePlan(UuidValue id) => _client.commsPlan.deletePlan(id);
}

final commsPlanRepositoryProvider = Provider<CommsPlanRepository>(
  (ref) => CommsPlanRepository(ref.watch(serverClientProvider)),
);
