import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../providers/layers_provider.dart';
import '../utils/map_layer_utils.dart';

class LayerPickerField extends ConsumerWidget {
  const LayerPickerField({
    super.key,
    required this.selectedLayerId,
    required this.onChanged,
  });

  final UuidValue? selectedLayerId;
  final ValueChanged<UuidValue?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layersAsync = ref.watch(layersProvider);
    final theme = Theme.of(context);

    return layersAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(labelText: 'Layer'),
        child: Text('Loading…'),
      ),
      error: (_, __) => InputDecorator(
        decoration: const InputDecoration(labelText: 'Layer'),
        child: Text(
          layerNameForObject(layerId: selectedLayerId, layersById: const {}),
        ),
      ),
      data: (result) {
        final layers = result;
        final selectedId = resolveSelectedLayerId(
          selectedLayerId: selectedLayerId,
          layers: layers,
        );

        return InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Layer',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UuidValue>(
              isExpanded: true,
              value: selectedId,
              style: theme.textTheme.bodyMedium,
              items: [
                for (final layer in sortedMapLayers(layers))
                  DropdownMenuItem(
                    value: layer.id,
                    child: Text(layer.name),
                  ),
              ],
              onChanged: (value) => onChanged(value),
            ),
          ),
        );
      },
    );
  }
}
