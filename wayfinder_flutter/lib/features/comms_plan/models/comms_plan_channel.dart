import 'dart:convert';

import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_radio.dart';
import 'comms_radio_service.dart';

/// Operational role of a channel on the comms plan board.
enum CommsChannelRole {
  primary,
  alternate,
  emergency,
  tactical,
  liaison;

  static CommsChannelRole parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'primary' => CommsChannelRole.primary,
      'alternate' || 'alt' => CommsChannelRole.alternate,
      'emergency' || 'emcomm' => CommsChannelRole.emergency,
      'tactical' || 'tac' => CommsChannelRole.tactical,
      'liaison' => CommsChannelRole.liaison,
      _ => CommsChannelRole.primary,
    };
  }

  String get storageValue => name;
}

/// Go / no-go status for a planned channel.
enum CommsChannelAvailability {
  go,
  noGo,
  conditional,
  unknown;

  static CommsChannelAvailability parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'go' || 'green' => CommsChannelAvailability.go,
      'nogo' || 'no_go' || 'no-go' || 'red' => CommsChannelAvailability.noGo,
      'conditional' ||
      'amber' ||
      'yellow' => CommsChannelAvailability.conditional,
      _ => CommsChannelAvailability.unknown,
    };
  }

  String get storageValue => switch (this) {
    CommsChannelAvailability.go => 'go',
    CommsChannelAvailability.noGo => 'noGo',
    CommsChannelAvailability.conditional => 'conditional',
    CommsChannelAvailability.unknown => 'unknown',
  };
}

/// One net / frequency row on a [CommsPlan] board.
class CommsPlanChannel {
  const CommsPlanChannel({
    required this.id,
    required this.label,
    this.netName,
    this.role = CommsChannelRole.primary,
    this.radioService = CommsRadioService.ham,
    this.serviceChannelId,
    this.frequencyMHz,
    this.mode = MarkerRadioMode.fm,
    this.toneHz,
    this.offsetMHz,
    this.callsign,
    this.daysOfWeek = const [],
    this.startLocalTime,
    this.durationMinutes,
    this.availability = CommsChannelAvailability.unknown,
    this.statusNote,
    this.markerId,
    this.notes,
  });

  final String id;
  final String label;
  final String? netName;
  final CommsChannelRole role;
  final CommsRadioService radioService;

  /// Permitted channel id for GMRS/FRS/CB (e.g. `19`, `15R`). Null for ham.
  final String? serviceChannelId;
  final double? frequencyMHz;
  final MarkerRadioMode mode;
  final double? toneHz;
  final double? offsetMHz;
  final String? callsign;

  /// ISO weekday numbers 1=Mon … 7=Sun. Empty = unscheduled / always available.
  final List<int> daysOfWeek;

  /// Local wall-clock `HH:mm` in the plan timezone.
  final String? startLocalTime;
  final int? durationMinutes;
  final CommsChannelAvailability availability;
  final String? statusNote;
  final String? markerId;
  final String? notes;

