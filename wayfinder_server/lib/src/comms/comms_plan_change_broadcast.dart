import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

abstract final class CommsPlanChangeBroadcast {
  static const channel = 'comms-plan-changes';

  static const typeCreated = 'created';
  static const typeUpdated = 'updated';
  static const typeDeleted = 'deleted';
  static const typeBulk = 'bulk';

  static Future<void> created(Session session, CommsPlan plan) {
    return _post(
      session,
      CommsPlanChange(
        type: typeCreated,
        plan: plan,
        planId: plan.id,
      ),
    );
  }

  static Future<void> updated(Session session, CommsPlan plan) {
    return _post(
      session,
      CommsPlanChange(
        type: typeUpdated,
        plan: plan,
        planId: plan.id,
      ),
    );
  }

  static Future<void> deleted(Session session, UuidValue planId) {
    return _post(
      session,
      CommsPlanChange(
        type: typeDeleted,
        planId: planId,
      ),
    );
  }

  static Future<void> bulk(Session session) {
    return _post(
      session,
      CommsPlanChange(type: typeBulk),
    );
  }

  static Future<void> _post(Session session, CommsPlanChange change) {
    return session.messages.postMessage(channel, change);
  }
}
