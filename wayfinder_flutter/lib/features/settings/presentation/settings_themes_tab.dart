import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../app/app_theme_choice.dart';
import '../../../app/app_theme_ids.dart';
import '../../../app/theme.dart';
import '../../../core/file_save.dart';
import '../../../core/l10n/localized_labels.dart';
import '../../access/providers/access_session_provider.dart';
import '../../settings/providers/app_theme_provider.dart';
import '../../themes/models/app_theme_palette.dart';
import '../../themes/providers/app_theme_definitions_provider.dart';
import '../../themes/presentation/app_theme_editor_dialog.dart';

class SettingsThemesTab extends ConsumerWidget {
  const SettingsThemesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canManage = ref.watch(canManageThemesProvider);
    final themesAsync = ref.watch(appThemeDefinitionsProvider);
    final selectedThemeId = ref.watch(appThemeProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.settingsThemesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          canManage
              ? l10n.settingsThemesDescription
              : l10n.settingsThemesPermissionDenied,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.settingsThemesBuiltInTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final choice in AppThemeChoice.values)
          _BuiltInThemeTile(
            choice: choice,
            selected: selectedThemeId == choice.name,
            onUse: () {
              unawaited(
                ref.read(appThemeProvider.notifier).setBuiltIn(choice),
              );
            },
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.settingsThemesCustomTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (canManage) ...[
              OutlinedButton.icon(
                onPressed: () => unawaited(_importTheme(context, ref)),
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.settingsThemesImport),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => unawaited(_createTheme(context, ref)),
                icon: const Icon(Icons.add),
                label: Text(l10n.settingsThemesNew),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        themesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(
            l10n.settingsThemesLoadFailed(error.toString()),
          ),
          data: (themes) {
            if (themes.isEmpty) {
              return Text(l10n.settingsThemesCustomEmpty);
            }
            return Column(
              children: [
                for (final theme in themes)
                  _CustomThemeCard(
                    theme: theme,
                    selected: AppThemeIds.matchesCustom(
                      selectedThemeId,
                      theme.id,
                    ),
                    canManage: canManage,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

Future<void> _createTheme(BuildContext context, WidgetRef ref) async {
  final created = await showAppThemeEditorDialog(context: context);
  if (created == null) {
    return;
  }
  await ref.read(appThemeDefinitionsProvider.notifier).reload();
  if (!context.mounted) {
    return;
  }
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.settingsThemesSaved(created.name))),
  );
}

Future<void> _importTheme(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final contents = await pickTextFileContents();
  if (contents == null || !context.mounted) {
    return;
  }
  try {
    jsonDecode(contents);
    final imported = await ref
        .read(appThemeDefinitionsRepositoryProvider)
        .importJson(contents);
    await ref.read(appThemeDefinitionsProvider.notifier).reload();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsThemesImported(imported.name))),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsThemesImportFailed(error.toString())),
      ),
    );
  }
}

class _BuiltInThemeTile extends StatelessWidget {
  const _BuiltInThemeTile({
    required this.choice,
    required this.selected,
    required this.onUse,
  });

  final AppThemeChoice choice;
  final bool selected;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppTheme.forChoice(choice).colorScheme;
    return Card(
      child: ListTile(
        leading: _ThemeSwatches(colors: colors),
        title: Text(choice.localizedLabel(l10n)),
        subtitle: Text(l10n.settingsThemesBuiltInSubtitle),
        trailing: selected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : TextButton(onPressed: onUse, child: Text(l10n.settingsThemesUse)),
      ),
    );
  }
}

class _CustomThemeCard extends ConsumerWidget {
  const _CustomThemeCard({
    required this.theme,
    required this.selected,
    required this.canManage,
  });

  final AppThemeDefinition theme;
  final bool selected;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = colorSchemeFromThemeDefinition(theme);
    final id = theme.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: _ThemeSwatches(colors: colors),
              title: Text(theme.name),
              subtitle: Text(l10n.settingsThemesCustomSubtitle),
              trailing: selected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : TextButton(
                      onPressed: () {
                        unawaited(
                          ref
                              .read(appThemeProvider.notifier)
                              .setCustomTheme(id),
                        );
                      },
                      child: Text(l10n.settingsThemesUse),
                    ),
            ),
            if (canManage)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => unawaited(_edit(context, ref)),
                      child: Text(l10n.settingsThemesEdit),
                    ),
                    TextButton(
                      onPressed: () => unawaited(_duplicate(context, ref)),
                      child: Text(l10n.settingsThemesDuplicate),
                    ),
                    TextButton(
                      onPressed: () => unawaited(_export(context, ref)),
                      child: Text(l10n.settingsThemesExport),
                    ),
                    TextButton(
                      onPressed: () => unawaited(_delete(context, ref)),
                      child: Text(l10n.settingsThemesDelete),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final updated = await showAppThemeEditorDialog(
      context: context,
      existing: theme,
    );
    if (updated == null) {
      return;
    }
    await ref.read(appThemeDefinitionsProvider.notifier).reload();
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsThemesSaved(updated.name))),
    );
  }

  Future<void> _duplicate(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final created = await ref
          .read(appThemeDefinitionsRepositoryProvider)
          .create(
            name: l10n.settingsThemesCopyName(theme.name),
            brightness: theme.brightness,
            seedColor: theme.seedColor,
            overridesJson: theme.overridesJson,
          );
      await ref.read(appThemeDefinitionsProvider.notifier).reload();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsThemesSaved(created.name))),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsThemesSaveFailed(error.toString())),
        ),
      );
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final json = await ref
          .read(appThemeDefinitionsRepositoryProvider)
          .exportJson(theme.id);
      final safeName = theme.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      final saved = await saveTextFile(
        fileName:
            'wayfinder-theme-${safeName.isEmpty ? 'custom' : safeName}.json',
        contents: json,
      );
      if (!context.mounted || !saved) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsThemesExported(theme.name))),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsThemesExportFailed(error.toString())),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsThemesDeleteTitle),
        content: Text(l10n.settingsThemesDeleteMessage(theme.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsThemesDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final selectedId = ref.read(appThemeProvider);
    try {
      await ref.read(appThemeDefinitionsRepositoryProvider).delete(theme.id);
      await ref.read(appThemeDefinitionsProvider.notifier).reload();
      if (AppThemeIds.matchesCustom(selectedId, theme.id)) {
        await ref
            .read(appThemeProvider.notifier)
            .setThemeId(AppThemeIds.defaultId);
      }
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsThemesDeleted(theme.name))),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsThemesDeleteFailed(error.toString())),
        ),
      );
    }
  }
}

class _ThemeSwatches extends StatelessWidget {
  const _ThemeSwatches({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 32,
      child: Row(
        children: [
          Expanded(child: ColoredBox(color: colors.primary)),
          Expanded(child: ColoredBox(color: colors.secondary)),
          Expanded(child: ColoredBox(color: colors.surface)),
        ],
      ),
    );
  }
}
