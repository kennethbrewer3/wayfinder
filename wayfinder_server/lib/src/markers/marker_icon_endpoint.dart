import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';

class MarkerIconEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'markerIcons';

  Future<List<MarkerIconCatalogEntry>> listCatalog(Session session) {
    return loggedCall(
      session,
      _tag,
      'listCatalog',
      () => MarkerIconCatalogEntry.db.find(
        session,
        orderBy: (t) => t.sortOrder,
      ),
      onSuccess: (entries) => 'count=${entries.length}',
    );
  }
}