  CommsPlanChannel copyWith({
    String? id,
    String? label,
    Object? netName = _unset,
    CommsChannelRole? role,
    CommsRadioService? radioService,
    Object? serviceChannelId = _unset,
    Object? frequencyMHz = _unset,
    MarkerRadioMode? mode,
    Object? toneHz = _unset,
    Object? offsetMHz = _unset,
    Object? callsign = _unset,
    List<int>? daysOfWeek,
    Object? startLocalTime = _unset,
    Object? durationMinutes = _unset,
    CommsChannelAvailability? availability,
    Object? statusNote = _unset,
    Object? markerId = _unset,
    Object? notes = _unset,
  }) {
    return CommsPlanChannel(
      id: id ?? this.id,
      label: label ?? this.label,
      netName: identical(netName, _unset) ? this.netName : netName as String?,
      role: role ?? this.role,
      radioService: radioService ?? this.radioService,
      serviceChannelId: identical(serviceChannelId, _unset)
          ? this.serviceChannelId
          : serviceChannelId as String?,
      frequencyMHz: identical(frequencyMHz, _unset)
          ? this.frequencyMHz
          : frequencyMHz as double?,
      mode: mode ?? this.mode,
      toneHz: identical(toneHz, _unset) ? this.toneHz : toneHz as double?,
      offsetMHz: identical(offsetMHz, _unset)
          ? this.offsetMHz
          : offsetMHz as double?,
      callsign: identical(callsign, _unset)
          ? this.callsign
          : callsign as String?,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startLocalTime: identical(startLocalTime, _unset)
          ? this.startLocalTime
          : startLocalTime as String?,
      durationMinutes: identical(durationMinutes, _unset)
          ? this.durationMinutes
          : durationMinutes as int?,
      availability: availability ?? this.availability,
      statusNote: identical(statusNote, _unset)
          ? this.statusNote
          : statusNote as String?,
      markerId: identical(markerId, _unset)
          ? this.markerId
          : markerId as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    if (netName != null && netName!.trim().isNotEmpty) 'netName': netName,
    'role': role.storageValue,
    'radioService': radioService.storageValue,
    if (serviceChannelId != null && serviceChannelId!.trim().isNotEmpty)
      'serviceChannelId': serviceChannelId,
    if (frequencyMHz != null) 'frequencyMHz': frequencyMHz,
    'mode': mode.storageValue,
    if (toneHz != null) 'toneHz': toneHz,
    if (offsetMHz != null) 'offsetMHz': offsetMHz,
    if (callsign != null && callsign!.trim().isNotEmpty)
      'callsign': radioService == CommsRadioService.cb
          ? callsign!.trim()
          : callsign!.trim().toUpperCase(),
    if (daysOfWeek.isNotEmpty) 'daysOfWeek': daysOfWeek,
    if (startLocalTime != null && startLocalTime!.trim().isNotEmpty)
      'startLocalTime': startLocalTime,
    if (durationMinutes != null) 'durationMinutes': durationMinutes,
    'availability': availability.storageValue,
    if (statusNote != null && statusNote!.trim().isNotEmpty)
      'statusNote': statusNote,
    if (markerId != null && markerId!.trim().isNotEmpty) 'markerId': markerId,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
  };

  factory CommsPlanChannel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['daysOfWeek'];
    final radioService = CommsRadioService.parse(
      json['radioService'] as String?,
    );
    final frequencyMHz = (json['frequencyMHz'] as num?)?.toDouble();
    var serviceChannelId = (json['serviceChannelId'] as String?)?.trim();
    if (radioService.usesPermittedChannels &&
        (serviceChannelId == null || serviceChannelId.isEmpty)) {
      serviceChannelId = findPermittedChannelByFrequency(
        radioService,
        frequencyMHz,
      )?.id;
    }
    return CommsPlanChannel(
      id: json['id'] as String? ?? const Uuid().v4(),
      label: (json['label'] as String?)?.trim().isNotEmpty == true
          ? (json['label'] as String).trim()
          : 'Channel',
      netName: (json['netName'] as String?)?.trim(),
      role: CommsChannelRole.parse(json['role'] as String?),
      radioService: radioService,
      serviceChannelId: serviceChannelId,
      frequencyMHz: frequencyMHz,
      mode: MarkerRadioMode.parse(json['mode'] as String?),
      toneHz: (json['toneHz'] as num?)?.toDouble(),
      offsetMHz: (json['offsetMHz'] as num?)?.toDouble(),
      callsign: (json['callsign'] as String?)?.trim(),
      daysOfWeek: rawDays is List
          ? [
              for (final day in rawDays)
                if (day is num) day.toInt(),
            ]
          : const [],
      startLocalTime: (json['startLocalTime'] as String?)?.trim(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      availability: CommsChannelAvailability.parse(
        json['availability'] as String?,
      ),
      statusNote: (json['statusNote'] as String?)?.trim(),
      markerId: (json['markerId'] as String?)?.trim(),
      notes: (json['notes'] as String?)?.trim(),
    );
  }
}

const _unset = Object();

List<CommsPlanChannel> decodeCommsPlanChannels(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return [
      for (final entry in decoded)
        if (entry is Map<String, dynamic>) CommsPlanChannel.fromJson(entry),
    ];
  } catch (_) {
    return const [];
  }
}

String encodeCommsPlanChannels(List<CommsPlanChannel> channels) {
  return jsonEncode([for (final channel in channels) channel.toJson()]);
}
