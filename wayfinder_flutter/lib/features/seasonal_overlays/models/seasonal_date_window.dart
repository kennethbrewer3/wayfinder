import 'dart:convert';

const seasonalDateModeAbsolute = 'absolute';
const seasonalDateModeRecurring = 'recurring';

/// One dated window for a seasonal overlay.
///
/// Absolute windows use calendar dates (`YYYY-MM-DD`).
/// Recurring windows use month/day pairs and may wrap across New Year.
class SeasonalDateWindow {
  const SeasonalDateWindow.absolute({
    required this.startDate,
    required this.endDate,
  }) : startMonth = null,
       startDay = null,
       endMonth = null,
       endDay = null;

  const SeasonalDateWindow.recurring({
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
  }) : startDate = null,
       endDate = null;

  final DateTime? startDate;
  final DateTime? endDate;
  final int? startMonth;
  final int? startDay;
  final int? endMonth;
  final int? endDay;

  bool get isAbsolute => startDate != null && endDate != null;

  bool get isRecurring =>
      startMonth != null &&
      startDay != null &&
      endMonth != null &&
      endDay != null;

  bool contains(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    if (isAbsolute) {
      final start = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
      );
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      return !date.isBefore(start) && !date.isAfter(end);
    }
    if (!isRecurring) {
      return false;
    }
    final ordinal = _dayOfYear(date.month, date.day);
    final startOrdinal = _dayOfYear(startMonth!, startDay!);
    final endOrdinal = _dayOfYear(endMonth!, endDay!);
    if (startOrdinal <= endOrdinal) {
      return ordinal >= startOrdinal && ordinal <= endOrdinal;
    }
    // Wraps year boundary (e.g. Nov 15 → Jan 15).
    return ordinal >= startOrdinal || ordinal <= endOrdinal;
  }

  Map<String, dynamic> toJson({required bool recurring}) {
    if (recurring) {
      return {
        'startMonth': startMonth,
        'startDay': startDay,
        'endMonth': endMonth,
        'endDay': endDay,
      };
    }
    return {
      'start': _formatDate(startDate!),
      'end': _formatDate(endDate!),
    };
  }

  static SeasonalDateWindow? fromJson(
    Map<String, dynamic> json, {
    required bool recurring,
  }) {
    if (recurring) {
      final startMonth = _asInt(json['startMonth']);
      final startDay = _asInt(json['startDay']);
      final endMonth = _asInt(json['endMonth']);
      final endDay = _asInt(json['endDay']);
      if (startMonth == null ||
          startDay == null ||
          endMonth == null ||
          endDay == null) {
        return null;
      }
      if (!_validMonthDay(startMonth, startDay) ||
          !_validMonthDay(endMonth, endDay)) {
        return null;
      }
      return SeasonalDateWindow.recurring(
        startMonth: startMonth,
        startDay: startDay,
        endMonth: endMonth,
        endDay: endDay,
      );
    }

    final start = _parseDate(json['start']);
    final end = _parseDate(json['end']);
    if (start == null || end == null || end.isBefore(start)) {
      return null;
    }
    return SeasonalDateWindow.absolute(startDate: start, endDate: end);
  }
}

class SeasonalSchedule {
  const SeasonalSchedule({
    required this.dateMode,
    required this.windows,
  });

  final String dateMode;
  final List<SeasonalDateWindow> windows;

  bool get isRecurring => dateMode == seasonalDateModeRecurring;

  bool get isValid =>
      (dateMode == seasonalDateModeAbsolute ||
          dateMode == seasonalDateModeRecurring) &&
      windows.isNotEmpty;

  bool isActiveOn(DateTime day) {
    if (!isValid) {
      return false;
    }
    for (final window in windows) {
      if (window.contains(day)) {
        return true;
      }
    }
    return false;
  }

  String encode() {
    return jsonEncode([
      for (final window in windows) window.toJson(recurring: isRecurring),
    ]);
  }

  static SeasonalSchedule parse({
    required String dateMode,
    required String dateWindowsJson,
  }) {
    final mode = dateMode == seasonalDateModeRecurring
        ? seasonalDateModeRecurring
        : seasonalDateModeAbsolute;
    try {
      final decoded = jsonDecode(dateWindowsJson);
      if (decoded is! List) {
        return SeasonalSchedule(dateMode: mode, windows: const []);
      }
      final windows = <SeasonalDateWindow>[];
      for (final entry in decoded) {
        if (entry is! Map) {
          continue;
        }
        final window = SeasonalDateWindow.fromJson(
          Map<String, dynamic>.from(entry),
          recurring: mode == seasonalDateModeRecurring,
        );
        if (window != null) {
          windows.add(window);
        }
      }
      return SeasonalSchedule(dateMode: mode, windows: windows);
    } catch (_) {
      return SeasonalSchedule(dateMode: mode, windows: const []);
    }
  }
}

bool isSeasonalOverlayActive({
  required String dateMode,
  required String dateWindowsJson,
  DateTime? on,
}) {
  final schedule = SeasonalSchedule.parse(
    dateMode: dateMode,
    dateWindowsJson: dateWindowsJson,
  );
  return schedule.isActiveOn(on ?? DateTime.now());
}

int _dayOfYear(int month, int day) {
  // Non-leap ordinal used only for relative month/day comparisons.
  const cumulative = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  return cumulative[month - 1] + day;
}

bool _validMonthDay(int month, int day) {
  if (month < 1 || month > 12 || day < 1) {
    return false;
  }
  const lengths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return day <= lengths[month - 1];
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? _parseDate(Object? raw) {
  if (raw is! String || raw.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw.trim());
  if (match == null) {
    return null;
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (!_validMonthDay(month, day)) {
    return null;
  }
  return DateTime(year, month, day);
}

int? _asInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  return null;
}
