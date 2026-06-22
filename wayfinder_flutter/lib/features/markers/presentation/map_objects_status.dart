import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

String mapObjectsLoadErrorMessage(Object error, AppLocalizations l10n) {
  final text = error.toString();

  if (_isNotFoundError(text)) {
    return l10n.mapObjectsErrorServerUnreachable;
  }

  if (text.contains('Unauthorized') && text.contains('ServerpodClient')) {
    return l10n.mapObjectsErrorSignInRequired;
  }

  if (text.contains('ServerpodClient')) {
    return l10n.mapObjectsErrorGeneric;
  }

  return l10n.mapObjectsErrorRetry;
}

bool _isNotFoundError(String text) {
  return text.contains('statusCode = 404') ||
      text.contains('ServerpodClientNotFound');
}

class MapObjectsEmptyState extends StatelessWidget {
  const MapObjectsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapObjectsErrorState extends StatelessWidget {
  const MapObjectsErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.actionTryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
