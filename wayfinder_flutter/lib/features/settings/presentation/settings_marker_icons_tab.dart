import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/l10n/localized_labels.dart';
import '../../../core/logging/app_logger.dart';
import '../../markers/models/marker_icon_categories.dart';
import '../../markers/models/marker_icon_category_catalog.dart';
import '../../markers/models/marker_icon_registry.dart';
import '../../markers/presentation/map_marker_icon.dart';
import '../../markers/presentation/marker_icon_category_field.dart';
import '../../markers/providers/marker_icon_background_color_provider.dart';
import '../../markers/providers/marker_icon_providers.dart';

final _keyPattern = RegExp(r'^[a-z0-9_]{1,64}$');

class SettingsMarkerIconsTab extends ConsumerStatefulWidget {
  const SettingsMarkerIconsTab({super.key});

  @override
  ConsumerState<SettingsMarkerIconsTab> createState() =>
      _SettingsMarkerIconsTabState();
}

class _SettingsMarkerIconsTabState extends ConsumerState<SettingsMarkerIconsTab> {
  static final _log = AppLogger.logSettings;

  bool _isBusy = false;

  Future<void> _runBusy(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  String _displayLabel(AppLocalizations l10n, MarkerIconCatalogEntry entry) {
    if (markerIconOption(entry.key) != null) {
      return localizedMarkerIconLabel(l10n, entry.key);
    }
    return entry.label;
  }

  Future<void> _pickAndUploadSvg(String key) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['svg'],
      withData: true,
      withReadStream: true,
    );
    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    await _runBusy(() async {
      try {
        await ref
            .read(markerIconRepositoryProvider)
            .uploadSvgFile(key, result.files.single);
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsUploadSuccess(key))),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon SVG upload failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsUploadFailed(error.toString()))),
        );
      }
    });
  }

  Future<void> _createIcon() async {
    final l10n = AppLocalizations.of(context)!;
    final created = await showDialog<_CreateIconFormData>(
      context: context,
      builder: (context) => _CreateIconDialog(l10n: l10n),
    );
    if (created == null || !mounted) {
      return;
    }

    await _runBusy(() async {
      try {
        final repository = ref.read(markerIconRepositoryProvider);
        await repository.createIcon(
          key: created.key,
          label: created.label,
          category: created.category,
          coloredAsset: created.coloredAsset,
          glyphScale: created.glyphScale,
        );
        if (created.svgFile != null) {
          await repository.uploadSvgFile(created.key, created.svgFile!);
        }
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsCreateSuccess(created.label))),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon create failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsCreateFailed(error.toString()))),
        );
      }
    });
  }

  Future<void> _editIcon(MarkerIconCatalogEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final updated = await showDialog<_EditIconFormData>(
      context: context,
      builder: (context) => _EditIconDialog(
        l10n: l10n,
        entry: entry,
        initialLabel: _displayLabel(l10n, entry),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }

    await _runBusy(() async {
      try {
        await ref.read(markerIconRepositoryProvider).updateIcon(
              key: entry.key,
              label: updated.label,
              category: updated.category,
              coloredAsset: updated.coloredAsset,
              glyphScale: updated.glyphScale,
            );
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsUpdateSuccess(updated.label))),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon update failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsUpdateFailed(error.toString()))),
        );
      }
    });
  }

  Future<void> _deleteIcon(MarkerIconCatalogEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final label = _displayLabel(l10n, entry);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markerIconsDeleteTitle),
        content: Text(l10n.markerIconsDeleteMessage(label, entry.key)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await _runBusy(() async {
      try {
        await ref.read(markerIconRepositoryProvider).deleteIcon(entry.key);
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsDeleteSuccess)),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon delete failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconsDeleteFailed(error.toString()))),
        );
      }
    });
  }

  Future<void> _createCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final created = await showDialog<_CategoryFormData>(
      context: context,
      builder: (context) => _CreateCategoryDialog(l10n: l10n),
    );
    if (created == null || !mounted) {
      return;
    }

    await _runBusy(() async {
      try {
        await ref.read(markerIconRepositoryProvider).createCategory(
              key: created.key,
              label: created.label,
            );
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markerIconCategoriesCreateSuccess(created.label)),
          ),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon category create failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markerIconCategoriesCreateFailed(error.toString())),
          ),
        );
      }
    });
  }

  Future<void> _editCategory(MarkerIconCategoryDefinition category) async {
    final l10n = AppLocalizations.of(context)!;
    final updated = await showDialog<_CategoryFormData>(
      context: context,
      builder: (context) => _EditCategoryDialog(
        l10n: l10n,
        category: category,
      ),
    );
    if (updated == null || !mounted) {
      return;
    }

    await _runBusy(() async {
      try {
        await ref.read(markerIconRepositoryProvider).updateCategory(
              key: category.key,
              label: updated.label,
            );
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markerIconCategoriesUpdateSuccess(updated.label)),
          ),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon category update failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markerIconCategoriesUpdateFailed(error.toString())),
          ),
        );
      }
    });
  }

  Future<void> _deleteCategory(MarkerIconCategoryDefinition category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markerIconCategoriesDeleteTitle),
        content: Text(
          l10n.markerIconCategoriesDeleteMessage(category.label, category.key),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await _runBusy(() async {
      try {
        await ref.read(markerIconRepositoryProvider).deleteCategory(category.key);
        refreshMarkerIcons(ref);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markerIconCategoriesDeleteSuccess)),
        );
      } catch (error, stackTrace) {
        _log.error(
          '📍 Marker icon category delete failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markerIconCategoriesDeleteFailed(error.toString())),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(markerIconRemoteEntriesProvider);
    final categoryCatalogAsync = ref.watch(markerIconCategoryCatalogProvider);
    final categoryCatalog = categoryCatalogAsync.valueOrNull ??
        MarkerIconCategoryCatalog.fallback();
    final categoryOrder = categoryCatalog.orderedKeys;
    final theme = Theme.of(context);
    final previewColor = theme.colorScheme.primary;
    final iconBackgroundColor = ref.watch(markerIconBackgroundColorProvider);

    final bundledSvgIcons = markerIconOptions
        .where((option) => option.assetPath != null)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.markerIconsTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.markerIconsDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.markerIconBackgroundColorTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.markerIconBackgroundColorDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MapMarkerIcon(
                      color: previewColor,
                      iconName: 'horse',
                      iconBackgroundColor: iconBackgroundColor,
                      width: 36,
                      height: 36,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.markerIconBackgroundColorLabel,
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          ColorPicker(
                            color: iconBackgroundColor,
                            onColorChanged: (color) => ref
                                .read(markerIconBackgroundColorProvider.notifier)
                                .setColor(color),
                            width: 32,
                            height: 32,
                            borderRadius: 8,
                            spacing: 8,
                            runSpacing: 8,
                            enableOpacity: true,
                            pickersEnabled: const {
                              ColorPickerType.wheel: true,
                              ColorPickerType.primary: true,
                              ColorPickerType.accent: true,
                            },
                            pickerTypeLabels: {
                              ColorPickerType.wheel: l10n.themePreviewOutline,
                              ColorPickerType.primary: l10n.themePreviewPrimary,
                              ColorPickerType.accent: l10n.themePreviewAccent,
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.markerIconCategoriesTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.markerIconCategoriesDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isBusy ? null : _createCategory,
          icon: const Icon(Icons.create_new_folder_outlined),
          label: Text(l10n.markerIconCategoriesAddButton),
        ),
        const SizedBox(height: 12),
        categoryCatalogAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            _log.error(
              '📍 Marker icon categories load failed',
              error: error,
              stackTrace: stackTrace,
            );
            return Text(l10n.markerIconsLoadFailed(error.toString()));
          },
          data: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final category in categoryCatalog.categories) ...[
                  Card(
                    child: ListTile(
                      title: Text(
                        markerIconCategoryDisplayLabel(
                          l10n,
                          category.key,
                          catalog: categoryCatalog,
                        ),
                      ),
                      subtitle: Text(category.key),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.markerIconsEditAction,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: _isBusy
                                ? null
                                : () => _editCategory(category),
                          ),
                          if (category.key != MarkerIconCategories.custom)
                            IconButton(
                              tooltip: l10n.actionDelete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _isBusy
                                  ? null
                                  : () => _deleteCategory(category),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _isBusy ? null : _createIcon,
          icon: _isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(l10n.markerIconsAddButton),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.markerIconsServerCatalogTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        entriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            _log.error(
              '📍 Marker icon catalog load failed',
              error: error,
              stackTrace: stackTrace,
            );
            return Text(l10n.markerIconsLoadFailed(error.toString()));
          },
          data: (entries) {
            if (entries.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.markerIconsNoServerEntries,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
            }

            final grouped = groupMarkerIconsByCategory<MarkerIconCatalogEntry>(
              items: entries,
              categoryFor: (entry) => entry.category,
              categoryOrder: categoryOrder,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final categoryEntry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      markerIconCategoryDisplayLabel(
                        l10n,
                        categoryEntry.key,
                        catalog: categoryCatalog,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final entry in categoryEntry.value) ...[
                    _MarkerIconEntryTile(
                      entry: entry,
                      label: _displayLabel(l10n, entry),
                      previewColor: previewColor,
                      categoryCatalog: categoryCatalog,
                      onUploadSvg: () => _pickAndUploadSvg(entry.key),
                      onEdit: () => _editIcon(entry),
                      onDelete: () => _deleteIcon(entry),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          l10n.markerIconsBuiltInTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.markerIconsBuiltInDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Text(l10n.markerIconsBuiltInExpandTitle),
            subtitle: Text(l10n.markerIconsBuiltInExpandSubtitle(bundledSvgIcons.length)),
            children: [
              for (final categoryEntry in groupMarkerIconsByCategory<MarkerIconOption>(
                items: bundledSvgIcons,
                categoryFor: (option) => option.resolvedCategory,
                categoryOrder: categoryOrder,
              ).entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    markerIconCategoryDisplayLabel(
                      l10n,
                      categoryEntry.key,
                      catalog: categoryCatalog,
                    ),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                for (var i = 0; i < categoryEntry.value.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: MapMarkerIcon(
                      color: previewColor,
                      iconName: categoryEntry.value[i].key,
                      width: 32,
                      height: 32,
                    ),
                    title: Text(
                      localizedMarkerIconLabel(
                        l10n,
                        categoryEntry.value[i].key,
                      ),
                    ),
                    subtitle: Text(categoryEntry.value[i].key),
                    trailing: IconButton(
                      tooltip: l10n.markerIconsUploadSvgAction,
                      icon: const Icon(Icons.upload_file),
                      onPressed: _isBusy
                          ? null
                          : () => _pickAndUploadSvg(categoryEntry.value[i].key),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MarkerIconEntryTile extends StatelessWidget {
  const _MarkerIconEntryTile({
    required this.entry,
    required this.label,
    required this.previewColor,
    required this.categoryCatalog,
    required this.onUploadSvg,
    required this.onEdit,
    required this.onDelete,
  });

  final MarkerIconCatalogEntry entry;
  final String label;
  final Color previewColor;
  final MarkerIconCategoryCatalog categoryCatalog;
  final VoidCallback onUploadSvg;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtitle = entry.hasCustomSvg
        ? l10n.markerIconsEntryCustomSvg(entry.key)
        : l10n.markerIconsEntryMaterialFallback(entry.key);
    final categoryLabel = markerIconCategoryDisplayLabel(
      l10n,
      entry.category,
      catalog: categoryCatalog,
    );

    return Card(
      child: ListTile(
        leading: MapMarkerIcon(
          color: previewColor,
          iconName: entry.key,
          width: 32,
          height: 32,
        ),
        title: Text(label),
        subtitle: Text('$categoryLabel • $subtitle'),
        trailing: PopupMenuButton<_MarkerIconEntryAction>(
          onSelected: (action) {
            switch (action) {
              case _MarkerIconEntryAction.upload:
                onUploadSvg();
              case _MarkerIconEntryAction.edit:
                onEdit();
              case _MarkerIconEntryAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _MarkerIconEntryAction.upload,
              child: ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(l10n.markerIconsUploadSvgAction),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _MarkerIconEntryAction.edit,
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.markerIconsEditAction),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _MarkerIconEntryAction.delete,
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.actionDelete),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MarkerIconEntryAction { upload, edit, delete }

class _CreateIconFormData {
  const _CreateIconFormData({
    required this.key,
    required this.label,
    required this.category,
    required this.coloredAsset,
    required this.glyphScale,
    this.svgFile,
  });

  final String key;
  final String label;
  final String category;
  final bool coloredAsset;
  final double glyphScale;
  final PlatformFile? svgFile;
}

class _CreateIconDialog extends StatefulWidget {
  const _CreateIconDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_CreateIconDialog> createState() => _CreateIconDialogState();
}

class _CreateIconDialogState extends State<_CreateIconDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _labelController = TextEditingController();
  var _coloredAsset = false;
  var _glyphScale = 1.0;
  var _category = MarkerIconCategories.custom;
  PlatformFile? _svgFile;

  @override
  void dispose() {
    _keyController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickSvg() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['svg'],
      withData: true,
      withReadStream: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    setState(() => _svgFile = result.files.single);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _CreateIconFormData(
        key: _keyController.text.trim().toLowerCase(),
        label: _labelController.text.trim(),
        category: _category,
        coloredAsset: _coloredAsset,
        glyphScale: _glyphScale,
        svgFile: _svgFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.markerIconsCreateTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _keyController,
                  decoration: InputDecoration(
                    labelText: l10n.markerIconsKeyLabel,
                    hintText: l10n.markerIconsKeyHint,
                    border: const OutlineInputBorder(),
                  ),
                  autocorrect: false,
                  validator: (value) {
                    final key = value?.trim().toLowerCase() ?? '';
                    if (key.isEmpty) {
                      return l10n.markerIconsKeyRequired;
                    }
                    if (!_keyPattern.hasMatch(key)) {
                      return l10n.markerIconsKeyInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: l10n.markerIconsLabelField,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.markerIconsLabelRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                MarkerIconCategoryField(
                  l10n: l10n,
                  value: _category,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.markerIconsColoredAssetLabel),
                  subtitle: Text(l10n.markerIconsColoredAssetHelp),
                  value: _coloredAsset,
                  onChanged: (value) => setState(() => _coloredAsset = value),
                ),
                Text(l10n.markerIconsGlyphScaleLabel(_glyphScale.toStringAsFixed(2))),
                Slider(
                  value: _glyphScale,
                  min: 0.5,
                  max: 1.5,
                  divisions: 20,
                  label: _glyphScale.toStringAsFixed(2),
                  onChanged: (value) => setState(() => _glyphScale = value),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _pickSvg,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _svgFile == null
                          ? l10n.markerIconsPickSvgOptional
                          : l10n.markerIconsPickSvgSelected(_svgFile!.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionCreate),
        ),
      ],
    );
  }
}

class _EditIconFormData {
  const _EditIconFormData({
    required this.label,
    required this.category,
    required this.coloredAsset,
    required this.glyphScale,
  });

  final String label;
  final String category;
  final bool coloredAsset;
  final double glyphScale;
}

class _EditIconDialog extends StatefulWidget {
  const _EditIconDialog({
    required this.l10n,
    required this.entry,
    required this.initialLabel,
  });

  final AppLocalizations l10n;
  final MarkerIconCatalogEntry entry;
  final String initialLabel;

  @override
  State<_EditIconDialog> createState() => _EditIconDialogState();
}

class _EditIconDialogState extends State<_EditIconDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late bool _coloredAsset;
  late double _glyphScale;
  late String _category;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialLabel);
    _coloredAsset = widget.entry.coloredAsset;
    _glyphScale = widget.entry.glyphScale;
    _category = widget.entry.category;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _EditIconFormData(
        label: _labelController.text.trim(),
        category: _category,
        coloredAsset: _coloredAsset,
        glyphScale: _glyphScale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.markerIconsEditTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.entry.key,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.markerIconsLabelField,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.markerIconsLabelRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              MarkerIconCategoryField(
                l10n: l10n,
                value: _category,
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.markerIconsColoredAssetLabel),
                subtitle: Text(l10n.markerIconsColoredAssetHelp),
                value: _coloredAsset,
                onChanged: (value) => setState(() => _coloredAsset = value),
              ),
              Text(l10n.markerIconsGlyphScaleLabel(_glyphScale.toStringAsFixed(2))),
              Slider(
                value: _glyphScale,
                min: 0.5,
                max: 1.5,
                divisions: 20,
                label: _glyphScale.toStringAsFixed(2),
                onChanged: (value) => setState(() => _glyphScale = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

class _CategoryFormData {
  const _CategoryFormData({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

class _CreateCategoryDialog extends StatefulWidget {
  const _CreateCategoryDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _CategoryFormData(
        key: _keyController.text.trim().toLowerCase(),
        label: _labelController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.markerIconCategoriesCreateTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: l10n.markerIconCategoriesKeyLabel,
                  hintText: l10n.markerIconCategoriesKeyHint,
                  border: const OutlineInputBorder(),
                ),
                autocorrect: false,
                validator: (value) {
                  final key = value?.trim().toLowerCase() ?? '';
                  if (key.isEmpty) {
                    return l10n.markerIconCategoriesKeyRequired;
                  }
                  if (!_keyPattern.hasMatch(key)) {
                    return l10n.markerIconCategoriesKeyInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.markerIconCategoriesLabelField,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.markerIconCategoriesLabelRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionCreate),
        ),
      ],
    );
  }
}

class _EditCategoryDialog extends StatefulWidget {
  const _EditCategoryDialog({
    required this.l10n,
    required this.category,
  });

  final AppLocalizations l10n;
  final MarkerIconCategoryDefinition category;

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.category.label);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _CategoryFormData(
        key: widget.category.key,
        label: _labelController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.markerIconCategoriesEditTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: widget.category.key,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.markerIconCategoriesKeyLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.markerIconCategoriesLabelField,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.markerIconCategoriesLabelRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
