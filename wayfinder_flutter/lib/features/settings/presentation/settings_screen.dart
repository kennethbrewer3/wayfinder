import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../settings_tab.dart';
import 'settings_backup_tab.dart';
import 'settings_general_tab.dart';
import 'settings_geocoding_tab.dart';
import 'settings_map_tiles_tab.dart';

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
            Tab(text: l10n.settingsTabGeocoding),
            Tab(text: l10n.settingsTabBackup),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SettingsGeneralTab(),
          SettingsMapTilesTab(),
          SettingsGeocodingTab(),
          SettingsBackupTab(),
        ],
      ),
    );
  }
}
