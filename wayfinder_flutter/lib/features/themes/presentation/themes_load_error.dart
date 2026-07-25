import 'package:wayfinder_flutter/l10n/app_localizations.dart';

/// User-facing explanation for custom-theme list failures.
String themesLoadErrorMessage(
  Object error,
  AppLocalizations l10n, {
  required String apiUrl,
}) {
  final text = error.toString();
  final lower = text.toLowerCase();

  if (lower.contains('statuscode = 500') ||
      lower.contains('internal server error')) {
    return l10n.settingsThemesLoadFailedServerError(apiUrl);
  }

  if (lower.contains('unauthorized') ||
      lower.contains('authentication required') ||
      lower.contains('statuscode = 401') ||
      lower.contains('statuscode = 403') ||
      lower.contains('permission denied') ||
      lower.contains('accessdenied')) {
    return l10n.settingsThemesLoadFailedSignIn(apiUrl);
  }

  if (lower.contains('statuscode = -1') ||
      lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('connection refused') ||
      lower.contains('timed out') ||
      lower.contains('timeoutexception') ||
      lower.contains('clientexception')) {
    return l10n.settingsThemesLoadFailedUnreachable(apiUrl);
  }

  return l10n.settingsThemesLoadFailedGeneric(apiUrl, text);
}
