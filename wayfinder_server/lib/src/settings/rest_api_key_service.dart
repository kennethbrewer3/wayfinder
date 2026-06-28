import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_env.dart';
import '../generated/protocol.dart';
import 'app_settings_store.dart';

/// Manages the REST API shared secret (stored as SHA-256 hash in [AppSettings]).
abstract final class RestApiKeyService {
  static const keyPrefix = 'wf_';
  static const previewLength = 8;

  static String? _cachedHash;

  static String? get configuredEnvKey => WayfinderEnv.restApiKey;

  static bool get envKeyConfigured {
    final key = configuredEnvKey;
    return key != null && key.isNotEmpty;
  }

  static Future<bool> isAuthEnabled(Session session) async {
    if (envKeyConfigured) {
      return true;
    }
    final hash = await storedKeyHash(session);
    return hash != null && hash.isNotEmpty;
  }

  static Future<String?> storedKeyHash(Session session) async {
    final cached = _cachedHash;
    if (cached != null) {
      return cached.isEmpty ? null : cached;
    }

    final settings = await AppSettingsStore.getOrCreate(session);
    final hash = settings.restApiKeyHash?.trim();
    _cachedHash = hash ?? '';
    return hash == null || hash.isEmpty ? null : hash;
  }

  static void invalidateCache() {
    _cachedHash = null;
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

  static bool matchesConfiguredKey(String provided, String? storedHash) {
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

    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }

    return _secureCompare(hashKey(trimmed), storedHash);
  }

  static Future<RestApiKeyInfo> readStatus(Session session) async {
    final enabled = await isAuthEnabled(session);
    if (!enabled) {
      return RestApiKeyInfo(enabled: false);
    }

    String? preview;
    final storedHash = await storedKeyHash(session);
    if (storedHash != null && storedHash.isNotEmpty) {
      preview = '$keyPrefix••••••••';
    } else if (envKeyConfigured) {
      preview = keyPreview(configuredEnvKey!);
    }

    return RestApiKeyInfo(
      enabled: true,
      keyPreview: preview,
    );
  }

  static Future<RestApiKeyInfo> generateAndStore(Session session) async {
    final apiKey = generatePlaintextKey();
    final settings = await AppSettingsStore.getOrCreate(session);
    await AppSettingsStore.update(
      session,
      settings.copyWith(restApiKeyHash: hashKey(apiKey)),
    );
    invalidateCache();
    await storedKeyHash(session);

    return RestApiKeyInfo(
      enabled: true,
      keyPreview: keyPreview(apiKey),
      apiKey: apiKey,
    );
  }

  static Future<RestApiKeyInfo> clearStoredKey(Session session) async {
    final settings = await AppSettingsStore.getOrCreate(session);
    await AppSettingsStore.update(
      session,
      settings.copyWith(restApiKeyHash: null),
    );
    invalidateCache();
    return readStatus(session);
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
