abstract final class MarkerIconCategoryKey {
  static final RegExp pattern = RegExp(r'^[a-z0-9_]{1,64}$');

  static const protectedKeys = {'custom'};

  static String normalize(String raw) {
    final key = raw.trim().toLowerCase();
    if (!pattern.hasMatch(key)) {
      throw FormatException(
        'Invalid marker icon category key "$raw". '
        'Use lowercase letters, digits, and underscores (max 64).',
      );
    }
    return key;
  }
}
