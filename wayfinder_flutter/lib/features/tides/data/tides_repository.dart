import 'dart:typed_data';

import 'package:wayfinder_client/wayfinder_client.dart';

class TidesRepository {
  TidesRepository(this._client);

  final Client _client;

  Future<List<TidePackInfo>> listPacks() => _client.tides.listPacks();

  Future<List<TideCoastalRegion>> listCoastalRegions() =>
      _client.tides.listCoastalRegions();

  Future<TidePackInfo> importCoastalRegion(String regionId) =>
      _client.tides.importCoastalRegion(regionId);

  Future<TidePackInfo> setPackActive(String packId, {required bool active}) =>
      _client.tides.setPackActive(packId, active);

  Future<bool> deletePack(String packId) => _client.tides.deletePack(packId);

  Future<Uint8List> exportPackArchive(String packId) async {
    final archive = await _client.tides.exportPack(packId);
    return archive.buffer.asUint8List(
      archive.offsetInBytes,
      archive.lengthInBytes,
    );
  }

  Future<TidePackInfo> importPackArchive(Uint8List archiveBytes) {
    return _client.tides.importPackArchive(ByteData.sublistView(archiveBytes));
  }

  Future<TideQueryResult> queryAt({
    required double lat,
    required double lng,
    required DateTime date,
    int hours = 24,
  }) {
    return _client.tides.queryAt(lat, lng, date, hours: hours);
  }
}
