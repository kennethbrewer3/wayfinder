import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/core/l10n/localized_labels.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_icon_registry.dart';
import 'map_marker_icon.dart';

class MarkerIconPicker extends StatefulWidget {
  const MarkerIconPicker({
    super.key,
    required this.selectedIcon,
    required this.color,
    required this.onChanged,
    this.initiallyExpanded = false,
  });

  final String selectedIcon;
  final Color color;
  final ValueChanged<String> onChanged;
  final bool initiallyExpanded;

  static const _columns = 6;
  static const _gridSpacing = 4.0;
  static const _gridAspectRatio = 1.45;
  static const _gridIconSize = 18.0;

  @override
  State<MarkerIconPicker> createState() => _MarkerIconPickerState();
}

class _MarkerIconPickerState extends State<MarkerIconPicker> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedOption =
        markerIconOption(widget.selectedIcon) ?? markerIconOptions.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        selectedOption.icon,
                        color: widget.color,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.markerIconLabel,
                          style: theme.textTheme.labelLarge,
                        ),
                        Text(
                          selectedOption.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.markerIconHelp,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MarkerIconPicker._columns,
                    mainAxisSpacing: MarkerIconPicker._gridSpacing,
                    crossAxisSpacing: MarkerIconPicker._gridSpacing,
                    childAspectRatio: MarkerIconPicker._gridAspectRatio,
                  ),
                  itemCount: markerIconOptions.length,
                  itemBuilder: (context, index) {
                    final option = markerIconOptions[index];
                    final selected = widget.selectedIcon == option.key;

                    return Material(
                      color: selected
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.45)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: () => widget.onChanged(option.key),
                        borderRadius: BorderRadius.circular(6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 4,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option.icon,
                                  color: selected
                                      ? widget.color
                                      : theme.iconTheme.color,
                                  size: MarkerIconPicker._gridIconSize,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  localizedMarkerIconLabel(l10n, option.key),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MarkerColorPickerField extends StatelessWidget {
  const MarkerColorPickerField({
    super.key,
    required this.color,
    required this.onChanged,
  });

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.formColorLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ColorPicker(
          color: color,
          onColorChanged: onChanged,
          width: 32,
          height: 32,
          borderRadius: 8,
          spacing: 8,
          runSpacing: 8,
          enableOpacity: false,
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
    );
  }
}

class MarkerPreview extends StatelessWidget {
  const MarkerPreview({
    super.key,
    required this.color,
    required this.iconName,
  });

  final Color color;
  final String iconName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.formPreviewLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Align(
          child: MapMarkerIcon(
            color: color,
            iconName: iconName,
          ),
        ),
      ],
    );
  }
}
