import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import 'settings_backup_tab.dart';
import 'settings_general_tab.dart';
import 'settings_geocoding_tab.dart';
import 'settings_map_tiles_tab.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logSettings.info('⚙️ Settings screen opened');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.settingsTabGeneral),
              Tab(text: l10n.settingsTabMapTiles),
              Tab(text: l10n.settingsTabGeocoding),
              Tab(text: l10n.settingsTabBackup),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SettingsGeneralTab(),
            SettingsMapTilesTab(),
            SettingsGeocodingTab(),
            SettingsBackupTab(),
          ],
        ),
      ),
    );
  }
}
