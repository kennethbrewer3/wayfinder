import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

enum SelectedMapObjectKind { marker, zone }

class SelectedMapObject {
  const SelectedMapObject({
    required this.kind,
    required this.id,
  });

  final SelectedMapObjectKind kind;
  final UuidValue id;

  @override
  bool operator ==(Object other) {
    return other is SelectedMapObject &&
        other.kind == kind &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}

extension SelectedMapObjectSelection on SelectedMapObject? {
  UuidValue? get selectedZoneId {
    final value = this;
    if (value == null || value.kind != SelectedMapObjectKind.zone) {
      return null;
    }
    return value.id;
  }

  UuidValue? get selectedMarkerId {
    final value = this;
    if (value == null || value.kind != SelectedMapObjectKind.marker) {
      return null;
    }
    return value.id;
  }
}

final selectedMapObjectProvider =
    StateNotifierProvider<SelectedMapObjectNotifier, SelectedMapObject?>(
  (ref) => SelectedMapObjectNotifier(),
);

class SelectedMapObjectNotifier extends StateNotifier<SelectedMapObject?> {
  SelectedMapObjectNotifier() : super(null);

  void select(SelectedMapObject object) {
    state = object;
  }

  void selectMarker(UuidValue id) {
    state = SelectedMapObject(kind: SelectedMapObjectKind.marker, id: id);
  }

  void selectZone(UuidValue id) {
    state = SelectedMapObject(kind: SelectedMapObjectKind.zone, id: id);
  }

  void clear() {
    state = null;
  }
}
