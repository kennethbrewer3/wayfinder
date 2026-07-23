import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'marker_attachment_service.dart';

class MarkerAttachmentEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'markerAttachments';

  Future<List<MarkerAttachment>> listForMarker(
    Session session,
    UuidValue markerId,
  ) {
    return loggedCall(
      session,
      _tag,
      'listForMarker',
      () => MarkerAttachmentService.listForMarker(session, markerId),
      onSuccess: (entries) => 'marker=${markerId.uuid} count=${entries.length}',
      requiresWrite: false,
    );
  }

  Future<bool> deleteAttachment(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteAttachment',
      () => MarkerAttachmentService.deleteAttachment(session, id),
      onSuccess: (deleted) =>
          deleted ? 'deleted id=${id.uuid}' : 'not found id=${id.uuid}',
    );
  }
}
