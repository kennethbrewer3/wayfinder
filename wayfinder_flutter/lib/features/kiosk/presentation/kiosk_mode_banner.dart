import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../providers/kiosk_mode_provider.dart';

class KioskModeBanner extends ConsumerWidget {
  const KioskModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kiosk = ref.watch(kioskModeActiveProvider);
    if (!kiosk) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final serverEnforced = ref.watch(kioskModeServerEnforcedProvider);

    return Material(
      color: theme.colorScheme.secondaryContainer,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.desktop_windows_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.kioskModeBannerTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      serverEnforced
                          ? l10n.kioskModeBannerServerEnforced
                          : l10n.kioskModeBannerHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (!serverEnforced)
                TextButton(
                  onPressed: () {
                    ref.read(localKioskModeProvider.notifier).setEnabled(false);
                  },
                  child: Text(l10n.kioskModeExit),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
