import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../codec/radio_event_codec.dart';
import '../models/radio_domain_event.dart';

const radioOutboxPrefsKey = 'wayfinder.radio_sync.outbox';

/// Persisted outbound radio event (encoded frame bytes).
class RadioOutboxRecord {
  const RadioOutboxRecord({
    required this.eventId,
    required this.msgType,
    required this.frameBytes,
    required this.enqueuedAt,
  });

  final String eventId;
  final int msgType;
  final Uint8List frameBytes;
  final DateTime enqueuedAt;

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'msgType': msgType,
    'frameBytes': base64Encode(frameBytes),
    'enqueuedAt': enqueuedAt.toIso8601String(),
  };

  factory RadioOutboxRecord.fromJson(Map<String, dynamic> json) {
    return RadioOutboxRecord(
      eventId: json['eventId'] as String,
      msgType: (json['msgType'] as num).toInt(),
      frameBytes: Uint8List.fromList(
        base64Decode(json['frameBytes'] as String),
      ),
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
    );
  }

  factory RadioOutboxRecord.fromEvent(
    RadioDomainEvent event, {
    RadioEventCodec codec = const RadioEventCodec(),
  }) {
    return RadioOutboxRecord(
      eventId: event.eventId,
      msgType: event.msgType,
      frameBytes: codec.encode(event),
      enqueuedAt: DateTime.now().toUtc(),
    );
  }

  RadioDomainEvent? decode({
    RadioEventCodec codec = const RadioEventCodec(),
  }) => codec.decode(frameBytes);
}

/// Device-local outbox for radio-sync frames awaiting server (or mesh) flush.
class RadioOutboxStore {
  RadioOutboxStore({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? SharedPreferences.getInstance();

  Future<List<RadioOutboxRecord>> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(radioOutboxPrefsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final entry in list)
          RadioOutboxRecord.fromJson(Map<String, dynamic>.from(entry as Map)),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<RadioOutboxRecord> records) async {
    final prefs = await _prefs;
    final encoded = jsonEncode([for (final r in records) r.toJson()]);
    await prefs.setString(radioOutboxPrefsKey, encoded);
  }

  Future<void> enqueue(RadioDomainEvent event) async {
    final records = [...await load()];
    // Dedupe by eventId (retries / dual emit).
    records.removeWhere((r) => r.eventId == event.eventId);
    records.add(RadioOutboxRecord.fromEvent(event));
    await save(records);
  }

  Future<void> enqueueAll(Iterable<RadioDomainEvent> events) async {
    for (final event in events) {
      await enqueue(event);
    }
  }

  Future<int> get pendingCount async => (await load()).length;

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(radioOutboxPrefsKey);
  }
}
