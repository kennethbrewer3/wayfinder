import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../../../core/logging/app_logger.dart';
import 'protomaps_offline_theme.dart';

/// Bundled Protomaps theme assets for fully offline vector map rendering.
class ProtomapsOfflineMapStyle {
  const ProtomapsOfflineMapStyle({
    required this.theme,
    required this.backgroundTheme,
    required this.sprites,
  });

  final Theme theme;
  final Theme backgroundTheme;
  final SpriteStyle sprites;
}

class ProtomapsOfflineAssets {
  ProtomapsOfflineAssets._();

  static final _log = AppLogger.logMap;

  static const _spriteJsonAsset =
      'assets/protomaps/sprites/v4/light/light@2x.json';
  static const _spritePngAsset =
      'assets/protomaps/sprites/v4/light/light@2x.png';

  static Future<ProtomapsOfflineMapStyle>? _lightV4Cache;

  /// Loads the bundled Protomaps light v4 theme and sprite atlas.
  static Future<ProtomapsOfflineMapStyle> loadLightV4() {
    return _lightV4Cache ??= _loadLightV4();
  }

  static Future<ProtomapsOfflineMapStyle> _loadLightV4() async {
    _log.info('📦 Loading bundled Protomaps offline assets');

    final spriteBytes = await rootBundle.load(_spritePngAsset);
    final spriteJson = jsonDecode(
      await rootBundle.loadString(_spriteJsonAsset),
    ) as Map<String, dynamic>;

    final sprites = SpriteStyle(
      atlasProvider: () async => spriteBytes.buffer.asUint8List(
        spriteBytes.offsetInBytes,
        spriteBytes.lengthInBytes,
      ),
      index: SpriteIndexReader().read(spriteJson),
    );

    final theme = buildOfflineProtomapsLightV4Theme();
    final backgroundTheme = buildOfflineProtomapsBackgroundTheme();
    _log.info('📦 Using simplified offline label expressions for street names');

    _log.success('📦 Protomaps offline assets ready');
    return ProtomapsOfflineMapStyle(
      theme: theme,
      backgroundTheme: backgroundTheme,
      sprites: sprites,
    );
  }
}
