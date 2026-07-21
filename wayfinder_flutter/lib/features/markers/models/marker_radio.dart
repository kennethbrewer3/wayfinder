import 'dart:convert';

/// Station / contact role for a radio card on a marker.
enum MarkerRadioRole {
  shack,
  repeater,
  station,
  net,
  other;

  static MarkerRadioRole parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'shack' || 'ham_shack' => MarkerRadioRole.shack,
      'repeater' => MarkerRadioRole.repeater,
      'station' => MarkerRadioRole.station,
      'net' => MarkerRadioRole.net,
      _ => MarkerRadioRole.other,
    };
  }

  String get storageValue => name;
}

/// Operating mode (not live radio — planning metadata only).
enum MarkerRadioMode {
  fm,
  am,
  ssb,
  cw,
  digi,
  dmr,
  other;

  static MarkerRadioMode parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'fm' => MarkerRadioMode.fm,
      'am' => MarkerRadioMode.am,
      'ssb' || 'usb' || 'lsb' => MarkerRadioMode.ssb,
      'cw' => MarkerRadioMode.cw,
      'digi' || 'digital' || 'packet' => MarkerRadioMode.digi,
      'dmr' => MarkerRadioMode.dmr,
      _ => MarkerRadioMode.other,
    };
  }

  String get storageValue => name;
}

/// Marker icons that commonly carry radio contact cards.
const radioContactMarkerIconKeys = <String>{
  'ham_shack',
  'radio_repeater',
  'radio_station',
  'mesh_network_node',
};

bool isRadioContactMarkerIcon(String? icon) {
  final key = icon?.trim().toLowerCase();
  return key != null && radioContactMarkerIconKeys.contains(key);
}

/// Structured radio net / contact card stored on a marker as [radioJson].
class MarkerRadioContact {
  const MarkerRadioContact({
    this.callsign = '',
    this.frequencyMHz,
    this.mode = MarkerRadioMode.fm,
    this.toneHz,
    this.offsetMHz,
    this.role = MarkerRadioRole.other,
    this.netName,
    this.notes,
  });

  final String callsign;
  final double? frequencyMHz;
  final MarkerRadioMode mode;
  final double? toneHz;
  final double? offsetMHz;
  final MarkerRadioRole role;
  final String? netName;
  final String? notes;

  /// True when there is nothing worth persisting (role/mode alone do not count).
  bool get isEmpty => sanitizeMarkerRadioContact(this) == null;

  bool get isNotEmpty => !isEmpty;

  MarkerRadioContact copyWith({
    String? callsign,
    Object? frequencyMHz = _unset,
    MarkerRadioMode? mode,
    Object? toneHz = _unset,
    Object? offsetMHz = _unset,
    MarkerRadioRole? role,
    Object? netName = _unset,
    Object? notes = _unset,
  }) {
    return MarkerRadioContact(
      callsign: callsign ?? this.callsign,
      frequencyMHz: identical(frequencyMHz, _unset)
          ? this.frequencyMHz
          : frequencyMHz as double?,
      mode: mode ?? this.mode,
      toneHz: identical(toneHz, _unset) ? this.toneHz : toneHz as double?,
      offsetMHz: identical(offsetMHz, _unset)
          ? this.offsetMHz
          : offsetMHz as double?,
      role: role ?? this.role,
      netName: identical(netName, _unset) ? this.netName : netName as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (callsign.trim().isNotEmpty) 'callsign': callsign.trim().toUpperCase(),
      if (frequencyMHz != null) 'frequencyMHz': frequencyMHz,
      'mode': mode.storageValue,
      if (toneHz != null) 'toneHz': toneHz,
      if (offsetMHz != null) 'offsetMHz': offsetMHz,
      'role': role.storageValue,
      if (netName != null && netName!.trim().isNotEmpty)
        'netName': netName!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  String? toStorageJson() {
    final sanitized = sanitizeMarkerRadioContact(this);
    if (sanitized == null) {
      return null;
    }
    return jsonEncode(sanitized.toJson());
  }

  static MarkerRadioContact fromMarkerRadioJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const MarkerRadioContact();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const MarkerRadioContact();
      }
      return fromJson(decoded);
    } catch (_) {
      return const MarkerRadioContact();
    }
  }

  static MarkerRadioContact fromJson(Map<String, dynamic> json) {
    return MarkerRadioContact(
      callsign: json['callsign']?.toString().trim() ?? '',
      frequencyMHz: _parseDouble(json['frequencyMHz']),
      mode: MarkerRadioMode.parse(json['mode'] as String?),
      toneHz: _parseDouble(json['toneHz']),
      offsetMHz: _parseDouble(json['offsetMHz']),
      role: MarkerRadioRole.parse(json['role'] as String?),
      netName: _optionalTrimmed(json['netName']),
      notes: _optionalTrimmed(json['notes']),
    );
  }
}

/// Returns null when there is nothing meaningful to store.
MarkerRadioContact? sanitizeMarkerRadioContact(MarkerRadioContact contact) {
  final callsign = contact.callsign.trim().toUpperCase();
  final netName = contact.netName?.trim();
  final notes = contact.notes?.trim();
  final cleaned = MarkerRadioContact(
    callsign: callsign,
    frequencyMHz: contact.frequencyMHz,
    mode: contact.mode,
    toneHz: contact.toneHz,
    offsetMHz: contact.offsetMHz,
    role: contact.role,
    netName: (netName == null || netName.isEmpty) ? null : netName,
    notes: (notes == null || notes.isEmpty) ? null : notes,
  );
  if (cleaned.callsign.isEmpty &&
      cleaned.frequencyMHz == null &&
      cleaned.toneHz == null &&
      cleaned.offsetMHz == null &&
      cleaned.netName == null &&
      cleaned.notes == null) {
    return null;
  }
  return cleaned;
}

bool markerHasRadioContact(String? radioJson) {
  return MarkerRadioContact.fromMarkerRadioJson(radioJson).isNotEmpty;
}

/// Suggest a role from the marker icon when the card is still empty.
MarkerRadioRole suggestedRadioRoleForIcon(String? icon) {
  return switch (icon?.trim().toLowerCase()) {
    'ham_shack' => MarkerRadioRole.shack,
    'radio_repeater' => MarkerRadioRole.repeater,
    'radio_station' || 'mesh_network_node' => MarkerRadioRole.station,
    _ => MarkerRadioRole.other,
  };
}

String formatRadioFrequencyMHz(double? mhz) {
  if (mhz == null) {
    return '';
  }
  final text = mhz.toStringAsFixed(5);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

double? _parseDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw.trim());
  }
  return null;
}

String? _optionalTrimmed(Object? raw) {
  final text = raw?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

const Object _unset = Object();
