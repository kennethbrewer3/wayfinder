import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../app/theme.dart';
import '../models/app_theme_palette.dart';
import '../providers/app_theme_definitions_provider.dart';

Future<AppThemeDefinition?> showAppThemeEditorDialog({
  required BuildContext context,
  AppThemeDefinition? existing,
}) {
  return showDialog<AppThemeDefinition>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppThemeEditorDialog(existing: existing),
  );
}

class AppThemeEditorDialog extends ConsumerStatefulWidget {
  const AppThemeEditorDialog({super.key, this.existing});

  final AppThemeDefinition? existing;

  @override
  ConsumerState<AppThemeEditorDialog> createState() =>
      _AppThemeEditorDialogState();
}

class _AppThemeEditorDialogState extends ConsumerState<AppThemeEditorDialog> {
  late final TextEditingController _nameController;
  late String _brightness;
  late Color _seedColor;
  late Map<String, String> _overrides;
  var _showAllOverrides = false;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _brightness = existing?.brightness ?? 'light';
    _seedColor =
        parseThemeHexColor(existing?.seedColor) ?? const Color(0xFF1B4965);
    _overrides = Map<String, String>.from(
      decodeThemeOverrides(existing?.overridesJson ?? '{}'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  AppThemeDefinition get _previewDefinition {
    final now = DateTime.now().toUtc();
    return AppThemeDefinition(
      id: widget.existing?.id,
      name: _nameController.text.trim().isEmpty
          ? 'Preview'
          : _nameController.text.trim(),
      brightness: _brightness,
      seedColor: themeColorToHex(_seedColor),
      overridesJson: encodeThemeOverrides(_overrides),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  List<String> get _visibleRoles =>
      _showAllOverrides ? appThemeOverrideRoles : appThemePrimaryOverrideRoles;

  Future<void> _pickSeed() async {
    final next = await showColorPickerDialog(
      context,
      _seedColor,
      title: Text(AppLocalizations.of(context)!.settingsThemesSeedColor),
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
      },
    );
    setState(() => _seedColor = next);
  }

  Future<void> _pickOverride(String role) async {
    final current =
        parseThemeHexColor(_overrides[role]) ??
        colorSchemeFromThemeDefinition(_previewDefinition)._roleColor(role);
    final next = await showColorPickerDialog(
      context,
      current,
      title: Text(role),
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
      },
    );
    setState(() => _overrides[role] = themeColorToHex(next));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.settingsThemesNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(appThemeDefinitionsRepositoryProvider);
      final AppThemeDefinition saved;
      if (widget.existing?.id == null) {
        saved = await repo.create(
          name: name,
          brightness: _brightness,
          seedColor: themeColorToHex(_seedColor),
          overridesJson: encodeThemeOverrides(_overrides),
        );
      } else {
        saved = await repo.update(
          id: widget.existing!.id,
          name: name,
          brightness: _brightness,
          seedColor: themeColorToHex(_seedColor),
          overridesJson: encodeThemeOverrides(_overrides),
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(saved);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = l10n.settingsThemesSaveFailed(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewTheme = AppTheme.fromDefinition(_previewDefinition);
    final colors = previewTheme.colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 840),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? l10n.settingsThemesNewTitle
                    : l10n.settingsThemesEditTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.settingsThemesName,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.settingsBrightness,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'light',
                          label: Text(l10n.themeBrightnessLight),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          label: Text(l10n.themeBrightnessDark),
                        ),
                      ],
                      selected: {_brightness},
                      onSelectionChanged: (selection) {
                        setState(() => _brightness = selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsThemesSeedColor),
                      subtitle: Text(l10n.settingsThemesSeedColorHint),
                      trailing: _ColorChip(color: _seedColor),
                      onTap: _pickSeed,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsThemesOverridesTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.settingsThemesOverridesHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    for (final role in _visibleRoles)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(role),
                        subtitle: Text(
                          _overrides.containsKey(role)
                              ? _overrides[role]!
                              : l10n.settingsThemesOverrideFromSeed,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ColorChip(
                              color:
                                  parseThemeHexColor(_overrides[role]) ??
                                  colors._roleColor(role),
                            ),
                            if (_overrides.containsKey(role))
                              IconButton(
                                tooltip: l10n.settingsThemesClearOverride,
                                onPressed: () {
                                  setState(() => _overrides.remove(role));
                                },
                                icon: const Icon(Icons.clear),
                              ),
                          ],
                        ),
                        onTap: () => _pickOverride(role),
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() => _showAllOverrides = !_showAllOverrides);
                      },
                      child: Text(
                        _showAllOverrides
                            ? l10n.settingsThemesShowFewerOverrides
                            : l10n.settingsThemesShowAllOverrides,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: previewTheme,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.settingsThemesPreview,
                                style: previewTheme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _PreviewSwatch(
                                    label: l10n.themePreviewPrimary,
                                    color: colors.primary,
                                  ),
                                  _PreviewSwatch(
                                    label: l10n.themePreviewSecondary,
                                    color: colors.secondary,
                                  ),
                                  _PreviewSwatch(
                                    label: l10n.themePreviewSurface,
                                    color: colors.surface,
                                  ),
                                  _PreviewSwatch(
                                    label: l10n.themePreviewAccent,
                                    color: colors.tertiary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  FilledButton(
                                    onPressed: () {},
                                    child: Text(l10n.themePreviewButton),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Text(l10n.themePreviewOutline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.actionSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

class _PreviewSwatch extends StatelessWidget {
  const _PreviewSwatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

extension on ColorScheme {
  Color _roleColor(String role) {
    return switch (role) {
      'primary' => primary,
      'onPrimary' => onPrimary,
      'primaryContainer' => primaryContainer,
      'onPrimaryContainer' => onPrimaryContainer,
      'secondary' => secondary,
      'onSecondary' => onSecondary,
      'secondaryContainer' => secondaryContainer,
      'onSecondaryContainer' => onSecondaryContainer,
      'tertiary' => tertiary,
      'onTertiary' => onTertiary,
      'tertiaryContainer' => tertiaryContainer,
      'onTertiaryContainer' => onTertiaryContainer,
      'error' => error,
      'onError' => onError,
      'errorContainer' => errorContainer,
      'onErrorContainer' => onErrorContainer,
      'surface' => surface,
      'onSurface' => onSurface,
      'onSurfaceVariant' => onSurfaceVariant,
      'outline' => outline,
      'outlineVariant' => outlineVariant,
      'inverseSurface' => inverseSurface,
      'onInverseSurface' => onInverseSurface,
      'inversePrimary' => inversePrimary,
      'surfaceTint' => surfaceTint,
      _ => primary,
    };
  }
}
