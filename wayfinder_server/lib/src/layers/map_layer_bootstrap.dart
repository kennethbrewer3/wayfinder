import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Stable id for the seeded default layer (matches migration SQL).
final defaultMapLayerId = UuidValue.fromString(
  '00000000-0000-4000-8000-000000000001',
);

/// Returns all layers, creating and backfilling a default layer when needed.
Future<List<MapLayer>> listLayersEnsuringDefault(Session session) async {
  var layers = await MapLayer.db.find(
    session,
    orderBy: (t) => t.sortOrder,
  );

  if (layers.isEmpty) {
    final now = DateTime.now().toUtc();
    final defaultLayer = await MapLayer.db.insertRow(
      session,
      MapLayer(
        id: defaultMapLayerId,
        name: 'Default',
        sortOrder: 0,
        visible: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    layers = [defaultLayer];
  }

  await MapMarker.db.updateWhere(
    session,
    where: (t) => t.layerId.equals(null),
    columnValues: (t) => [t.layerId(defaultMapLayerId)],
  );
  await MapZone.db.updateWhere(
    session,
    where: (t) => t.layerId.equals(null),
    columnValues: (t) => [t.layerId(defaultMapLayerId)],
  );

  return MapLayer.db.find(
    session,
    orderBy: (t) => t.sortOrder,
  );
}
