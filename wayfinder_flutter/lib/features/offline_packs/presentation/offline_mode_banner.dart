import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../data/offline_pack_store.dart';
import '../providers/force_offline_pack_provider.dart';
import '../providers/offline_pack_controller.dart';
import '../providers/offline_snapshot_provider.dart';
import '../providers/server_reachability_provider.dart';

class OfflineModeBanner extends ConsumerWidget {
  const OfflineModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineModeActiveProvider);
    if (!offline) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final meta = ref.watch(offlinePackMetaProvider).valueOrNull;
    final index =
        ref.watch(offlinePackIndexProvider).valueOrNull ??
        const OfflinePackIndex();
    final outbox = ref.watch(offlineOutboxCountProvider).valueOrNull ?? 0;
    final packName = meta?.name ?? l10n.offlinePackDefaultName;
    final forced =
        ref.watch(forceOfflinePackWhileOnlineProvider) &&
        ref.watch(serverReachableProvider);
    final subtitle = forced
        ? l10n.offlineModeBannerForcedHint
        : outbox > 0
        ? l10n.offlineModeBannerPending(outbox)
        : l10n.offlineModeBannerReadWriteHint;
    final canSwitch = index.packs.length > 1;

    return Material(
      color: theme.colorScheme.tertiaryContainer,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off,
                color: theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.offlineModeBannerTitle(packName),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (canSwitch)
                IconButton(
                  tooltip: l10n.offlinePackSwitchTooltip,
                  onPressed: () => _showPackSwitcher(context, ref, index),
                  icon: Icon(
                    Icons.swap_horiz,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPackSwitcher(
    BuildContext context,
    WidgetRef ref,
    OfflinePackIndex index,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.offlinePackSwitchTitle),
                subtitle: Text(l10n.offlinePackSwitchDescription),
              ),
              for (final pack in index.packs)
                ListTile(
                  leading: Icon(
                    pack.id == index.activePackId
                        ? Icons.check_circle
                        : Icons.offline_pin_outlined,
                  ),
                  title: Text(pack.name),
                  subtitle: pack.id == index.activePackId
                      ? Text(l10n.offlinePackActiveLabel)
                      : null,
                  onTap: () => Navigator.of(context).pop(pack.id),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == index.activePackId) {
      return;
    }
    await ref.read(offlinePackControllerProvider).activatePack(selected);
  }
}
