import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Map tiles'),
              Tab(text: 'Geocoding'),
              Tab(text: 'Backup'),
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
