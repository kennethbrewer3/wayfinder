import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../../markers/models/marker_icon_registry.dart';
import '../../circles/models/circle_geometry.dart';
import '../../lines/models/line_geometry.dart';
import '../../rectangles/models/rectangle_geometry.dart';
import '../../map/providers/map_providers.dart';

class MapObjectTreeGroup<T> {
  const MapObjectTreeGroup({
    required this.key,
    required this.label,
    required this.items,
    this.leading,
  });

  final String key;
  final String label;
  final List<T> items;
  final Widget? leading;
}

double colorHueDegrees(Color color) {
  final hsv = HSVColor.fromColor(color);
  if (hsv.saturation < 0.05) {
    return -1;
  }
  return hsv.hue;
}

int compareColorHue(Color a, Color b) {
  final hueCompare = colorHueDegrees(a).compareTo(colorHueDegrees(b));
  if (hueCompare != 0) {
    return hueCompare;
  }
  return formatMarkerColorHex(a).compareTo(formatMarkerColorHex(b));
}

int compareVisibility(bool aVisible, bool bVisible) {
  if (aVisible == bVisible) {
    return 0;
  }
  return aVisible ? -1 : 1;
}

String markerNameGroupKey(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '#';
  }
  final first = trimmed[0].toUpperCase();
  final codeUnit = first.codeUnitAt(0);
  if (codeUnit >= 65 && codeUnit <= 90) {
    return first;
  }
  if (codeUnit >= 48 && codeUnit <= 57) {
    return '0-9';
  }
  return '#';
}

String markerNameGroupLabel(String key) {
  return switch (key) {
    '0-9' => '0-9',
    '#' => 'Other',
    _ => key,
  };
}

Color zoneSortColor(MapZone zone) {
  return switch (zone.type) {
    lineZoneType => parseMarkerColor(zone.color),
    circleZoneType => parseMarkerColor(zone.borderColor),
    rectangleZoneType => parseMarkerColor(zone.borderColor),
    _ => parseMarkerColor(zone.color),
  };
}

String zoneTypeLabel(String type) {
  return switch (type) {
    lineZoneType => 'Line',
    circleZoneType => 'Circle',
    rectangleZoneType => 'Rectangle',
    _ => type,
  };
}

int zoneTypeSortOrder(String type) {
  return switch (type) {
    lineZoneType => 0,
    circleZoneType => 1,
    rectangleZoneType => 2,
    _ => 99,
  };
}

int compareZoneTypes(String a, String b) {
  final orderCompare = zoneTypeSortOrder(a).compareTo(zoneTypeSortOrder(b));
  if (orderCompare != 0) {
    return orderCompare;
  }
  return zoneTypeLabel(a).compareTo(zoneTypeLabel(b));
}

int compareMarkers(MapMarker a, MapMarker b, MarkerSortField sort) {
  final primary = switch (sort) {
    MarkerSortField.name =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    MarkerSortField.hue =>
      compareColorHue(parseMarkerColor(a.color), parseMarkerColor(b.color)),
    MarkerSortField.icon => markerIconLabel(a.icon)
        .toLowerCase()
        .compareTo(markerIconLabel(b.icon).toLowerCase()),
    MarkerSortField.visibility => compareVisibility(a.visible, b.visible),
  };
  if (primary != 0) {
    return primary;
  }
  if (sort == MarkerSortField.name) {
    return a.id.uuid.compareTo(b.id.uuid);
  }
  final nameCompare =
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  if (nameCompare != 0) {
    return nameCompare;
  }
  return a.id.uuid.compareTo(b.id.uuid);
}

int compareZones(MapZone a, MapZone b, ZoneSortField sort) {
  final primary = switch (sort) {
    ZoneSortField.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    ZoneSortField.hue =>
      compareColorHue(zoneSortColor(a), zoneSortColor(b)),
    ZoneSortField.type => compareZoneTypes(a.type, b.type),
    ZoneSortField.visibility => compareVisibility(a.visible, b.visible),
  };
  if (primary != 0) {
    return primary;
  }
  if (sort == ZoneSortField.name) {
    return a.id.uuid.compareTo(b.id.uuid);
  }
  final nameCompare =
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  if (nameCompare != 0) {
    return nameCompare;
  }
  return a.id.uuid.compareTo(b.id.uuid);
}

int compareNameGroupKeys(String a, String b) {
  int rank(String key) {
    if (key == '#') {
      return 2;
    }
    if (key == '0-9') {
      return 1;
    }
    return 0;
  }

  final rankCompare = rank(a).compareTo(rank(b));
  if (rankCompare != 0) {
    return rankCompare;
  }
  return a.compareTo(b);
}

int compareMarkerGroups(
  MapObjectTreeGroup<MapMarker> a,
  MapObjectTreeGroup<MapMarker> b,
  MarkerSortField sort,
) {
  return switch (sort) {
    MarkerSortField.name => compareNameGroupKeys(a.key, b.key),
    MarkerSortField.hue => compareColorHue(
        parseMarkerColor(a.key),
        parseMarkerColor(b.key),
      ),
    MarkerSortField.icon => markerIconLabel(a.key)
        .toLowerCase()
        .compareTo(markerIconLabel(b.key).toLowerCase()),
    MarkerSortField.visibility => compareVisibility(
        a.key == 'visible',
        b.key == 'visible',
      ),
  };
}

