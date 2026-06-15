import 'dart:convert';

import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
// Protomaps v4 layer definitions are not exported publicly.
// ignore: implementation_imports
import 'package:vector_map_tiles_pmtiles/src/themes/v4/_package.dart' as v4;
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

/// Builds a Protomaps light v4 theme with label expressions compatible with
/// [vector_tile_renderer].
///
/// Protomaps v4 styles use MapLibre `format` expressions for multilingual
/// labels. Those are not implemented in vector_tile_renderer, so labels would
/// otherwise evaluate to empty strings offline.
Theme buildOfflineProtomapsLightV4Theme() {
  final layers = v4.themeLight
      .map(
        (layer) => Map<String, Object>.from(
          jsonDecode(jsonEncode(layer)) as Map,
        ),
      )
      .toList();

  for (final layer in layers) {
    if (layer['type'] != 'symbol') {
      continue;
    }

    final layout = layer['layout'];
    if (layout is! Map) {
      continue;
    }

    if (!layout.containsKey('text-field')) {
      continue;
    }

    layout['text-field'] = [
      'coalesce',
      ['get', 'name:en'],
      ['get', 'pgf:name'],
      ['get', 'name'],
    ];
  }

  return ProtomapsThemes(
    glyphs: 'asset://protomaps/glyphs/{fontstack}/{range}.pbf',
  ).build(layers);
}
