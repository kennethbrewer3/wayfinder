import '../../markers/models/marker_icon_registry.dart';

/// Stable `uint8` icon ids for radio (`iconId`), indexed from [markerIconOptions].
abstract final class RadioIconDictionary {
  static final List<String> _keys = [
    for (final option in markerIconOptions) option.key,
  ];

  static final Map<String, int> _keyToId = {
    for (var i = 0; i < _keys.length && i < 256; i++) _keys[i]: i,
  };

  static int idForKey(String key) => _keyToId[key] ?? 0;

  static String keyForId(int id) {
    if (id < 0 || id >= _keys.length) {
      return _keys.isEmpty ? 'flag' : _keys.first;
    }
    return _keys[id];
  }
}