int compareZoneGroups(
  MapObjectTreeGroup<MapZone> a,
  MapObjectTreeGroup<MapZone> b,
  ZoneSortField sort,
) {
  return switch (sort) {
    ZoneSortField.name => compareNameGroupKeys(a.key, b.key),
    ZoneSortField.hue => compareColorHue(
        parseMarkerColor(a.key),
        parseMarkerColor(b.key),
      ),
    ZoneSortField.type => compareZoneTypes(a.key, b.key),
    ZoneSortField.visibility => compareVisibility(
        a.key == 'visible',
        b.key == 'visible',
      ),
  };
}

List<MapMarker> sortMarkers(
  List<MapMarker> markers,
  MarkerSortField sort,
) {
  final sorted = [...markers]..sort((a, b) => compareMarkers(a, b, sort));
  return sorted;
}

List<MapZone> sortZones(
  List<MapZone> zones,
  ZoneSortField sort,
) {
  final sorted = [...zones]..sort((a, b) => compareZones(a, b, sort));
  return sorted;
}

List<MapObjectTreeGroup<MapMarker>> groupMarkers(
  List<MapMarker> markers,
  MarkerSortField sort,
) {
  final grouped = <String, List<MapMarker>>{};
  for (final marker in markers) {
    final key = switch (sort) {
      MarkerSortField.name => markerNameGroupKey(marker.name),
      MarkerSortField.hue => formatMarkerColorHex(parseMarkerColor(marker.color)),
      MarkerSortField.icon => marker.icon,
      MarkerSortField.visibility => marker.visible ? 'visible' : 'hidden',
    };
    grouped.putIfAbsent(key, () => []).add(marker);
  }

  final groups = grouped.entries.map((entry) {
    final items = [...entry.value]
      ..sort((a, b) => compareMarkers(a, b, MarkerSortField.name));
    return MapObjectTreeGroup<MapMarker>(
      key: entry.key,
      label: markerGroupLabel(entry.key, sort),
      leading: markerGroupLeading(entry.key, sort),
      items: items,
    );
  }).toList()
    ..sort((a, b) => compareMarkerGroups(a, b, sort));

  return groups;
}

List<MapObjectTreeGroup<MapZone>> groupZones(
  List<MapZone> zones,
  ZoneSortField sort,
) {
  final grouped = <String, List<MapZone>>{};
  for (final zone in zones) {
    final key = switch (sort) {
      ZoneSortField.name => markerNameGroupKey(zone.name),
      ZoneSortField.hue => formatMarkerColorHex(zoneSortColor(zone)),
      ZoneSortField.type => zone.type,
      ZoneSortField.visibility => zone.visible ? 'visible' : 'hidden',
    };
    grouped.putIfAbsent(key, () => []).add(zone);
  }

  final groups = grouped.entries.map((entry) {
    final items = [...entry.value]
      ..sort((a, b) => compareZones(a, b, ZoneSortField.name));
    return MapObjectTreeGroup<MapZone>(
      key: entry.key,
      label: zoneGroupLabel(entry.key, sort),
      leading: zoneGroupLeading(entry.key, sort),
      items: items,
    );
  }).toList()
    ..sort((a, b) => compareZoneGroups(a, b, sort));

  return groups;
}

String markerGroupLabel(String key, MarkerSortField sort) {
  return switch (sort) {
    MarkerSortField.name => markerNameGroupLabel(key),
    MarkerSortField.hue => key,
    MarkerSortField.icon => markerIconLabel(key),
    MarkerSortField.visibility => key == 'visible' ? 'Visible' : 'Hidden',
  };
}

String zoneGroupLabel(String key, ZoneSortField sort) {
  return switch (sort) {
    ZoneSortField.name => markerNameGroupLabel(key),
    ZoneSortField.hue => key,
    ZoneSortField.type => zoneTypeLabel(key),
    ZoneSortField.visibility => key == 'visible' ? 'Visible' : 'Hidden',
  };
}

Widget? markerGroupLeading(String key, MarkerSortField sort) {
  return switch (sort) {
    MarkerSortField.hue => _colorSwatch(parseMarkerColor(key)),
    MarkerSortField.icon => Icon(
        markerIconData(key),
        size: 18,
        color: parseMarkerColor('#1B4965'),
      ),
    _ => null,
  };
}

Widget? zoneGroupLeading(String key, ZoneSortField sort) {
  return switch (sort) {
    ZoneSortField.hue => _colorSwatch(parseMarkerColor(key)),
    ZoneSortField.type => Icon(
        zoneTypeIcon(key),
        size: 18,
        color: parseMarkerColor('#1B4965'),
      ),
    _ => null,
  };
}

IconData zoneTypeIcon(String type) {
  return switch (type) {
    lineZoneType => Icons.timeline,
    circleZoneType => Icons.radio_button_unchecked,
    rectangleZoneType => Icons.crop_square,
    _ => Icons.layers,
  };
}

Widget _colorSwatch(Color color) {
  return Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 2,
        ),
      ],
    ),
  );
}
