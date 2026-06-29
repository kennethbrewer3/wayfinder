import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_env.dart';
import '../generated/protocol.dart';
import 'app_settings_store.dart';

/// Manages named REST API keys (stored as SHA-256 hashes in [RestApiKey] rows).
abstract final class RestApiKeyService {
  static const keyPrefix = 'wf_';
  static const previewLength = 8;
  static const legacyKeyName = 'Legacy key';

  static Set<String>? _cachedHashes;

  static String? get configuredEnvKey => WayfinderEnv.restApiKey;

  static bool get envKeyConfigured {
    final key = configuredEnvKey;
    return key != null && key.isNotEmpty;
  }

  static Future<bool> isAuthEnabled(Session session) async {
    if (envKeyConfigured) {
      return true;
    }
    final hashes = await storedKeyHashes(session);
    return hashes.isNotEmpty;
  }

  static Future<Set<String>> storedKeyHashes(Session session) async {
    final cached = _cachedHashes;
    if (cached != null) {
      return cached;
    }

    await _migrateLegacyKeyIfNeeded(session);
    final keys = await RestApiKey.db.find(session);
    final hashes = keys.map((entry) => entry.keyHash.trim()).where((hash) {
      return hash.isNotEmpty;
    }).toSet();
    _cachedHashes = hashes;
    return hashes;
  }

  static void invalidateCache() {
    _cachedHashes = null;
  }

  static String generatePlaintextKey() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    final encoded = base64Url.encode(bytes).replaceAll('=', '');
    return '$keyPrefix$encoded';
  }

  static String hashKey(String apiKey) {
    return sha256.convert(utf8.encode(apiKey.trim())).toString();
  }

  static String keyPreview(String apiKey) {
    final trimmed = apiKey.trim();
    if (trimmed.length <= previewLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, previewLength)}…';
  }

  static Future<bool> matchesConfiguredKey(
    Session session,
    String provided,
  ) async {
    final trimmed = provided.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final envKey = configuredEnvKey;
    if (envKey != null &&
        envKey.isNotEmpty &&
        _secureCompare(trimmed, envKey)) {
      return true;
    }

    final hashes = await storedKeyHashes(session);
    if (hashes.isEmpty) {
      return false;
    }

    final providedHash = hashKey(trimmed);
    for (final storedHash in hashes) {
      if (_secureCompare(providedHash, storedHash)) {
        return true;
      }
    }
    return false;
  }

  static Future<RestApiKeyInfo> readStatus(Session session) async {
    final enabled = await isAuthEnabled(session);
    return RestApiKeyInfo(
      enabled: enabled,
      envKeyConfigured: envKeyConfigured,
    );
  }

  static Future<List<RestApiKey>> listKeys(Session session) async {
    await _migrateLegacyKeyIfNeeded(session);
    return RestApiKey.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  static Future<RestApiKeyCreated> createKey(
    Session session,
    String name,
  ) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'API key name is required.');
    }

    await _migrateLegacyKeyIfNeeded(session);

    final apiKey = generatePlaintextKey();
    final now = DateTime.now().toUtc();
    final entry = await RestApiKey.db.insertRow(
      session,
      RestApiKey(
        name: trimmedName,
        keyHash: hashKey(apiKey),
        keyPreview: keyPreview(apiKey),
        createdAt: now,
      ),
    );
    invalidateCache();
    await storedKeyHashes(session);

    return RestApiKeyCreated(
      key: entry,
      apiKey: apiKey,
    );
  }

  static Future<bool> deleteKey(Session session, UuidValue id) async {
    await _migrateLegacyKeyIfNeeded(session);
    final deleted = await RestApiKey.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
    if (deleted.isEmpty) {
      return false;
    }
    invalidateCache();
    return true;
  }

  static Future<void> clearStoredKeys(Session session) async {
    await _migrateLegacyKeyIfNeeded(session);
    final keys = await RestApiKey.db.find(session);
    if (keys.isNotEmpty) {
      await RestApiKey.db.delete(session, keys);
    }
    final settings = await AppSettingsStore.getOrCreate(session);
    if (settings.restApiKeyHash != null) {
      await AppSettingsStore.update(
        session,
        settings.copyWith(restApiKeyHash: null),
      );
    }
    invalidateCache();
  }

  static Future<void> _migrateLegacyKeyIfNeeded(Session session) async {
    final settings = await AppSettingsStore.getOrCreate(session);
    final legacyHash = settings.restApiKeyHash?.trim();
    if (legacyHash == null || legacyHash.isEmpty) {
      return;
    }

    final existing = await RestApiKey.db.find(session, limit: 1);
    if (existing.isNotEmpty) {
      await AppSettingsStore.update(
        session,
        settings.copyWith(restApiKeyHash: null),
      );
      invalidateCache();
      return;
    }

    await RestApiKey.db.insertRow(
      session,
      RestApiKey(
        name: legacyKeyName,
        keyHash: legacyHash,
        keyPreview: '$keyPrefix••••••••',
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await AppSettingsStore.update(
      session,
      settings.copyWith(restApiKeyHash: null),
    );
    invalidateCache();
  }

  static bool _secureCompare(String a, String b) {
    final aCodes = utf8.encode(a);
    final bCodes = utf8.encode(b);
    if (aCodes.length != bCodes.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < aCodes.length; i++) {
      result |= aCodes[i] ^ bCodes[i];
    }
    return result == 0;
  }
}
