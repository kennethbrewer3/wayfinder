import 'package:serverpod/serverpod.dart';

import '../access/wayfinder_permissions.dart';
import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'comms_plan_change_broadcast.dart';

class CommsPlanEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'commsPlan';

  Future<List<CommsPlan>> listPlans(Session session) {
    return loggedCall(
      session,
      _tag,
      'listPlans',
      () => CommsPlan.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      ),
      onSuccess: (plans) => 'count=${plans.length}',
    );
  }

  Future<CommsPlan?> getPlan(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getPlan',
      () => CommsPlan.db.findById(session, id),
      onSuccess: (plan) => plan == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<CommsPlan> createPlan(Session session, CommsPlan plan) {
    return loggedCall(
      session,
      _tag,
      'createPlan',
      () async {
        final now = DateTime.now().toUtc();
        final created = await CommsPlan.db.insertRow(
          session,
          plan.copyWith(
            channelsJson: plan.channelsJson.trim().isEmpty
                ? '[]'
                : plan.channelsJson,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await CommsPlanChangeBroadcast.created(session, created);
        return created;
      },
      onSuccess: (created) => 'id=${created.id} name="${created.name}"',
      requiredPermission: WayfinderPermission.manageLayers,
    );
  }

  Future<CommsPlan> updatePlan(Session session, CommsPlan plan) {
    return loggedCall(
      session,
      _tag,
      'updatePlan',
      () async {
        final updated = await CommsPlan.db.updateRow(
          session,
          plan.copyWith(updatedAt: DateTime.now().toUtc()),
        );
        await CommsPlanChangeBroadcast.updated(session, updated);
        return updated;
      },
      onSuccess: (updated) =>
          'id=${updated.id} active=${updated.active} channels=${updated.channelsJson.length}',
      requiredPermission: WayfinderPermission.manageLayers,
    );
  }

  Future<bool> deletePlan(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deletePlan',
      () async {
        final deleted = await CommsPlan.db.deleteWhere(
          session,
          where: (t) => t.id.equals(id),
        );
        if (deleted.isNotEmpty) {
          await CommsPlanChangeBroadcast.deleted(session, id);
        }
        return deleted.isNotEmpty;
      },
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
      requiredPermission: WayfinderPermission.manageLayers,
    );
  }

  Stream<CommsPlanChange> planChanges(Session session) async* {
    final changes = session.messages.createStream<CommsPlanChange>(
      CommsPlanChangeBroadcast.channel,
    );
    await for (final change in changes) {
      yield change;
    }
  }
}
