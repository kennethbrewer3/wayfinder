abstract final class MarkerIconBackgroundColor {
  static final RegExp pattern = RegExp(r'^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');

  static const defaultHex = '#FFFFFF';

  static String normalize(String? raw, {String fallback = defaultHex}) {
    final value = raw?.trim().toUpperCase();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    if (!pattern.hasMatch(value)) {
      throw FormatException(
        'Invalid icon background color "$raw". Use #RRGGBB or #AARRGGBB.',
      );
    }
    return value;
  }
}
