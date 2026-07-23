import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../settings_tab.dart';
import 'settings_about_tab.dart';
import 'settings_backup_tab.dart';
import 'settings_general_tab.dart';
import 'settings_geocoding_tab.dart';
import 'settings_map_tiles_tab.dart';
import 'settings_marker_icons_tab.dart';
import 'settings_seasonal_overlays_tab.dart';
import 'settings_tides_tab.dart';
import 'settings_trash_tab.dart';
import 'settings_users_tab.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.tab});

  final SettingsTab tab;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SettingsTab.values.length,
      vsync: this,
      initialIndex: widget.tab.index,
    );
    _tabController.addListener(_syncRouteFromSwipe);
    AppLogger.logSettings.info(
      '⚙️ Settings screen opened',
      data: widget.tab.routePath,
    );
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab &&
        _tabController.index != widget.tab.index) {
      _tabController.index = widget.tab.index;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncRouteFromSwipe);
    _tabController.dispose();
    super.dispose();
  }

  void _syncRouteFromSwipe() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final selectedTab = SettingsTab.values[_tabController.index];
    if (selectedTab != widget.tab) {
      context.replace(selectedTab.routePath);
    }
  }

  void _openTab(int index) {
    final selectedTab = SettingsTab.values[index];
    if (selectedTab == widget.tab) {
      return;
    }
    context.replace(selectedTab.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kiosk = ref.watch(kioskModeActiveProvider);
    final serverEnforced = ref.watch(kioskModeServerEnforcedProvider);

    if (kiosk) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.kioskModeBannerTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/maps'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.desktop_windows_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                serverEnforced
                    ? l10n.kioskModeBannerServerEnforced
                    : l10n.kioskModeSettingsLockedMessage,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (!serverEnforced)
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(localKioskModeProvider.notifier)
                        .setEnabled(false);
                    if (context.mounted) {
                      context.go('/maps');
                    }
                  },
                  icon: const Icon(Icons.lock_open),
                  label: Text(l10n.kioskModeExit),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/maps'),
                child: Text(l10n.kioskModeBackToMap),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: _openTab,
          tabs: [
            Tab(text: l10n.settingsTabGeneral),
            Tab(text: l10n.settingsTabMapTiles),
            Tab(text: l10n.settingsTabMarkerIcons),
            Tab(text: l10n.settingsTabGeocoding),
            Tab(text: l10n.settingsTabTides),
            Tab(text: l10n.settingsTabSeasonalOverlays),
            Tab(text: l10n.settingsTabUsers),
            Tab(text: l10n.settingsTabTrash),
            Tab(text: l10n.settingsTabBackup),
            Tab(text: l10n.settingsTabAbout),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SettingsGeneralTab(),
          SettingsMapTilesTab(),
          SettingsMarkerIconsTab(),
          SettingsGeocodingTab(),
          SettingsTidesTab(),
          SettingsSeasonalOverlaysTab(),
          SettingsUsersTab(),
          SettingsTrashTab(),
          SettingsBackupTab(),
          SettingsAboutTab(),
        ],
      ),
    );
  }
}
