/// On-air [msgType] values from `radio-sync-events.md` (design draft).
abstract final class RadioSyncMsgType {
  static const int markerUpsert = 0x01;
  static const int markerDelete = 0x02;
  static const int zoneUpsertLight = 0x03;
  static const int zoneDelete = 0x04;
  static const int logAppend = 0x05;
  static const int eventAck = 0x06;
  static const int evacKitMetaUpsert = 0x10;
  static const int evacRouteUpsert = 0x11;
  static const int evacRouteDelete = 0x12;
  static const int evacKitDelete = 0x13;
  static const int chunk = 0x7e;
  static const int hello = 0x7f;
}
