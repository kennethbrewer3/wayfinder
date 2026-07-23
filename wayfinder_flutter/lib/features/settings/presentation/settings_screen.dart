import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../providers/visible_settings_tabs_provider.dart';
import '../settings_tab.dart';
import 'settings_about_tab.dart';
import 'settings_backup_tab.dart';
import 'settings_general_tab.dart';
import 'settings_geocoding_tab.dart';
import 'settings_map_tiles_tab.dart';
import 'settings_marker_icons_tab.dart';
import 'settings_seasonal_overlays_tab.dart';
import 'settings_themes_tab.dart';
import 'settings_tides_tab.dart';
import 'settings_trash_tab.dart';
import 'settings_users_tab.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.tab});

  final SettingsTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final visibleTabs = ref.watch(visibleSettingsTabsProvider);
    final selectedTab = visibleTabs.contains(tab) ? tab : SettingsTab.general;

    if (selectedTab != tab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.replace(selectedTab.routePath);
        }
      });
    }

    return _SettingsTabsScaffold(
      key: ValueKey(visibleTabs.map((t) => t.slug).join(',')),
      tabs: visibleTabs,
      selectedTab: selectedTab,
    );
  }
}

class _SettingsTabsScaffold extends StatefulWidget {
  const _SettingsTabsScaffold({
    super.key,
    required this.tabs,
    required this.selectedTab,
  });

  final List<SettingsTab> tabs;
  final SettingsTab selectedTab;

  @override
  State<_SettingsTabsScaffold> createState() => _SettingsTabsScaffoldState();
}

class _SettingsTabsScaffoldState extends State<_SettingsTabsScaffold>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: _indexFor(widget.selectedTab),
    );
    _tabController.addListener(_syncRouteFromSwipe);
    AppLogger.logSettings.info(
      '⚙️ Settings screen opened',
      data: widget.selectedTab.routePath,
    );
  }

  @override
  void didUpdateWidget(_SettingsTabsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = _indexFor(widget.selectedTab);
    if (_tabController.index != nextIndex) {
      _tabController.index = nextIndex;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncRouteFromSwipe);
    _tabController.dispose();
    super.dispose();
  }

  int _indexFor(SettingsTab tab) {
    final index = widget.tabs.indexOf(tab);
    return index >= 0 ? index : 0;
  }

  void _syncRouteFromSwipe() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final selectedTab = widget.tabs[_tabController.index];
    if (selectedTab != widget.selectedTab) {
      context.replace(selectedTab.routePath);
    }
  }

  void _openTab(int index) {
    final selectedTab = widget.tabs[index];
    if (selectedTab == widget.selectedTab) {
      return;
    }
    context.replace(selectedTab.routePath);
  }

  String _labelFor(SettingsTab tab, AppLocalizations l10n) {
    return switch (tab) {
      SettingsTab.general => l10n.settingsTabGeneral,
      SettingsTab.mapTiles => l10n.settingsTabMapTiles,
      SettingsTab.markerIcons => l10n.settingsTabMarkerIcons,
      SettingsTab.themes => l10n.settingsTabThemes,
      SettingsTab.geocoding => l10n.settingsTabGeocoding,
      SettingsTab.tides => l10n.settingsTabTides,
      SettingsTab.seasonalOverlays => l10n.settingsTabSeasonalOverlays,
      SettingsTab.users => l10n.settingsTabUsers,
      SettingsTab.trash => l10n.settingsTabTrash,
      SettingsTab.backup => l10n.settingsTabBackup,
      SettingsTab.about => l10n.settingsTabAbout,
    };
  }

  Widget _bodyFor(SettingsTab tab) {
    return switch (tab) {
      SettingsTab.general => const SettingsGeneralTab(),
      SettingsTab.mapTiles => const SettingsMapTilesTab(),
      SettingsTab.markerIcons => const SettingsMarkerIconsTab(),
      SettingsTab.themes => const SettingsThemesTab(),
      SettingsTab.geocoding => const SettingsGeocodingTab(),
      SettingsTab.tides => const SettingsTidesTab(),
      SettingsTab.seasonalOverlays => const SettingsSeasonalOverlaysTab(),
      SettingsTab.users => const SettingsUsersTab(),
      SettingsTab.trash => const SettingsTrashTab(),
      SettingsTab.backup => const SettingsBackupTab(),
      SettingsTab.about => const SettingsAboutTab(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: _openTab,
          tabs: [
            for (final tab in widget.tabs) Tab(text: _labelFor(tab, l10n)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [for (final tab in widget.tabs) _bodyFor(tab)],
      ),
    );
  }
}
